package com.dryclean.mall.repository;

import com.dryclean.mall.entity.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserAddressRepository extends JpaRepository<UserAddress, Long> {

    @Query("SELECT a FROM UserAddress a WHERE a.userId = :userId ORDER BY a.isDefault DESC, a.createdAt DESC")
    List<UserAddress> findByUserIdOrderByIsDefaultDescCreatedAtDesc(@Param("userId") Long userId);
}
