import request from '@/utils/request'

export interface StoreItem {
  id: number
  name: string
  address?: string
  phone?: string
  businessHours?: string
}

export const getStoreList = () => request<StoreItem[]>({ url: '/store/list' })
