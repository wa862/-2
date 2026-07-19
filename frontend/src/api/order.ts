import request from '@/utils/request'

export interface OrderItem {
  id: number
  orderNo: string
  userId: number
  serviceId?: number
  serviceName?: string
  serviceImage?: string
  productId?: number
  productName?: string
  productImage?: string
  quantity: number
  totalPrice: number
  status: string
  payStatus: string
  orderType?: string
  payTime?: string
  remark?: string
  pickupDate?: string
  deliveryType?: string
  urgent?: number
  createdAt: string
  /** 是否已评价，仅我的订单列表返回 */
  hasComment?: boolean
}

export function createOrder(
  serviceId: number,
  quantity?: number,
  remark?: string,
  addressId?: number,
  deliveryType?: string,
  storeId?: number,
  serviceSpecName?: string,
  pickupDate?: string,
  urgent?: boolean
) {
  return request.post<any, OrderItem>('/order/create', {
    orderType: 'SERVICE',
    serviceId,
    quantity: quantity || 1,
    remark,
    addressId: addressId ?? null,
    deliveryType: deliveryType || 'DOOR_TO_DOOR',
    storeId: storeId ?? null,
    serviceSpecName: serviceSpecName || undefined,
    pickupDate: pickupDate || undefined,
    urgent: urgent ? true : undefined,
  })
}

export function createProductOrder(
  productId: number,
  quantity?: number,
  remark?: string,
  addressId?: number,
  deliveryType?: string,
  storeId?: number
) {
  return request.post<any, OrderItem>('/order/create', {
    orderType: 'PRODUCT',
    productId,
    quantity: quantity || 1,
    remark,
    addressId: addressId ?? null,
    deliveryType: deliveryType || 'DOOR_TO_DOOR',
    storeId: storeId ?? null,
  })
}

export function myOrders(page = 0, size = 20) {
  return request.get<any, OrderItem[]>('/order/my', { params: { page, size } })
}

export function payOrder(id: number) {
  return request.post<any, OrderItem>(`/order/${id}/pay`)
}

export function cancelOrder(id: number) {
  return request.post<any, OrderItem>(`/order/${id}/cancel`)
}
