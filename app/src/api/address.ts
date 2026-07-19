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

export const getAddressList = () => request<UserAddressItem[]>({ url: '/address/list' })
export const createAddress = (data: AddressCreateParams) =>
  request<UserAddressItem>({ url: '/address/create', method: 'POST', data })
export const updateAddress = (id: number, data: AddressCreateParams) =>
  request<UserAddressItem>({ url: `/address/${id}`, method: 'PUT', data })
export const removeAddress = (id: number) => request({ url: `/address/${id}`, method: 'DELETE' })
