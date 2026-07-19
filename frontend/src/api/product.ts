import request from '@/utils/request'

export interface ProductItem {
  id: number
  name?: string
  category?: string
  brand?: string
  manufacturer?: string
  productionDate?: string
  specification?: string
  price?: number
  description?: string
  image?: string
  stock?: number
  sales?: number
  status?: number
}

export function getProductList() {
  return request.get<any, ProductItem[]>('/product/list')
}

export function getProductDetail(id: number) {
  return request.get<any, ProductItem>(`/product/${id}`)
}
