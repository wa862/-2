package com.dryclean.mall.controller;

import com.dryclean.mall.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class CaptchaImageController {

    private final AuthService authService;

    /**
     * 获取图片验证码，结构：{ captchaEnabled, img, uuid }
     */
    @GetMapping("/captchaImage")
    public ResponseEntity<Map<String, Object>> captchaImage() {
        return ResponseEntity.ok(authService.captchaImage());
    }
}

