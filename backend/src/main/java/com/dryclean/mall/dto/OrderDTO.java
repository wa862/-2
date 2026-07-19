package com.dryclean.mall.dto;

import com.dryclean.mall.entity.OrderInfo;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class OrderDTO {

    private Long id;
    private String orderNo;
    private Long userId;
    private Long serviceId;
    private String serviceName;
    private String serviceImage;
    private Long productId;
    private String productName;
    private String productImage;
    private Integer quantity;
    private BigDecimal totalPrice;
    private String status;
    private String payStatus;
    private String orderType;
    private LocalDateTime payTime;
    private String remark;
    private Long addressId;
    private String deliveryType;
    private Long storeId;
    private String storeName;
    /** 取送地址摘要（省市区+详细地址，用于订单详情展示） */
    private String addressLine;
    private String userName;
    private String userPhone;
    private LocalDate pickupDate;
    private Integer urgent;
    private LocalDateTime createdAt;
    /** 是否已评价（仅用户端我的订单列表使用） */
    private Boolean hasComment;

    public static OrderDTO fromEntity(OrderInfo o) {
        OrderDTO dto = new OrderDTO();
        dto.setId(o.getId());
        dto.setOrderNo(o.getOrderNo());
        dto.setUserId(o.getUserId());
        dto.setServiceId(o.getServiceId());
        dto.setProductId(o.getProductId());
        dto.setQuantity(o.getQuantity());
        dto.setTotalPrice(o.getTotalPrice());
        dto.setStatus(o.getStatus());
        dto.setPayStatus(o.getPayStatus() != null ? o.getPayStatus() : "UNPAID");
        dto.setPayTime(o.getPayTime());
        dto.setRemark(o.getRemark());
        dto.setAddressId(o.getAddressId());
        dto.setDeliveryType(o.getDeliveryType());
        dto.setStoreId(o.getStoreId());
        dto.setOrderType(o.getOrderType());
        dto.setPickupDate(o.getPickupDate());
        dto.setUrgent(o.getUrgent());
        dto.setCreatedAt(o.getCreatedAt());
        return dto;
    }

    public void setStoreName(String storeName) { this.storeName = storeName; }
    public void setUserName(String userName) { this.userName = userName; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }
}
