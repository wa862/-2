package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "order_comment")
public class OrderComment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false)
    private Long orderId;

    @Column(name = "order_no", length = 32)
    private String orderNo;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    /**
     * 评价对象类型：SERVICE / PRODUCT
     */
    @Column(name = "target_type", length = 20, nullable = false)
    private String targetType = "SERVICE";

    /**
     * 评价对象ID：干洗服务ID或商品ID
     */
    @Column(name = "target_id", nullable = false)
    private Long targetId;

    @Column(length = 500)
    private String content;

    @Column(length = 500)
    private String reply;

    @Column(name = "reply_time")
    private LocalDateTime replyTime;

    @Column(nullable = false)
    private Integer score = 5;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}

