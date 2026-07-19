package com.dryclean.mall.dto;

import lombok.Data;

@Data
public class ProfileUpdateRequest {
    private String username;
    private String realName;
    /** 头像图片 URL */
    private String avatar;
    /** 修改密码时必填：当前密码，用于验证 */
    private String currentPassword;
    private String newPassword;
}
