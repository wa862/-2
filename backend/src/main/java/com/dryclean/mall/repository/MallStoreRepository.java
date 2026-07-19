package com.dryclean.mall.repository;

import com.dryclean.mall.entity.MallStore;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MallStoreRepository extends JpaRepository<MallStore, Long> {

    List<MallStore> findByStatusOrderBySortOrderAsc(Integer status);
}
