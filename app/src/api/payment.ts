import request from '@/utils/request'

export interface PaymentItem {
  id: number
  orderId: number
  userId: number
  amount: number
  status: string
  payMethod: string
  orderNo: string
  createdAt?: string
  paidAt?: string
}

export const createPayment = (orderId: number) =>
  request<PaymentItem>({ url: `/payment/order/${orderId}`, method: 'POST' })
export const getPayment = (paymentId: number) => request<PaymentItem>({ url: `/payment/${paymentId}` })
export const confirmPayment = (paymentId: number, payMethod = 'SIMULATE') =>
  request<PaymentItem>({ url: `/payment/${paymentId}/confirm`, method: 'POST', data: { payMethod } })
