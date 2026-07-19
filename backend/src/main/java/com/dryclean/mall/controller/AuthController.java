package com.dryclean.mall.controller;

import com.dryclean.mall.dto.AuthResponse;
import com.dryclean.mall.dto.LoginRequest;
import com.dryclean.mall.dto.ProfileUpdateRequest;
import com.dryclean.mall.dto.RegisterRequest;
import com.dryclean.mall.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @GetMapping("/me")
    public ResponseEntity<AuthResponse.UserDTO> me(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof Long)) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(authService.getCurrentUser(userId));
    }

    @PutMapping("/profile")
    public ResponseEntity<AuthResponse.UserDTO> updateProfile(Authentication auth, @RequestBody ProfileUpdateRequest req) {
        if (auth == null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof Long)) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(authService.updateProfile(userId, req.getUsername(), req.getRealName(),
                req.getAvatar(), req.getCurrentPassword(), req.getNewPassword()));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.ok(authService.register(req));
    }

    @GetMapping("/captcha")
    public ResponseEntity<Map<String, String>> captcha() {
        return ResponseEntity.ok(authService.captcha());
    }
}
