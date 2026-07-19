package com.dryclean.mall.controller;

import com.dryclean.mall.dto.NotificationDTO;
import com.dryclean.mall.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notification")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/list")
    public ResponseEntity<List<NotificationDTO>> list(Authentication auth,
                                                      @RequestParam(defaultValue = "0") int page,
                                                      @RequestParam(defaultValue = "20") int size) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.ok(List.of());
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(notificationService.listByUser(userId, page, size));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> unreadCount(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.ok(Map.of("count", 0L));
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(Map.of("count", notificationService.unreadCount(userId)));
    }

    /** 须在 /{id}/read 之前定义，否则 "read-all" 会被当作 id 匹配 */
    @PostMapping("/read-all")
    public ResponseEntity<Void> markAllRead(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        notificationService.markAllRead(userId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<Void> markRead(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        notificationService.markRead(userId, id);
        return ResponseEntity.ok().build();
    }
}
