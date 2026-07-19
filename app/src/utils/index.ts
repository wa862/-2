import { BASE_URL } from '@/config'

const PHONE_REG = /^1[3-9]\d{9}$/

export function isPhone(value: string) {
  return PHONE_REG.test(value.trim())
}

export function requireLogin(redirect?: string): boolean {
  const token = uni.getStorageSync('token')
  if (token) return true
  uni.showToast({ title: '请先登录', icon: 'none' })
  const url = redirect
    ? `/pages/login/login?redirect=${encodeURIComponent(redirect)}`
    : '/pages/login/login'
  setTimeout(() => uni.navigateTo({ url }), 400)
  return false
}

const TAB_PAGES = [
  '/pages/index/index',
  '/pages/service/list',
  '/pages/product/list',
  '/pages/cart/cart',
  '/pages/profile/profile',
]

/** 统一跳转：自动区分 tab 页与普通页 */
export function goPage(url: string, replace = false) {
  const path = (url || '').split('?')[0]
  if (TAB_PAGES.includes(path)) {
    uni.switchTab({ url: path })
    return
  }
  if (replace) {
    uni.redirectTo({ url })
  } else {
    uni.navigateTo({ url })
  }
}

export function formatTime(val?: string) {
  if (!val) return ''
  return val.replace('T', ' ').slice(0, 19)
}

export function fullAddress(a: {
  province?: string
  city?: string
  district?: string
  detailAddress?: string
}) {
  return [a.province, a.city, a.district, a.detailAddress].filter(Boolean).join('')
}

export function maskPhone(phone?: string) {
  if (!phone || phone.length < 7) return phone || ''
  return phone.slice(0, 3) + '****' + phone.slice(-4)
}

export type SpecOption = { name: string; price: number }

export function parseServiceSpecs(raw?: string): SpecOption[] {
  if (!raw || !raw.trim()) return []
  return raw
    .split(/[;,，]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => {
      const [name, priceStr] = part.split('|').map((s) => s.trim())
      const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
      if (!name || Number.isNaN(price) || price <= 0) return null
      return { name, price }
    })
    .filter((x): x is SpecOption => !!x)
}

export function listMinPrice(price: number, specs: SpecOption[]) {
  if (!specs.length) return price || 0
  return Math.min(...specs.map((s) => s.price))
}

export function matchServiceCategory(name: string, cat: string) {
  if (cat === '全部') return true
  if (cat === '西装') return name.includes('西装')
  if (cat === '羽绒服') return name.includes('羽绒服')
  if (cat === '大衣') return name.includes('大衣') || name.includes('呢子')
  if (cat === '日常衣物') return ['衬衫', 'T恤', '连衣裙', '牛仔裤', '围巾', '运动服'].some((k) => name.includes(k))
  if (cat === '鞋类') return ['鞋', '靴'].some((k) => name.includes(k))
  if (cat === '箱包/奢侈品') return ['羊绒', '羊毛', '皮衣', '毛毯', '背包', '帽子', '手套'].some((k) => name.includes(k))
  return true
}

/** 将后端相对路径补成小程序可访问的完整地址 */
export function resolveImageUrl(url?: string) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) return url
  // #ifdef H5
  return url
  // #endif
  // #ifndef H5
  if (url.startsWith('/')) {
    return BASE_URL.replace(/\/api$/, '') + url
  }
  return url
  // #endif
}

export function addDaysISO(days: number) {
  const d = new Date()
  d.setHours(0, 0, 0, 0)
  d.setDate(d.getDate() + days)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${dd}`
}

export function cycleMinDays(cycle?: string) {
  const s = (cycle || '').trim()
  if (!s) return 3
  const m = s.match(/(\d+)\s*-\s*(\d+)/)
  if (m) return Math.max(1, Number(m[1]) || 1)
  const m2 = s.match(/(\d+)/)
  if (m2) return Math.max(1, Number(m2[1]) || 1)
  return 3
}
