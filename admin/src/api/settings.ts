import request from '@/utils/request'

export interface BannerItem {
  id?: number
  image?: string
  title?: string
  subtitle?: string
  link?: string
  sortOrder?: number
  enabled?: boolean
}

export interface ContactConfig {
  phone?: string
  hours?: string
  qr?: string
}

export interface ServiceOption {
  id: number
  name?: string
  price?: number
  category?: string
}

export interface ProductOption {
  id: number
  name?: string
  price?: number
  category?: string
}

export interface HomeModuleConfigResponse {
  hotServiceIds: number[]
  recommendProductIds: number[]
  allServices: ServiceOption[]
  allProducts: ProductOption[]
}

export function getBanners() {
  return request.get<any, BannerItem[]>('/admin/settings/banners')
}

export function saveBanners(data: BannerItem[]) {
  return request.post('/admin/settings/banners', data)
}

export function getContactConfig() {
  return request.get<any, ContactConfig>('/admin/settings/contact')
}

export function saveContactConfig(data: ContactConfig) {
  return request.post('/admin/settings/contact', data)
}

export function getHomeModuleConfig() {
  return request.get<any, HomeModuleConfigResponse>('/admin/settings/home-modules')
}

export function saveHomeModuleConfig(data: { hotServiceIds: number[]; recommendProductIds: number[] }) {
  return request.post('/admin/settings/home-modules', data)
}

