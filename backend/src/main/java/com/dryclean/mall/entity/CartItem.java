package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "cart_item")
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "item_type", nullable = false, length = 20)
    private String itemType; // PRODUCT / SERVICE

    @Column(name = "product_id")
    private Long productId;

    @Column(name = "service_id")
    private Long serviceId;

    @Column(name = "service_spec_name", length = 50)
    private String serviceSpecName;

    @Column(nullable = false)
    private Integer quantity = 1;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}
