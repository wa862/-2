package com.dryclean.mall.service;

import com.dryclean.mall.dto.CommentCreateRequest;
import com.dryclean.mall.dto.CommentDTO;
import com.dryclean.mall.entity.OrderComment;
import com.dryclean.mall.repository.OrderCommentRepository;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.SysUserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommentService {

    private final OrderCommentRepository commentRepository;
    private final OrderInfoRepository orderRepository;
    private final SysUserRepository userRepository;

    @Transactional
    public CommentDTO create(Long userId, CommentCreateRequest req) {
        var order = orderRepository.findById(req.getOrderId())
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权评价该订单");
        }
        if (!"COMPLETED".equals(order.getStatus())) {
            throw new RuntimeException("仅支持对已完成订单进行评价");
        }
        if (commentRepository.existsByOrderIdAndUserId(order.getId(), userId)) {
            throw new RuntimeException("该订单已评价过");
        }
        String targetType = order.getOrderType() != null ? order.getOrderType() : "SERVICE";
        Long targetId;
        if ("PRODUCT".equals(targetType)) {
            if (order.getProductId() == null) {
                // 兼容旧数据：部分历史订单可能把商品ID错误写进了 service_id
                if (order.getServiceId() != null) {
                    log.warn("兼容旧数据：订单 {} 为 PRODUCT，但 productId 为空，将使用 serviceId={} 作为商品ID兜底",
                            order.getOrderNo(), order.getServiceId());
                    order.setProductId(order.getServiceId());
                    order.setServiceId(null);
                    order = orderRepository.save(order);
                } else {
                    throw new RuntimeException("该订单缺少商品ID，无法评价");
                }
            }
            targetId = order.getProductId();
        } else {
            if (order.getServiceId() == null) {
                throw new RuntimeException("该订单缺少服务ID，无法评价");
            }
            targetId = order.getServiceId();
            targetType = "SERVICE";
        }
        OrderComment c = new OrderComment();
        c.setOrderId(order.getId());
        c.setOrderNo(order.getOrderNo());
        c.setUserId(userId);
        c.setTargetType(targetType);
        c.setTargetId(targetId);
        c.setContent(req.getContent() != null ? req.getContent().trim() : null);
        c.setScore(req.getScore() != null ? req.getScore() : 5);
        c = commentRepository.save(c);
        CommentDTO dto = CommentDTO.fromEntity(c);
        dto.setOrderNo(order.getOrderNo());
        userRepository.findById(userId).ifPresent(u -> dto.setUsername(u.getRealName() != null ? u.getRealName() : u.getUsername()));
        return dto;
    }

    public boolean hasCommented(Long userId, Long orderId) {
        return commentRepository.existsByOrderIdAndUserId(orderId, userId);
    }

    @Transactional
    public void delete(Long id) {
        commentRepository.deleteById(id);
    }

    @Transactional
    public CommentDTO reply(Long id, String reply) {
        OrderComment c = commentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("评论不存在"));
        String r = reply != null ? reply.trim() : "";
        if (r.isEmpty()) {
            throw new RuntimeException("回复内容不能为空");
        }
        c.setReply(r);
        c.setReplyTime(LocalDateTime.now());
        c = commentRepository.save(c);
        CommentDTO dto = CommentDTO.fromEntity(c);
        // 补充用户名
        userRepository.findById(c.getUserId())
                .ifPresent(u -> dto.setUsername(u.getRealName() != null ? u.getRealName() : u.getUsername()));
        return dto;
    }

    public List<CommentDTO> list(String targetType, Long targetId) {
        try {
            List<OrderComment> rows;
            if (targetId != null) {
                String t = (targetType != null ? targetType.trim().toUpperCase() : "SERVICE");
                if (!"PRODUCT".equals(t)) t = "SERVICE";
                rows = commentRepository.findByTargetTypeAndTargetIdOrderByCreatedAtDesc(t, targetId);
            } else {
                rows = commentRepository.findAllByOrderByCreatedAtDesc();
            }
            return rows
                    .stream()
                    .map(c -> {
                        CommentDTO dto = CommentDTO.fromEntity(c);
                        // 若实体中没有带出订单编号，则从订单表补一次
                        if (dto.getOrderNo() == null || dto.getOrderNo().isEmpty()) {
                            orderRepository.findById(c.getOrderId())
                                    .ifPresent(o -> dto.setOrderNo(o.getOrderNo()));
                        }
                        userRepository.findById(c.getUserId())
                                .ifPresent(u -> dto.setUsername(
                                        u.getRealName() != null ? u.getRealName() : u.getUsername()));
                        return dto;
                    })
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("评论列表查询失败", e);
            return Collections.emptyList();
        }
    }
}
