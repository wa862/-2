package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "order_info")
public class OrderInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_no", nullable = false, unique = true, length = 32)
    private String orderNo;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "service_id")
    private Long serviceId;

    @Column(name = "order_type", length = 20, nullable = false)
    private String orderType = "SERVICE";

    @Column(name = "product_id")
    private Long productId;

    @Column(nullable = false)
    private Integer quantity = 1;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(nullable = false, length = 20)
    private String status = "PENDING";

    @Column(name = "pay_status", nullable = false, length = 20)
    private String payStatus = "UNPAID";

    @Column(name = "pay_time")
    private LocalDateTime payTime;

    @Column(name = "pickup_time")
    private LocalDateTime pickupTime;

    @Column(name = "washing_start_time")
    private LocalDateTime washingStartTime;

    @Column(name = "washing_end_time")
    private LocalDateTime washingEndTime;

    @Column(name = "ready_time")
    private LocalDateTime readyTime;

    @Column(name = "delivery_time")
    private LocalDateTime deliveryTime;

    @Column(length = 200)
    private String remark;

    @Column(name = "address_id")
    private Long addressId;

    @Column(name = "delivery_type", length = 20)
    private String deliveryType;

    @Column(name = "store_id")
    private Long storeId;

    @Column(name = "pickup_date")
    private LocalDate pickupDate;

    @Column(name = "urgent", nullable = false)
    private Integer urgent = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id", insertable = false, updatable = false)
    private DryService service;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", insertable = false, updatable = false)
    private MallProduct product;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (updatedAt == null) updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
