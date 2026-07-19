package com.dryclean.mall.dto;

import lombok.Data;

@Data
public class AuthResponse {

    private String token;
    private Long expireAt;
    private UserDTO user;

    @Data
    public static class UserDTO {
        private Long id;
        private String username;
        private String realName;
        private String phone;
        private String avatar;
        private String role;
    }
}
