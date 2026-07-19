import request from '@/utils/request'

export interface UserAddressItem {
  id: number
  userId: number
  contactName: string
  phone: string
  province?: string
  city?: string
  district?: string
  detailAddress: string
  isDefault: boolean
}

export interface AddressCreateParams {
  contactName: string
  phone: string
  province?: string
  city?: string
  district?: string
  detailAddress: string
  isDefault?: boolean
}

export function getAddressList() {
  return request.get<any, UserAddressItem[]>('/address/list')
}

export function createAddress(data: AddressCreateParams) {
  return request.post<any, UserAddressItem>('/address/create', data)
}

export function updateAddress(id: number, data: AddressCreateParams) {
  return request.put<any, UserAddressItem>(`/address/${id}`, data)
}

export function setDefaultAddress(id: number) {
  return request.post(`/address/${id}/default`)
}

export function removeAddress(id: number) {
  return request.delete(`/address/${id}`)
}
