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

export interface BatchPaymentItem {
  payments: PaymentItem[]
  totalAmount: number
  status: string
}

/** 为订单创建支付单（去支付时调用） */
export function createPayment(orderId: number) {
  return request.post<any, PaymentItem>(`/payment/order/${orderId}`)
}

export function createPayments(orderIds: number[]) {
  return request.post<any, BatchPaymentItem>('/payment/orders', { orderIds })
}

/** 获取支付单详情（支付页加载） */
export function getPayment(paymentId: number) {
  return request.get<any, PaymentItem>(`/payment/${paymentId}`)
}

/** 确认支付（用户在支付页点击「确认支付」后调用，payMethod: ALIPAY | WECHAT | SIMULATE） */
export function confirmPayment(paymentId: number, payMethod: string = 'SIMULATE') {
  return request.post<any, PaymentItem>(`/payment/${paymentId}/confirm`, { payMethod })
}

export function confirmPayments(paymentIds: number[], payMethod: string = 'SIMULATE') {
  return request.post<any, BatchPaymentItem>('/payment/batch/confirm', { paymentIds, payMethod })
}
