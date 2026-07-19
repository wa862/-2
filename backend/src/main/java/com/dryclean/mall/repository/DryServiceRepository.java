package com.dryclean.mall.repository;

import com.dryclean.mall.entity.DryService;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DryServiceRepository extends JpaRepository<DryService, Long> {

    List<DryService> findByStatusOrderBySortOrderAsc(Integer status);

    List<DryService> findByNameContainingIgnoreCase(String name);
}
