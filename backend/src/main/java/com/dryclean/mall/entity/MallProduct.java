package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "mall_product")
public class MallProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 32)
    private String category = "洗衣液";

    @Column(length = 50)
    private String brand;

    @Column(length = 50)
    private String manufacturer;

    @Column(name = "production_date")
    private LocalDate productionDate;

    @Column(length = 50)
    private String specification;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(length = 500)
    private String description;

    @Column(length = 500)
    private String image;

    @Column(nullable = false)
    private Integer stock = 0;

    @Column(nullable = false)
    private Integer sales = 0;

    @Column(nullable = false)
    private Integer status = 1;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

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
