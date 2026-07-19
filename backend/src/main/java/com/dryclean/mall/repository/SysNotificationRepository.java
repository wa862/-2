package com.dryclean.mall.repository;

import com.dryclean.mall.entity.SysNotification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SysNotificationRepository extends JpaRepository<SysNotification, Long> {

    Page<SysNotification> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    long countByUserIdAndIsRead(Long userId, Integer isRead);

    List<SysNotification> findByUserIdAndIsRead(Long userId, Integer isRead);
}
