package com.dryclean.mall.repository;

import com.dryclean.mall.entity.AiKnowledge;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AiKnowledgeRepository extends JpaRepository<AiKnowledge, Long> {

    List<AiKnowledge> findByStatusOrderBySortOrderAsc(Integer status);

    List<AiKnowledge> findByQuestionContainingIgnoreCaseOrAnswerContainingIgnoreCaseOrKeywordsContainingIgnoreCase(
            String question, String answer, String keywords, Sort sort);
}
