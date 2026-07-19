package com.dryclean.mall.dto;

import com.dryclean.mall.entity.AiKnowledge;
import lombok.Data;

@Data
public class AiKnowledgeDTO {

    private Long id;
    private String question;
    private String answer;
    private String category;
    private String keywords;
    private Integer status;
    private Integer sortOrder;
    private Integer hitCount;

    public static AiKnowledgeDTO fromEntity(AiKnowledge entity) {
        AiKnowledgeDTO dto = new AiKnowledgeDTO();
        dto.setId(entity.getId());
        dto.setQuestion(entity.getQuestion());
        dto.setAnswer(entity.getAnswer());
        dto.setCategory(entity.getCategory());
        dto.setKeywords(entity.getKeywords());
        dto.setStatus(entity.getStatus());
        dto.setSortOrder(entity.getSortOrder());
        dto.setHitCount(entity.getHitCount());
        return dto;
    }
}
