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

/** 创建订单评价 */
export function createComment(orderId: number, content: string, score: number) {
  return request.post<any, CommentItem>('/comment/create', { orderId, content, score })
}

/** 检查订单是否已评价 */
export function hasCommented(orderId: number) {
  return request.get<any, boolean>('/comment/has-commented', { params: { orderId } })
}

/** 公开评论列表（用于商品/服务详情页展示评价区） */
export function getCommentList(targetType: 'SERVICE' | 'PRODUCT', targetId: number) {
  return request.get<any, CommentItem[]>('/comment/list', { params: { targetType, targetId } })
}
