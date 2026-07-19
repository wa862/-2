package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class OrderStatusRequest {

    @NotBlank(message = "状态不能为空")
    private String status;
}
