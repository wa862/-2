package com.dryclean.mall.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception e) {
        log.error("Request error", e);
        String message = e.getMessage();
        if (message != null && (message.contains("cart_item") || message.contains("doesn't exist") || message.contains("Unknown column") || message.contains("Table"))) {
            message = "数据库表或字段未就绪，请先执行 database 目录下的 SQL 脚本（full_rebuild.sql 或 init_missing_tables.sql）";
        } else if (message == null || message.isEmpty()) {
            message = "服务器内部错误";
        }
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("message", message));
    }
}
