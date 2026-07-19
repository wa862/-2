package com.dryclean.mall.controller;

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
}
