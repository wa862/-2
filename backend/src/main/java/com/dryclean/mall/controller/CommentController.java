package com.dryclean.mall.controller;

import com.dryclean.mall.dto.CommentCreateRequest;
import com.dryclean.mall.dto.CommentDTO;
import com.dryclean.mall.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/comment")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @GetMapping("/list")
    public ResponseEntity<List<CommentDTO>> list(
            @RequestParam(required = false) String targetType,
            @RequestParam(required = false) Long targetId
    ) {
        return ResponseEntity.ok(commentService.list(targetType, targetId));
    }

    @PostMapping("/create")
    public ResponseEntity<CommentDTO> create(Authentication auth, @Valid @RequestBody CommentCreateRequest req) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(commentService.create(userId, req));
    }

    @GetMapping("/has-commented")
    public ResponseEntity<Boolean> hasCommented(Authentication auth, @RequestParam Long orderId) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.ok(false);
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(commentService.hasCommented(userId, orderId));
    }
}
