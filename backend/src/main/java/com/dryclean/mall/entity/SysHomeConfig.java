package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;

/**
 * 首页模块动态配置（热门干洗服务、推荐商品）。
 * 仅保留一行记录（id=1），存储 JSON 数组形式的 ID 列表。
 */
@Data
@Entity
@Table(name = "sys_home_config")
public class SysHomeConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** 首页「热门干洗服务」展示的服务 ID 列表，JSON 数组如 "[1,2,3,4]" */
    @Column(name = "hot_service_ids", columnDefinition = "TEXT")
    private String hotServiceIds;

    /** 首页「推荐商品」展示的商品 ID 列表，JSON 数组如 "[1,2,3,4]" */
    @Column(name = "recommend_product_ids", columnDefinition = "TEXT")
    private String recommendProductIds;
}
