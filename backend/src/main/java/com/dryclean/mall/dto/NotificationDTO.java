package com.dryclean.mall.dto;

import com.dryclean.mall.entity.SysNotification;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NotificationDTO {

    private Long id;
    private String title;
    private String content;
    private String type;
    private Long relatedId;
    private Integer isRead;
    private LocalDateTime createdAt;

    public static NotificationDTO fromEntity(SysNotification n) {
        NotificationDTO dto = new NotificationDTO();
        dto.setId(n.getId());
        dto.setTitle(n.getTitle());
        dto.setContent(n.getContent());
        dto.setType(n.getType());
        dto.setRelatedId(n.getRelatedId());
        dto.setIsRead(n.getIsRead());
        dto.setCreatedAt(n.getCreatedAt());
        return dto;
    }
}
