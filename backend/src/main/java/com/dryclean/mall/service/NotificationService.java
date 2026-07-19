package com.dryclean.mall.service;

import com.dryclean.mall.dto.NotificationDTO;
import com.dryclean.mall.entity.SysNotification;
import com.dryclean.mall.repository.SysNotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SysNotificationRepository notificationRepository;

    public void create(Long userId, String title, String content, String type, Long relatedId) {
        SysNotification n = new SysNotification();
        n.setUserId(userId);
        n.setTitle(title);
        n.setContent(content);
        n.setType(type);
        n.setRelatedId(relatedId);
        n.setIsRead(0);
        notificationRepository.save(n);
    }

    public List<NotificationDTO> listByUser(Long userId, int page, int size) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(page, size))
                .stream()
                .map(NotificationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public long unreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsRead(userId, 0);
    }

    @Transactional
    public void markRead(Long userId, Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            if (n.getUserId().equals(userId)) {
                n.setIsRead(1);
                notificationRepository.save(n);
            }
        });
    }

    @Transactional
    public void markAllRead(Long userId) {
        notificationRepository.findByUserIdAndIsRead(userId, 0).forEach(n -> {
            n.setIsRead(1);
            notificationRepository.save(n);
        });
    }
}
