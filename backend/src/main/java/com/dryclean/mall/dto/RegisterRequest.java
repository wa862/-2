package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class RegisterRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, max = 32)
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 32)
    private String password;

    private String realName;
    private String phone;

    /** 新版验证码字段：uuid + code */
    @NotBlank(message = "验证码不能为空")
    private String uuid;

    @NotBlank(message = "验证码不能为空")
    private String code;

    /** 旧字段兼容（可选） */
    private String captchaKey;
    private String captchaCode;
}
