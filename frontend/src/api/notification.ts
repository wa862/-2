import request from '@/utils/request'

export interface NotificationItem {
  id: number
  title: string
  content: string
  type: string
  relatedId?: number
  isRead: number
  createdAt: string
}

export function getNotificationList(page = 0, size = 20) {
  return request.get<any, NotificationItem[]>('/notification/list', { params: { page, size } })
}

export function getUnreadCount() {
  return request.get<any, { count: number }>('/notification/unread-count')
}

export function markRead(id: number) {
  return request.post(`/notification/${id}/read`)
}

export function markAllRead() {
  return request.post('/notification/read-all')
}
