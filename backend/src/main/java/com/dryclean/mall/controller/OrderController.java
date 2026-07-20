package com.dryclean.mall.controller;

import com.dryclean.mall.dto.OrderCreateRequest;
import com.dryclean.mall.dto.OrderDTO;
import com.dryclean.mall.dto.OrderStatusRequest;
import com.dryclean.mall.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/order")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping("/create")
    public ResponseEntity<OrderDTO> create(Authentication auth, @RequestBody OrderCreateRequest req) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(orderService.create(userId, req));
    }

    @GetMapping("/my")
    public ResponseEntity<List<OrderDTO>> myOrders(Authentication auth,
                                                  @RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "20") int size) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(orderService.listByUser(userId, page, size));
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderDTO> detail(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(orderService.detail(userId, id));
    }

    /** 管理端/商家端：分页订单列表，可选 status 筛选 */
    @GetMapping("/list")
    public ResponseEntity<Page<OrderDTO>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String orderType,
            @RequestParam(required = false) String deliveryType) {
        return ResponseEntity.ok(orderService.listAll(page, size, status, keyword, orderType, deliveryType));
    }

    @PostMapping("/{id}/pay")
    public ResponseEntity<OrderDTO> pay(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(orderService.pay(userId, id));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<OrderDTO> cancel(Authentication auth, @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(orderService.cancel(userId, id));
    }

    /** 管理端：将订单状态推进到下一步（严格顺序，不可跳步） */
    @PostMapping("/{id}/advance")
    public ResponseEntity<OrderDTO> advanceOrderStatus(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.advanceOrderStatus(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<OrderDTO> updateStatus(@PathVariable Long id, @RequestBody OrderStatusRequest req) {
        return ResponseEntity.ok(orderService.updateStatus(id, req.getStatus()));
    }
}
