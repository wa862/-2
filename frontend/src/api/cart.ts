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

export function addToCart(
  itemType: 'PRODUCT' | 'SERVICE',
  productId?: number,
  serviceId?: number,
  quantity = 1,
  serviceSpecName?: string
) {
  return request.post<any, CartItem>('/cart/add', {
    itemType,
    productId: productId ?? null,
    serviceId: serviceId ?? null,
    serviceSpecName: serviceSpecName || undefined,
    quantity,
  })
}

export function getCartList() {
  return request.get<any, CartItem[]>('/cart/list')
}

export function updateCartQuantity(id: number, quantity: number) {
  return request.put<any, CartItem>(`/cart/${id}`, null, { params: { quantity } })
}

export function removeCartItem(id: number) {
  return request.delete(`/cart/${id}`)
}
