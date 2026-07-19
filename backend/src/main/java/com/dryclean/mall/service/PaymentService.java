package com.dryclean.mall.service;

import com.dryclean.mall.dto.PaymentDTO;
import com.dryclean.mall.entity.OrderInfo;
import com.dryclean.mall.entity.PaymentRecord;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.PaymentRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRecordRepository paymentRepository;
    private final OrderInfoRepository orderRepository;
    private final NotificationService notificationService;
    private final OrderService orderService;

    @Transactional
    public PaymentDTO createPayment(Long userId, Long orderId) {
        OrderInfo order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        if ("PAID".equals(order.getPayStatus())) {
            throw new RuntimeException("订单已支付");
        }
        List<PaymentRecord> pending = paymentRepository.findByOrderIdOrderByCreatedAtDesc(orderId);
        if (!pending.isEmpty() && "PENDING".equals(pending.get(0).getStatus())) {
            return PaymentDTO.fromEntity(pending.get(0), order.getOrderNo());
        }
        PaymentRecord p = new PaymentRecord();
        p.setOrderId(orderId);
        p.setUserId(userId);
        p.setAmount(order.getTotalPrice());
        p.setStatus("PENDING");
        p.setPayMethod("SIMULATE");
        p = paymentRepository.save(p);
        return PaymentDTO.fromEntity(p, order.getOrderNo());
    }

    public PaymentDTO getPayment(Long userId, Long paymentId) {
        PaymentRecord p = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("支付单不存在"));
        if (!p.getUserId().equals(userId)) {
            throw new RuntimeException("无权查看");
        }
        String orderNo = orderRepository.findById(p.getOrderId()).map(OrderInfo::getOrderNo).orElse("");
        return PaymentDTO.fromEntity(p, orderNo);
    }

    @Transactional
    public PaymentDTO confirmPayment(Long userId, Long paymentId, String payMethod) {
        PaymentRecord p = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("支付单不存在"));
        if (!p.getUserId().equals(userId)) {
            throw new RuntimeException("无权操作");
        }
        if (!"PENDING".equals(p.getStatus())) {
            throw new RuntimeException("支付单已处理");
        }
        if (payMethod != null && !payMethod.isBlank()) {
            p.setPayMethod(payMethod);
        }
        OrderInfo order = orderRepository.findById(p.getOrderId())
                .orElseThrow(() -> new RuntimeException("订单不存在"));
        if ("PAID".equals(order.getPayStatus())) {
            p.setStatus("PAID");
            p.setPaidAt(LocalDateTime.now());
            paymentRepository.save(p);
            return PaymentDTO.fromEntity(p, order.getOrderNo());
        }
        p.setStatus("PAID");
        p.setPaidAt(LocalDateTime.now());
        paymentRepository.save(p);
        order.setPayStatus("PAID");
        order.setPayTime(LocalDateTime.now());
        orderService.onOrderPaidSetInitialFulfillmentStatus(order);
        orderRepository.save(order);
        notificationService.create(userId, "支付成功", "订单 " + order.getOrderNo() + " 已支付成功。", "ORDER", order.getId());
        return PaymentDTO.fromEntity(p, order.getOrderNo());
    }
}
