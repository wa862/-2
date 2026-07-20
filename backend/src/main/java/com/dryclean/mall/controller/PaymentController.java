package com.dryclean.mall.controller;

import com.dryclean.mall.dto.BatchPaymentDTO;
import com.dryclean.mall.dto.PaymentDTO;
import com.dryclean.mall.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/order/{orderId}")
    public ResponseEntity<PaymentDTO> createPayment(Authentication auth, @PathVariable Long orderId) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(paymentService.createPayment(userId, orderId));
    }

    @PostMapping("/orders")
    public ResponseEntity<BatchPaymentDTO> createPayments(Authentication auth,
                                                         @RequestBody java.util.Map<String, java.util.List<Long>> body) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        java.util.List<Long> orderIds = body != null ? body.get("orderIds") : null;
        return ResponseEntity.ok(paymentService.createPayments(userId, orderIds));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentDTO> getPayment(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(paymentService.getPayment(userId, id));
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<PaymentDTO> confirmPayment(Authentication auth, @PathVariable Long id,
                                                     @RequestBody(required = false) java.util.Map<String, String> body) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        String payMethod = body != null && body.containsKey("payMethod") ? body.get("payMethod") : "SIMULATE";
        return ResponseEntity.ok(paymentService.confirmPayment(userId, id, payMethod));
    }

    @PostMapping("/batch/confirm")
    public ResponseEntity<BatchPaymentDTO> confirmPayments(Authentication auth,
                                                          @RequestBody(required = false) java.util.Map<String, Object> body) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        String payMethod = body != null && body.get("payMethod") != null ? String.valueOf(body.get("payMethod")) : "SIMULATE";
        java.util.List<Long> paymentIds = new java.util.ArrayList<>();
        Object raw = body != null ? body.get("paymentIds") : null;
        if (raw instanceof java.util.List<?>) {
            for (Object item : (java.util.List<?>) raw) {
                if (item != null) paymentIds.add(Long.valueOf(String.valueOf(item)));
            }
        }
        return ResponseEntity.ok(paymentService.confirmPayments(userId, paymentIds, payMethod));
    }
}
