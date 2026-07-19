import request from '@/utils/request'

export interface OrderItem {
  id: number
  orderNo: string
  userId: number
  serviceId: number
  serviceName?: string
  quantity: number
  totalPrice: number
  status: string
  payStatus: string
  orderType?: string
  deliveryType?: string
  storeId?: number
  storeName?: string
  userName?: string
  userPhone?: string
  createdAt: string
}

export interface OrderListRes {
  content: OrderItem[]
  totalElements: number
  totalPages: number
  number: number
  size: number
}

export function getOrderList(params: {
  page?: number
  size?: number
  keyword?: string
  orderType?: string
  deliveryType?: string
  status?: string
}) {
  return request.get<any, OrderListRes>('/order/list', { params })
}

export function updateOrderStatus(id: number, status: string) {
  return request.put<any, OrderItem>(`/order/${id}/status`, { status })
}

export function advanceOrder(id: number) {
  return request.post<any, OrderItem>(`/order/${id}/advance`)
}
