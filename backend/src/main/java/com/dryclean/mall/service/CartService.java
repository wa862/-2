package com.dryclean.mall.service;

import com.dryclean.mall.dto.CartAddRequest;
import com.dryclean.mall.dto.CartItemDTO;
import com.dryclean.mall.entity.CartItem;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.repository.CartItemRepository;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.MallProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final MallProductRepository productRepository;
    private final DryServiceRepository serviceRepository;

    @Transactional
    public CartItemDTO add(Long userId, CartAddRequest req) {
        try {
            return addInternal(userId, req);
        } catch (Exception e) {
            log.warn("购物车加购失败: {}", e.getMessage());
            throw new RuntimeException("购物车不可用，请先执行 database 目录下 add_missing_columns.sql 或 full_rebuild.sql 创建 cart_item 表后重启后端");
        }
    }

    private CartItemDTO addInternal(Long userId, CartAddRequest req) {
        String type = req.getItemType() != null ? req.getItemType().toUpperCase() : "";
        if ("PRODUCT".equals(type) && req.getProductId() != null) {
            Optional<MallProduct> product = productRepository.findById(req.getProductId());
            if (product.isEmpty()) return null;
            Optional<CartItem> existing = cartItemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                    .filter(c -> c.getProductId() != null && c.getProductId().equals(req.getProductId()))
                    .findFirst();
            if (existing.isPresent()) {
                CartItem c = existing.get();
                c.setQuantity(c.getQuantity() + (req.getQuantity() != null ? req.getQuantity() : 1));
                cartItemRepository.save(c);
                return toDTO(c);
            }
            CartItem item = new CartItem();
            item.setUserId(userId);
            item.setItemType("PRODUCT");
            item.setProductId(req.getProductId());
            item.setQuantity(req.getQuantity() != null ? req.getQuantity() : 1);
            cartItemRepository.save(item);
            return toDTO(item);
        }
        if ("SERVICE".equals(type) && req.getServiceId() != null) {
            Optional<DryService> service = serviceRepository.findById(req.getServiceId());
            if (service.isEmpty()) return null;
            final String specNameFinal = normalizeSpecName(req.getServiceSpecName());
            Optional<CartItem> existing = cartItemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                    .filter(c -> c.getServiceId() != null && c.getServiceId().equals(req.getServiceId()))
                    .filter(c -> {
                        String ex = normalizeSpecName(c.getServiceSpecName());
                        if (specNameFinal == null && ex == null) return true;
                        return specNameFinal != null && specNameFinal.equals(ex);
                    })
                    .findFirst();
            if (existing.isPresent()) {
                CartItem c = existing.get();
                c.setQuantity(c.getQuantity() + (req.getQuantity() != null ? req.getQuantity() : 1));
                cartItemRepository.save(c);
                return toDTO(c);
            }
            CartItem item = new CartItem();
            item.setUserId(userId);
            item.setItemType("SERVICE");
            item.setServiceId(req.getServiceId());
            item.setServiceSpecName(specNameFinal);
            item.setQuantity(req.getQuantity() != null ? req.getQuantity() : 1);
            cartItemRepository.save(item);
            return toDTO(item);
        }
        return null;
    }

    public List<CartItemDTO> list(Long userId) {
        try {
            List<CartItemDTO> result = new ArrayList<>();
            for (CartItem c : cartItemRepository.findByUserIdOrderByCreatedAtDesc(userId)) {
                result.add(toDTO(c));
            }
            return result;
        } catch (Exception e) {
            log.warn("购物车列表查询失败: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    @Transactional
    public CartItemDTO updateQuantity(Long userId, Long id, Integer quantity) {
        Optional<CartItem> opt = cartItemRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getUserId().equals(userId)) return null;
        CartItem c = opt.get();
        if (quantity != null && quantity >= 1) c.setQuantity(quantity);
        cartItemRepository.save(c);
        return toDTO(c);
    }

    @Transactional
    public CartItemDTO updateServiceSpec(Long userId, Long id, String serviceSpecName, Integer quantity) {
        Optional<CartItem> opt = cartItemRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getUserId().equals(userId)) return null;
        CartItem c = opt.get();
        if (!"SERVICE".equals(c.getItemType()) || c.getServiceId() == null) return null;
        c.setServiceSpecName(normalizeSpecName(serviceSpecName));
        if (quantity != null && quantity >= 1) c.setQuantity(quantity);
        cartItemRepository.save(c);
        return toDTO(c);
    }

    @Transactional
    public void remove(Long userId, Long id) {
        cartItemRepository.findById(id).ifPresent(c -> {
            if (c.getUserId().equals(userId)) cartItemRepository.delete(c);
        });
    }

    private CartItemDTO toDTO(CartItem c) {
        CartItemDTO dto = new CartItemDTO();
        dto.setId(c.getId());
        dto.setItemType(c.getItemType());
        dto.setProductId(c.getProductId());
        dto.setServiceId(c.getServiceId());
        dto.setServiceSpecName(c.getServiceSpecName());
        dto.setQuantity(c.getQuantity());
        if ("PRODUCT".equals(c.getItemType()) && c.getProductId() != null) {
            productRepository.findById(c.getProductId()).ifPresent(p -> {
                dto.setName(p.getName());
                dto.setPrice(p.getPrice());
                dto.setImage(p.getImage());
                dto.setUnit("件");
            });
        } else if ("SERVICE".equals(c.getItemType()) && c.getServiceId() != null) {
            serviceRepository.findById(c.getServiceId()).ifPresent(s -> {
                String specName = normalizeSpecName(c.getServiceSpecName());
                dto.setName(specName != null ? (s.getName() + "（" + specName + "）") : s.getName());
                dto.setPrice(resolveServiceUnitPrice(s, specName));
                dto.setImage(s.getImage());
                dto.setUnit("件");
            });
        }
        return dto;
    }

    private String normalizeSpecName(String v) {
        if (v == null) return null;
        String s = v.trim();
        return s.isEmpty() ? null : s;
    }

    private java.math.BigDecimal resolveServiceUnitPrice(DryService service, String specName) {
        java.math.BigDecimal base = service.getPrice() != null ? service.getPrice() : java.math.BigDecimal.ZERO;
        if (specName == null || specName.isBlank() || service.getSpecs() == null || service.getSpecs().isBlank()) {
            return base;
        }
        java.math.BigDecimal p = parseSpecPrice(service.getSpecs(), specName);
        return p != null ? p : base;
    }

    private java.math.BigDecimal parseSpecPrice(String specs, String specName) {
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
                java.math.BigDecimal price = new java.math.BigDecimal(num);
                if (price.compareTo(java.math.BigDecimal.ZERO) > 0) return price;
            } catch (Exception ignored) { }
        }
        return null;
    }
}
