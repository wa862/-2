package com.dryclean.mall.dto;

import lombok.Data;

@Data
public class AiChatResponse {

    private String answer;
    private String sourceType;
    private Long matchedKnowledgeId;
    private String matchedQuestion;
    private Double score;

    public static AiChatResponse of(String answer, String sourceType, Long matchedKnowledgeId, String matchedQuestion, Double score) {
        AiChatResponse response = new AiChatResponse();
        response.setAnswer(answer);
        response.setSourceType(sourceType);
        response.setMatchedKnowledgeId(matchedKnowledgeId);
        response.setMatchedQuestion(matchedQuestion);
        response.setScore(score);
        return response;
    }
}
