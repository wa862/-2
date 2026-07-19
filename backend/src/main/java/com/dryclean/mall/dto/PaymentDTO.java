package com.dryclean.mall.dto;

import com.dryclean.mall.entity.PaymentRecord;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PaymentDTO {

    private Long id;
    private Long orderId;
    private Long userId;
    private BigDecimal amount;
    private String status;
    private String payMethod;
    private LocalDateTime createdAt;
    private LocalDateTime paidAt;
    private String orderNo;

    public static PaymentDTO fromEntity(PaymentRecord p, String orderNo) {
        PaymentDTO dto = new PaymentDTO();
        dto.setId(p.getId());
        dto.setOrderId(p.getOrderId());
        dto.setUserId(p.getUserId());
        dto.setAmount(p.getAmount());
        dto.setStatus(p.getStatus());
        dto.setPayMethod(p.getPayMethod());
        dto.setCreatedAt(p.getCreatedAt());
        dto.setPaidAt(p.getPaidAt());
        dto.setOrderNo(orderNo);
        return dto;
    }
}
