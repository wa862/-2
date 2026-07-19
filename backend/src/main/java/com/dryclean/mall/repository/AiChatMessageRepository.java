package com.dryclean.mall.repository;

import com.dryclean.mall.entity.AiChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AiChatMessageRepository extends JpaRepository<AiChatMessage, Long> {
}
