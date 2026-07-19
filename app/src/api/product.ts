import request from '@/utils/request'

export interface ProductItem {
  id: number
  name: string
  category: string
  brand?: string
  specification?: string
  price: number
  description?: string
  image?: string
  stock: number
  sales: number
  status: number
}

export const getProductList = () => request<ProductItem[]>({ url: '/product/list' })
export const getProductDetail = (id: number) => request<ProductItem>({ url: `/product/${id}` })
