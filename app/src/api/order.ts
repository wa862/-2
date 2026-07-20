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
  deliveryType?: string
  remark?: string
  pickupDate?: string
  urgent?: number
  createdAt: string
  hasComment?: boolean
}

export const createOrder = (
  serviceId: number,
  quantity?: number,
  remark?: string,
  addressId?: number,
  deliveryType?: string,
  storeId?: number,
  serviceSpecName?: string,
  pickupDate?: string,
  urgent?: boolean
) =>
  request<OrderItem>({
    url: '/order/create',
    method: 'POST',
    data: {
      orderType: 'SERVICE',
      serviceId,
      quantity: quantity || 1,
      remark,
      addressId: addressId === undefined || addressId === null ? null : addressId,
      deliveryType: deliveryType || 'DOOR_TO_DOOR',
      storeId: storeId === undefined || storeId === null ? null : storeId,
      serviceSpecName: serviceSpecName || undefined,
      pickupDate: pickupDate || undefined,
      urgent: urgent ? true : undefined,
    },
  })

export const createProductOrder = (
  productId: number,
  quantity?: number,
  remark?: string,
  addressId?: number,
  deliveryType?: string,
  storeId?: number
) =>
  request<OrderItem>({
    url: '/order/create',
    method: 'POST',
    data: {
      orderType: 'PRODUCT',
      productId,
      quantity: quantity || 1,
      remark,
      addressId: addressId === undefined || addressId === null ? null : addressId,
      deliveryType: deliveryType || 'DOOR_TO_DOOR',
      storeId: storeId === undefined || storeId === null ? null : storeId,
    },
  })

export const myOrders = (page = 0, size = 20) =>
  request<OrderItem[]>({ url: '/order/my', params: { page, size } })
export const getOrderDetail = (id: number) => request<OrderItem>({ url: `/order/${id}` })
export const cancelOrder = (id: number) => request<OrderItem>({ url: `/order/${id}/cancel`, method: 'POST' })
