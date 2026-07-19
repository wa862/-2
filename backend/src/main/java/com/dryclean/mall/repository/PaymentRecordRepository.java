package com.dryclean.mall.repository;

import com.dryclean.mall.entity.PaymentRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {

    Optional<PaymentRecord> findByOrderIdAndStatus(Long orderId, String status);

    List<PaymentRecord> findByOrderIdOrderByCreatedAtDesc(Long orderId);
}
