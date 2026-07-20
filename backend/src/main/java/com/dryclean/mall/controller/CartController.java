package com.dryclean.mall.controller;

import com.dryclean.mall.dto.CartAddRequest;
import com.dryclean.mall.dto.CartItemDTO;
import com.dryclean.mall.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @PostMapping("/add")
    public ResponseEntity<CartItemDTO> add(Authentication auth, @Valid @RequestBody CartAddRequest req) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        CartItemDTO dto = cartService.add(userId, req);
        return dto != null ? ResponseEntity.ok(dto) : ResponseEntity.badRequest().build();
    }

    @GetMapping("/list")
    public ResponseEntity<List<CartItemDTO>> list(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.ok(List.of());
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(cartService.list(userId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CartItemDTO> updateQuantity(Authentication auth, @PathVariable Long id, @RequestParam Integer quantity) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        CartItemDTO dto = cartService.updateQuantity(userId, id, quantity);
        return dto != null ? ResponseEntity.ok(dto) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}/service-spec")
    public ResponseEntity<CartItemDTO> updateServiceSpec(
            Authentication auth,
            @PathVariable Long id,
            @RequestParam(required = false) String serviceSpecName,
            @RequestParam(required = false) Integer quantity) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        CartItemDTO dto = cartService.updateServiceSpec(userId, id, serviceSpecName, quantity);
        return dto != null ? ResponseEntity.ok(dto) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remove(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        cartService.remove(userId, id);
        return ResponseEntity.ok().build();
    }
}
