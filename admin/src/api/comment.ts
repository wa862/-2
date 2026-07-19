import request from '@/utils/request'

export interface CommentItem {
  id: number
  orderId: number
  orderNo?: string
  userId: number
  username?: string
  content?: string
  reply?: string
  replyTime?: string
  score: number
  createdAt: string
}

export function getCommentList() {
  return request.get<any, CommentItem[]>('/admin/comment/list')
}

export function replyComment(id: number, reply: string) {
  return request.post<any, CommentItem>(`/admin/comment/${id}/reply`, { reply })
}
