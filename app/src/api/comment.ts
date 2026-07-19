import request from '@/utils/request'

export interface CommentItem {
  id: number
  orderId: number
  userId: number
  targetType?: 'SERVICE' | 'PRODUCT'
  targetId?: number
  username?: string
  content?: string
  reply?: string
  replyTime?: string
  score: number
  createdAt: string
}

export const createComment = (orderId: number, content: string, score: number) =>
  request<CommentItem>({ url: '/comment/create', method: 'POST', data: { orderId, content, score } })
export const getCommentList = (targetType: 'SERVICE' | 'PRODUCT', targetId: number) =>
  request<CommentItem[]>({ url: '/comment/list', params: { targetType, targetId } })
