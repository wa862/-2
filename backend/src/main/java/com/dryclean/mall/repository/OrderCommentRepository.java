package com.dryclean.mall.repository;

import com.dryclean.mall.entity.OrderComment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderCommentRepository extends JpaRepository<OrderComment, Long> {

    List<OrderComment> findAllByOrderByCreatedAtDesc();

    List<OrderComment> findByTargetTypeAndTargetIdOrderByCreatedAtDesc(String targetType, Long targetId);

    boolean existsByOrderIdAndUserId(Long orderId, Long userId);
}
