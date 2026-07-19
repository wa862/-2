package com.dryclean.mall.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/upload")
@RequiredArgsConstructor
public class UploadController {

    private static final Path UPLOAD_ROOT = Paths.get(System.getProperty("user.dir"), "uploads");
    private static final Path PRODUCT_ROOT = UPLOAD_ROOT.resolve("product");
    private static final Path SERVICE_ROOT = UPLOAD_ROOT.resolve("service");

    private static final long MAX_SIZE = 2 * 1024 * 1024; // 2MB
    private static final List<String> ALLOWED_TYPES = List.of("image/jpeg", "image/png", "image/gif");

    @PostMapping("/product-image")
    public ResponseEntity<Map<String, String>> uploadProductImage(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            String contentType = file.getContentType();
            if (contentType == null || !ALLOWED_TYPES.contains(contentType.toLowerCase())) {
                Map<String, String> err = new HashMap<>();
                err.put("message", "只支持 JPG/PNG/GIF 格式");
                return ResponseEntity.badRequest().body(err);
            }
            if (file.getSize() > MAX_SIZE) {
                Map<String, String> err = new HashMap<>();
                err.put("message", "图片大小不能超过 2MB");
                return ResponseEntity.badRequest().body(err);
            }
            if (!Files.exists(PRODUCT_ROOT)) {
                Files.createDirectories(PRODUCT_ROOT);
            }
            String original = StringUtils.cleanPath(file.getOriginalFilename());
            String ext = "";
            int idx = original.lastIndexOf('.');
            if (idx >= 0) {
                ext = original.substring(idx);
            }
            String filename = UUID.randomUUID().toString().replace("-", "") + ext;
            Path target = PRODUCT_ROOT.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            // 注意：项目配置了 context-path=/api，静态资源实际访问路径为 /api/uploads/**
            String url = "/api/uploads/product/" + filename;
            Map<String, String> body = new HashMap<>();
            body.put("url", url);
            return ResponseEntity.ok(body);
        } catch (IOException e) {
            Map<String, String> body = new HashMap<>();
            body.put("message", "图片上传失败");
            return ResponseEntity.status(500).body(body);
        }
    }

    @PostMapping("/service-image")
    public ResponseEntity<Map<String, String>> uploadServiceImage(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            String contentType = file.getContentType();
            if (contentType == null || !ALLOWED_TYPES.contains(contentType.toLowerCase())) {
                Map<String, String> err = new HashMap<>();
                err.put("message", "只支持 JPG/PNG/GIF 格式");
                return ResponseEntity.badRequest().body(err);
            }
            if (file.getSize() > MAX_SIZE) {
                Map<String, String> err = new HashMap<>();
                err.put("message", "图片大小不能超过 2MB");
                return ResponseEntity.badRequest().body(err);
            }
            if (!Files.exists(SERVICE_ROOT)) {
                Files.createDirectories(SERVICE_ROOT);
            }
            String original = StringUtils.cleanPath(file.getOriginalFilename());
            String ext = "";
            int idx = original.lastIndexOf('.');
            if (idx >= 0) {
                ext = original.substring(idx);
            }
            String filename = UUID.randomUUID().toString().replace("-", "") + ext;
            Path target = SERVICE_ROOT.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            // 注意：项目配置了 context-path=/api，静态资源实际访问路径为 /api/uploads/**
            String url = "/api/uploads/service/" + filename;
            Map<String, String> body = new HashMap<>();
            body.put("url", url);
            return ResponseEntity.ok(body);
        } catch (IOException e) {
            Map<String, String> body = new HashMap<>();
            body.put("message", "图片上传失败");
            return ResponseEntity.status(500).body(body);
        }
    }
}

