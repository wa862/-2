package com.dryclean.mall.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CartItemDTO {

    private Long id;
    private String itemType; // PRODUCT / SERVICE
    private Long productId;
    private Long serviceId;
    private String serviceSpecName;
    private String name;
    private BigDecimal price;
    private String image;
    private Integer quantity;
    private String unit; // 件/瓶 等
}
