package com.dryclean.mall.service;

import com.dryclean.mall.dto.OrderCreateRequest;
import com.dryclean.mall.dto.OrderDTO;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.entity.OrderInfo;
import com.dryclean.mall.repository.OrderCommentRepository;
import com.dryclean.mall.repository.MallProductRepository;
import com.dryclean.mall.repository.MallStoreRepository;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.SysUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderInfoRepository orderRepository;
    private final DryServiceRepository serviceRepository;
    private final MallProductRepository productRepository;
    private final OrderCommentRepository commentRepository;
    private final SysUserRepository userRepository;
    private final MallStoreRepository storeRepository;
    private final NotificationService notificationService;

    @Transactional
    public OrderDTO create(Long userId, OrderCreateRequest req) {
        int qty = req.getQuantity() == null || req.getQuantity() < 1 ? 1 : req.getQuantity();
        String orderType = req.getOrderType() != null ? req.getOrderType().trim().toUpperCase() : "SERVICE";
        BigDecimal unit;
        BigDecimal total;
        DryService service = null;
        MallProduct product = null;
        if ("PRODUCT".equals(orderType)) {
            if (req.getProductId() == null) throw new RuntimeException("商品ID不能为空");
            product = productRepository.findById(req.getProductId())
                    .orElseThrow(() -> new RuntimeException("商品不存在"));
            unit = product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO;
            total = unit.multiply(BigDecimal.valueOf(qty));
        } else {
            if (req.getServiceId() == null) throw new RuntimeException("服务ID不能为空");
            orderType = "SERVICE";
            service = serviceRepository.findById(req.getServiceId())
                    .orElseThrow(() -> new RuntimeException("服务不存在"));
            unit = resolveServiceUnitPrice(service, req.getServiceSpecName());
            total = unit.multiply(BigDecimal.valueOf(qty));
        }
        OrderInfo order = new OrderInfo();
        order.setOrderNo("DC" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase());
        order.setUserId(userId);
        order.setOrderType(orderType);
        if ("PRODUCT".equals(orderType)) {
            order.setProductId(product.getId());
            order.setServiceId(null);
        } else {
            order.setServiceId(service.getId());
            order.setProductId(null);
        }
        order.setQuantity(qty);
        order.setTotalPrice(total);
        order.setStatus("PENDING");
        order.setPayStatus("UNPAID");
        String rmk = req.getRemark();
        if ("SERVICE".equals(orderType)) {
            if (StringUtils.hasText(req.getServiceSpecName()) && StringUtils.hasText(service.getSpecs())
                    && parseSpecPrice(service.getSpecs(), req.getServiceSpecName()) != null) {
                rmk = "[规格:" + req.getServiceSpecName().trim() + "] " + (rmk != null ? rmk : "");
            }
        }
        order.setRemark(rmk);
        order.setAddressId(req.getAddressId());
        order.setDeliveryType(req.getDeliveryType() != null ? req.getDeliveryType() : "DOOR_TO_DOOR");
        order.setStoreId(req.getStoreId());
        order.setPickupDate(req.getPickupDate());
        order.setUrgent(Boolean.TRUE.equals(req.getUrgent()) ? 1 : 0);
        order = orderRepository.save(order);
        if ("PRODUCT".equals(orderType)) {
            order.setProduct(product);
        } else {
            order.setService(service);
        }
        OrderInfo savedOrder = order;
        userRepository.findAll().stream()
                .filter(u -> "MERCHANT".equals(u.getRole()))
                .findFirst()
                .ifPresent(merchant -> notificationService.create(merchant.getId(), "新订单",
                        "订单 " + savedOrder.getOrderNo() + " 待处理，请及时接单。", "ORDER", savedOrder.getId()));
        return OrderDTO.fromEntity(savedOrder);
    }

    /** 按规格解析单价；规格无效时用服务基础价 */
    private BigDecimal resolveServiceUnitPrice(DryService service, String specName) {
        BigDecimal base = service.getPrice() != null ? service.getPrice() : BigDecimal.ZERO;
        if (!StringUtils.hasText(specName) || !StringUtils.hasText(service.getSpecs())) {
            return base;
        }
        BigDecimal p = parseSpecPrice(service.getSpecs(), specName);
        return p != null ? p : base;
    }

    private BigDecimal parseSpecPrice(String specs, String specName) {
        String target = specName.trim();
        for (String part : specs.split("[;,，]")) {
            part = part.trim();
            if (part.isEmpty()) continue;
            int idx = part.indexOf('|');
            if (idx <= 0 || idx >= part.length() - 1) continue;
            String name = part.substring(0, idx).trim();
            if (!name.equals(target)) continue;
            String num = part.substring(idx + 1).trim().replaceAll("[^0-9.]", "");
            try {
                BigDecimal price = new BigDecimal(num);
                if (price.compareTo(BigDecimal.ZERO) > 0) return price;
            } catch (Exception ignored) { }
        }
        return null;
    }

    public List<OrderDTO> listByUser(Long userId, int page, int size) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId,
                        org.springframework.data.domain.PageRequest.of(page, size))
                .stream()
                .map(o -> {
                    OrderDTO dto = OrderDTO.fromEntity(o);

                    if ("PRODUCT".equals(o.getOrderType())) {
                        if (o.getProductId() != null) {
                            MallProduct p = productRepository.findById(o.getProductId()).orElse(null);
                            dto.setProductName(p != null ? p.getName() : null);
                            dto.setProductImage(p != null ? p.getImage() : null);
                        }
                    } else {
                        if (o.getServiceId() != null) {
                            DryService s = serviceRepository.findById(o.getServiceId()).orElse(null);
                            dto.setServiceName(s != null ? s.getName() : null);
                            dto.setServiceImage(s != null ? s.getImage() : null);
                        }
                    }

                    // 用订单ID判断该用户是否已评价过该订单，用于“收货后才出现评价按钮”
                    dto.setHasComment(commentRepository.existsByOrderIdAndUserId(o.getId(), userId));

                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public OrderDTO pay(Long userId, Long orderId) {
        OrderInfo order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        if ("PAID".equals(order.getPayStatus())) {
            return OrderDTO.fromEntity(order);
        }
        order.setPayStatus("PAID");
        order.setPayTime(LocalDateTime.now());
        onOrderPaidSetInitialFulfillmentStatus(order);
        order = orderRepository.save(order);
        if ("PRODUCT".equals(order.getOrderType())) {
            if (order.getProductId() != null) {
                order.setProduct(productRepository.findById(order.getProductId()).orElse(null));
            }
        } else if (order.getServiceId() != null) {
            order.setService(serviceRepository.findById(order.getServiceId()).orElse(null));
        }
        notificationService.create(userId, "支付成功", "订单 " + order.getOrderNo() + " 已支付成功。", "ORDER", order.getId());
        return OrderDTO.fromEntity(order);
    }

    /** 管理端/商家端：分页订单列表（支持状态、关键词、订单类型、配送方式筛选） */
    @Transactional(readOnly = true)
    public Page<OrderDTO> listAll(int page, int size, String status, String keyword, String orderType, String deliveryType) {
        Pageable pageable = PageRequest.of(page, size);
        String kw = StringUtils.hasText(keyword) ? keyword.trim() : null;
        String ot = StringUtils.hasText(orderType) ? orderType.trim().toUpperCase() : null;
        String dt = StringUtils.hasText(deliveryType) ? deliveryType.trim().toUpperCase() : null;

        Set<Long> userIds = new HashSet<>();
        Set<Long> serviceIds = new HashSet<>();
        Set<Long> productIds = new HashSet<>();
        if (kw != null) {
            userRepository
                    .findByUsernameContainingIgnoreCaseOrRealNameContainingIgnoreCaseOrPhoneContaining(kw, kw, kw)
                    .forEach(u -> userIds.add(u.getId()));
            serviceRepository.findByNameContainingIgnoreCase(kw).forEach(s -> serviceIds.add(s.getId()));
            productRepository.findByNameContainingIgnoreCase(kw).forEach(p -> productIds.add(p.getId()));
        }

        Specification<OrderInfo> spec = (root, query, cb) -> {
            List<javax.persistence.criteria.Predicate> predicates = new java.util.ArrayList<>();
            if (StringUtils.hasText(status)) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (ot != null) {
                predicates.add(cb.equal(root.get("orderType"), ot));
            }
            if (dt != null) {
                predicates.add(cb.equal(root.get("deliveryType"), dt));
            }
            if (kw != null) {
                List<javax.persistence.criteria.Predicate> kwOr = new java.util.ArrayList<>();
                kwOr.add(cb.like(root.get("orderNo"), "%" + kw + "%"));
                if (!userIds.isEmpty()) kwOr.add(root.get("userId").in(userIds));
                if (!serviceIds.isEmpty()) kwOr.add(root.get("serviceId").in(serviceIds));
                if (!productIds.isEmpty()) kwOr.add(root.get("productId").in(productIds));
                predicates.add(cb.or(kwOr.toArray(new javax.persistence.criteria.Predicate[0])));
            }
            query.orderBy(cb.desc(root.get("createdAt")));
            return cb.and(predicates.toArray(new javax.persistence.criteria.Predicate[0]));
        };

        Page<OrderInfo> orderPage = orderRepository.findAll(spec, pageable);
        return orderPage.map(o -> {
            OrderDTO dto = OrderDTO.fromEntity(o);
            userRepository.findById(o.getUserId()).ifPresent(u -> {
                dto.setUserName(u.getRealName() != null ? u.getRealName() : u.getUsername());
                dto.setUserPhone(u.getPhone());
            });
            if (o.getStoreId() != null) {
                storeRepository.findById(o.getStoreId()).ifPresent(s -> dto.setStoreName(s.getName()));
            }
            // 避免直接访问 o.getProduct()/o.getService() 的 LAZY 代理对象，导致 LazyInitializationException
            if ("PRODUCT".equals(o.getOrderType())) {
                if (o.getProductId() != null) {
                    MallProduct p = productRepository.findById(o.getProductId()).orElse(null);
                    dto.setProductName(p != null ? p.getName() : null);
                    dto.setProductImage(p != null ? p.getImage() : null);
                }
            } else {
                if (o.getServiceId() != null) {
                    DryService s = serviceRepository.findById(o.getServiceId()).orElse(null);
                    dto.setServiceName(s != null ? s.getName() : null);
                    dto.setServiceImage(s != null ? s.getImage() : null);
                }
            }
            return dto;
        });
    }

    /**
     * 支付成功后：从未支付 PENDING 进入履约首状态（仅当仍为 PENDING）
     */
    public void onOrderPaidSetInitialFulfillmentStatus(OrderInfo order) {
        if (!"PENDING".equals(order.getStatus())) {
            return;
        }
        if ("PRODUCT".equals(order.getOrderType())) {
            order.setStatus("AWAIT_SHIP");
        } else if ("IN_STORE".equals(order.getDeliveryType())) {
            order.setStatus("AWAIT_DROP");
        } else {
            order.setStatus("AWAIT_PICKUP");
        }
    }

    /**
     * 管理端：仅允许按顺序推进到下一状态，禁止跳步或任意修改
     */
    @Transactional
    public OrderDTO advanceOrderStatus(Long orderId) {
        OrderInfo order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!"PAID".equals(order.getPayStatus())) {
            throw new RuntimeException("订单未支付，无法推进履约状态");
        }
        if ("CANCELLED".equals(order.getStatus())) {
            throw new RuntimeException("已取消订单不可操作");
        }
        String next = computeNextFulfillmentStatus(order);
        if (next == null) {
            throw new RuntimeException("当前已是最终状态，无法继续推进");
        }
        order.setStatus(next);
        order = orderRepository.save(order);
        if ("PRODUCT".equals(order.getOrderType())) {
            if (order.getProductId() != null) {
                order.setProduct(productRepository.findById(order.getProductId()).orElse(null));
            }
        } else if (order.getServiceId() != null) {
            order.setService(serviceRepository.findById(order.getServiceId()).orElse(null));
        }
        return OrderDTO.fromEntity(order);
    }

    private String computeNextFulfillmentStatus(OrderInfo o) {
        String s = o.getStatus();
        if (s == null) return null;

        if ("PRODUCT".equals(o.getOrderType())) {
            switch (s) {
                case "AWAIT_SHIP": return "SHIPPING";
                case "SHIPPING": return "COMPLETED";
                case "PENDING": return null;
                default: return null;
            }
        }

        boolean inStore = "IN_STORE".equals(o.getDeliveryType());
        if (inStore) {
            switch (s) {
                case "AWAIT_DROP": return "RECEIVED";
                case "RECEIVED": return "WASHING";
                case "WASHING": return "READY_PICKUP";
                case "READY_PICKUP": return "COMPLETED";
                case "PENDING": return null;
                default: return null;
            }
        }

        switch (s) {
            case "PICKUP": return "PICKED";
            case "AWAIT_PICKUP": return "PICKED";
            case "PICKED": return "WASHING";
            case "WASHING": return "READY_RETURN";
            case "READY": return "RETURNING";
            case "READY_RETURN": return "RETURNING";
            case "DELIVERING": return "COMPLETED";
            case "RETURNING": return "COMPLETED";
            case "DELIVERED": return "COMPLETED";
            case "PENDING": return null;
            default: return null;
        }
    }

    @Transactional
    public OrderDTO updateStatus(Long orderId, String status) {
        OrderInfo order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        String next = computeNextFulfillmentStatus(order);
        if (next == null || !next.equals(status)) {
            throw new RuntimeException("状态须按顺序推进，请使用「推进到下一步」且不可跳步");
        }
        order.setStatus(status);
        order = orderRepository.save(order);
        if ("PRODUCT".equals(order.getOrderType())) {
            if (order.getProductId() != null) {
                order.setProduct(productRepository.findById(order.getProductId()).orElse(null));
            }
        } else if (order.getServiceId() != null) {
            order.setService(serviceRepository.findById(order.getServiceId()).orElse(null));
        }
        return OrderDTO.fromEntity(order);
    }

    @Transactional
    public OrderDTO cancel(Long userId, Long orderId) {
        OrderInfo order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        if ("PAID".equals(order.getPayStatus())) {
            throw new RuntimeException("已支付的订单无法取消");
        }
        order.setStatus("CANCELLED");
        order = orderRepository.save(order);
        if ("PRODUCT".equals(order.getOrderType())) {
            if (order.getProductId() != null) {
                order.setProduct(productRepository.findById(order.getProductId()).orElse(null));
            }
        } else if (order.getServiceId() != null) {
            order.setService(serviceRepository.findById(order.getServiceId()).orElse(null));
        }
        notificationService.create(userId, "订单取消", "订单 " + order.getOrderNo() + " 已取消。", "ORDER", order.getId());
        return OrderDTO.fromEntity(order);
    }
}
