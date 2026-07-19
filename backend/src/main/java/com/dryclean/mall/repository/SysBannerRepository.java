package com.dryclean.mall.repository;

import com.dryclean.mall.entity.SysBanner;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SysBannerRepository extends JpaRepository<SysBanner, Long> {

    List<SysBanner> findAllByOrderBySortOrderAscIdAsc();
}

