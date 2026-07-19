import request from '@/utils/request'

export interface ProductItem {
  id: number
  name: string
  category?: string
  brand?: string
  manufacturer?: string
  productionDate?: string
  specification?: string
  price: number
  description?: string
  image?: string
  stock?: number
  sales?: number
  status?: number
}

export function getProductList(all = false) {
  return request.get<any, ProductItem[]>('/product/list', { params: { all } })
}

export function getProductById(id: number) {
  return request.get<any, ProductItem>(`/product/${id}`)
}

export function createProduct(data: Partial<ProductItem>) {
  return request.post<any, ProductItem>('/product', data)
}

export function updateProduct(id: number, data: Partial<ProductItem>) {
  return request.put<any, ProductItem>(`/product/${id}`, data)
}
