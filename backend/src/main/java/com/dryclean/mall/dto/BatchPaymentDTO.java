package com.dryclean.mall.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class BatchPaymentDTO {
    private List<PaymentDTO> payments;
    private BigDecimal totalAmount;
    private String status;

    public static BatchPaymentDTO of(List<PaymentDTO> payments) {
        BatchPaymentDTO dto = new BatchPaymentDTO();
        dto.setPayments(payments);
        dto.setTotalAmount(payments.stream()
                .map(PaymentDTO::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        dto.setStatus(payments.stream().allMatch(p -> "PAID".equals(p.getStatus())) ? "PAID" : "PENDING");
        return dto;
    }
}
