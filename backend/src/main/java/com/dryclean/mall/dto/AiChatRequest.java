package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class AiChatRequest {

    @NotBlank(message = "问题不能为空")
    private String question;

    private Long userId;
}
