package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;

@Data
public class CartAddRequest {

    @NotNull(message = "类型不能为空")
    private String itemType; // PRODUCT / SERVICE

    private Long productId;
    private Long serviceId;
    /** 干洗服务规格名称（SERVICE 时可选，如：短款/长款） */
    private String serviceSpecName;

    @Min(1)
    private Integer quantity = 1;
}
