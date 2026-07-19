import request from '@/utils/request'

export interface BannerItem {
  id?: number
  image?: string
  title?: string
  subtitle?: string
  link?: string
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

export const getBanners = () => request<BannerItem[]>({ url: '/settings/banners' })
export const getContactConfig = () => request<ContactConfig>({ url: '/settings/contact' })
export const getHomeModules = () => request<HomeModulesData>({ url: '/settings/home-modules' })
