import request from '@/utils/request'

export interface CartItem {
  id: number
  itemType: string
  productId?: number
  serviceId?: number
  serviceSpecName?: string
  name: string
  price: number
  image?: string
  quantity: number
  unit?: string
}

export const addToCart = (
  itemType: 'PRODUCT' | 'SERVICE',
  productId?: number,
  serviceId?: number,
  quantity = 1,
  serviceSpecName?: string
) =>
  request<CartItem>({
    url: '/cart/add',
    method: 'POST',
    data: {
      itemType,
      productId: productId === undefined || productId === null ? null : productId,
      serviceId: serviceId === undefined || serviceId === null ? null : serviceId,
      serviceSpecName: serviceSpecName || undefined,
      quantity,
    },
  })

export const getCartList = () => request<CartItem[]>({ url: '/cart/list' })
export const updateCartQuantity = (id: number, quantity: number) =>
  request<CartItem>({ url: `/cart/${id}`, method: 'PUT', params: { quantity } })
export const updateCartServiceSpec = (id: number, serviceSpecName?: string, quantity?: number) =>
  request<CartItem>({
    url: `/cart/${id}/service-spec`,
    method: 'PUT',
    params: { serviceSpecName: serviceSpecName || '', quantity },
  })
export const removeCartItem = (id: number) => request({ url: `/cart/${id}`, method: 'DELETE' })
