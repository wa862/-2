package com.dryclean.mall.repository;

import com.dryclean.mall.entity.OrderInfo;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface OrderInfoRepository extends JpaRepository<OrderInfo, Long>, JpaSpecificationExecutor<OrderInfo> {

    List<OrderInfo> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Page<OrderInfo> findByStatusOrderByCreatedAtDesc(String status, Pageable pageable);

    @Query("SELECT o FROM OrderInfo o WHERE o.status IN :statuses ORDER BY o.createdAt DESC")
    Page<OrderInfo> findByStatusInOrderByCreatedAtDesc(@Param("statuses") List<String> statuses, Pageable pageable);

    Page<OrderInfo> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Optional<OrderInfo> findByOrderNo(String orderNo);

    long countByCreatedAtAfter(LocalDateTime after);

    /** 查询指定时间范围内的全部订单（用于统计报表） */
    List<OrderInfo> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);

    @Query("SELECT COALESCE(SUM(o.totalPrice), 0) FROM OrderInfo o")
    BigDecimal sumTotalPrice();
}
