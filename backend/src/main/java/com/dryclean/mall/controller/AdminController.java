package com.dryclean.mall.controller;

import com.dryclean.mall.dto.CommentDTO;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.SysUserRepository;
import com.dryclean.mall.service.CommentService;
import com.dryclean.mall.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final OrderInfoRepository orderRepository;
    private final SysUserRepository userRepository;
    private final CommentService commentService;
    private final NotificationService notificationService;

    @GetMapping("/comment/list")
    public ResponseEntity<List<CommentDTO>> commentList() {
        return ResponseEntity.ok(commentService.list(null, null));
    }

    @PostMapping("/comment/{id}/reply")
    public ResponseEntity<CommentDTO> replyComment(@PathVariable Long id, @org.springframework.web.bind.annotation.RequestBody java.util.Map<String, String> body) {
        String reply = body != null ? body.get("reply") : null;
        return ResponseEntity.ok(commentService.reply(id, reply));
    }

    /** 管理端一键已读（避免 /notification/read-all 被误匹配为 /notification/{id} 导致 404） */
    @PostMapping("/notification/read-all")
    public ResponseEntity<Void> notificationMarkAllRead(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        notificationService.markAllRead(userId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> stats() {
        LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
        long todayOrders = orderRepository.countByCreatedAtAfter(startOfToday);
        long totalOrders = orderRepository.count();
        BigDecimal sales = orderRepository.sumTotalPrice();
        long userCount = userRepository.count();
        Map<String, Object> map = new HashMap<>();
        map.put("todayOrders", todayOrders);
        map.put("totalOrders", totalOrders);
        map.put("sales", sales != null ? sales.toString() : "0");
        map.put("userCount", userCount);
        return ResponseEntity.ok(map);
    }

    /**
     * 最近 N 天订单趋势（每日订单数 + 销售额）
     */
    @GetMapping("/stats/trend")
    public ResponseEntity<List<Map<String, Object>>> orderTrend(
            @RequestParam(value = "days", required = false, defaultValue = "7") int days) {
        if (days <= 0) days = 7;
        if (days > 60) days = 60; // 简单限制，避免一次性查太多天

        LocalDate today = LocalDate.now();
        LocalDate startDate = today.minusDays(days - 1);
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = today.plusDays(1).atStartOfDay();

        var orders = orderRepository.findByCreatedAtBetween(start, end);

        // 先按天初始化 0 值，确保没有订单的日期也会返回
        Map<LocalDate, DayAgg> aggMap = new LinkedHashMap<>();
        for (int i = 0; i < days; i++) {
            LocalDate d = startDate.plusDays(i);
            aggMap.put(d, new DayAgg());
        }

        for (var o : orders) {
            if (o.getCreatedAt() == null) continue;
            LocalDate d = o.getCreatedAt().toLocalDate();
            DayAgg agg = aggMap.get(d);
            if (agg != null) {
                agg.orderCount++;
                if (o.getTotalPrice() != null) {
                    agg.sales = agg.sales.add(o.getTotalPrice());
                }
            }
        }

        List<Map<String, Object>> list = aggMap.entrySet().stream().map(e -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("date", e.getKey().toString());
            m.put("orderCount", e.getValue().orderCount);
            m.put("sales", e.getValue().sales);
            return m;
        }).toList();

        return ResponseEntity.ok(list);
    }

    private static class DayAgg {
        long orderCount = 0;
        BigDecimal sales = BigDecimal.ZERO;
    }
}
