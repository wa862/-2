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

export interface HomeModulesData {
  hotServices: { id: number; name?: string; price?: number; image?: string }[]
  recommendProducts: { id: number; name?: string; price?: number; image?: string }[]
}

export function getBanners() {
  return request.get<any, BannerItem[]>('/settings/banners')
}

export function getContactConfig() {
  return request.get<any, ContactConfig>('/settings/contact')
}

export function getHomeModules() {
  return request.get<any, HomeModulesData>('/settings/home-modules')
}

