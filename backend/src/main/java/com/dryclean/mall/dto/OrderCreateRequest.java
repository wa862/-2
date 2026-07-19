package com.dryclean.mall.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class OrderCreateRequest {

    /**
     * 订单类型：SERVICE（干洗服务）、PRODUCT（商城商品）
     */
    private String orderType;

    /** 干洗服务ID（orderType=SERVICE 时必填） */
    private Long serviceId;

    /** 商品ID（orderType=PRODUCT 时必填） */
    private Long productId;

    private Integer quantity = 1;

    private String remark;

    private Long addressId;

    private String deliveryType;

    private Long storeId;

    /** 干洗服务规格名称（与 dry_service.specs 中「名称|价格」的名称一致，如：短款、长款） */
    private String serviceSpecName;

    /** 用户期望的取衣/送达日期（最早可选日期由前端计算） */
    private LocalDate pickupDate;

    /** 是否加急 */
    private Boolean urgent;
}
