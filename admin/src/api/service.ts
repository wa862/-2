import request from '@/utils/request'

export interface ServiceItem {
  id: number
  name: string
  category?: string
  price: number
  description?: string
  image?: string
  status?: number
}

export function getServiceList(all = false) {
  return request.get<any, ServiceItem[]>('/service/list', { params: { all } })
}

export function getServiceById(id: number) {
  return request.get<any, ServiceItem>(`/service/${id}`)
}

export function createService(data: Partial<ServiceItem>) {
  return request.post<any, ServiceItem>('/service', data)
}

export function updateService(id: number, data: Partial<ServiceItem>) {
  return request.put<any, ServiceItem>(`/service/${id}`, data)
}

export function deleteService(id: number) {
  return request.request({ method: 'DELETE', url: `/service/${id}` })
}
