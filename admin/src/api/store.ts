import request from '@/utils/request'

export interface StoreItem {
  id: number
  name: string
  address?: string
  phone?: string
  businessHours?: string
  sortOrder?: number
}

export function getStoreList(all = false) {
  return request.get<any, StoreItem[]>('/store/list', { params: { all } })
}

export function deleteStore(id: number) {
  return request.delete(`/store/${id}`)
}

export function createStore(data: Partial<StoreItem>) {
  return request.post<any, StoreItem>('/store', data)
}

export function updateStore(id: number, data: Partial<StoreItem>) {
  return request.put<any, StoreItem>(`/store/${id}`, data)
}
