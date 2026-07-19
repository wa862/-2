import request from '@/utils/request'

export interface StoreItem {
  id: number
  name: string
  address?: string
  phone?: string
  businessHours?: string
  sortOrder?: number
}

export function getStoreList() {
  return request.get<any, StoreItem[]>('/store/list')
}
