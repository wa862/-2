import request from '@/utils/request'

export interface StatsRes {
  todayOrders: number
  totalOrders: number
  sales: string
  userCount: number
}

export interface OrderTrendItem {
  /** 日期字符串，例如 2026-03-06 */
  date: string
  /** 当日订单数 */
  orderCount: number
  /** 当日销售额，单位元 */
  sales: number
}

export function getStats() {
  return request.get<any, StatsRes>('/admin/stats')
}

/** 最近 N 天订单趋势（默认 7 天） */
export function getOrderTrend(days = 7) {
  return request.get<any, OrderTrendItem[]>('/admin/stats/trend', { params: { days } })
}
