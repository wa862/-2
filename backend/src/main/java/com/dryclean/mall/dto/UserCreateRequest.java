package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class UserCreateRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, max = 64)
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 32)
    private String password;

    @Size(max = 32)
    private String realName;

    @Size(max = 20)
    private String phone;

    @NotBlank(message = "角色不能为空")
    private String role; // USER, ADMIN
}
