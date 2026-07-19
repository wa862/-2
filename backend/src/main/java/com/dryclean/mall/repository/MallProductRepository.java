package com.dryclean.mall.repository;

import com.dryclean.mall.entity.MallProduct;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MallProductRepository extends JpaRepository<MallProduct, Long> {

    List<MallProduct> findByStatusOrderBySortOrderAsc(Integer status);

    List<MallProduct> findByNameContainingIgnoreCase(String name);
}
