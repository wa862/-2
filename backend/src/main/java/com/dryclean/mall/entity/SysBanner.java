package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "sys_banner")
public class SysBanner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 255)
    private String image;

    @Column(length = 255)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(length = 255)
    private String link;

    @Column(name = "sort_order")
    private Integer sortOrder;

    @Column(name = "enabled")
    private Boolean enabled;
}

