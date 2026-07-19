package com.dryclean.mall.dto;

import com.dryclean.mall.entity.OrderComment;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommentDTO {

    private Long id;
    private Long orderId;
    private String orderNo;
    private Long userId;
    private String username;
    private String targetType;
    private Long targetId;
    private String content;
    private String reply;
    private LocalDateTime replyTime;
    private Integer score;
    private LocalDateTime createdAt;

    public static CommentDTO fromEntity(OrderComment c) {
        CommentDTO dto = new CommentDTO();
        dto.setId(c.getId());
        dto.setOrderId(c.getOrderId());
        dto.setOrderNo(c.getOrderNo());
        dto.setUserId(c.getUserId());
        dto.setTargetType(c.getTargetType());
        dto.setTargetId(c.getTargetId());
        dto.setContent(c.getContent());
        dto.setReply(c.getReply());
        dto.setReplyTime(c.getReplyTime());
        dto.setScore(c.getScore());
        dto.setCreatedAt(c.getCreatedAt());
        return dto;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}

