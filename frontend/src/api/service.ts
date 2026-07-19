import request from '@/utils/request'

export interface ServiceItem {
  id: number
  name: string
  category: string
  price: number
  description?: string
  image?: string
  status: number
  specs?: string
  cycle?: string
}

export function getServiceList() {
  return request.get<any, ServiceItem[]>('/service/list')
}
