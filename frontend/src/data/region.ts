import { ref } from 'vue'
import { regionData } from 'element-china-area-data'

/** 省市区级联选项（全国数据） */
export interface RegionOption {
  value: string
  label: string
  children?: RegionOption[]
}

export const regionOptions: RegionOption[] = regionData as unknown as RegionOption[]

function findPathByCodes(arr: string[]): { p?: RegionOption; c?: RegionOption; d?: RegionOption } {
  const p = regionOptions.find((x) => x.value === arr[0])
  const c = p?.children?.find((x) => x.value === arr[1])
  const d = c?.children?.find((x) => x.value === arr[2])
  return { p, c, d }
}

function findPathByNames(province: string, city: string, district: string): string[] {
  const pName = (province || '').trim()
  const cName = (city || '').trim()
  const dName = (district || '').trim()
  if (!pName) return []

  const p = regionOptions.find((x) => x.label === pName)
  if (!p) return []

  if (!cName && !dName) return [p.value]

  const cityList = p.children || []
  let c = cityList.find((x) => x.label === cName)

  // 直辖市/特殊城市兜底
  if (!c && cName === pName && cityList.length === 1) c = cityList[0]
  if (!c && cityList.length > 0) c = cityList[0]
  if (!c) return [p.value]

  if (!dName) return [p.value, c.value]
  const d = (c.children || []).find((x) => x.label === dName)
  if (!d) return [p.value, c.value]
  return [p.value, c.value, d.value]
}

/** 将级联选中的数组转为省/市/区。直辖市两级 [市, 区]；普通省三级 [省, 市, 区] */
export function regionToAddress(arr?: string[]): { province: string; city: string; district: string } {
  if (!arr?.length) return { province: '', city: '', district: '' }
  const { p, c, d } = findPathByCodes(arr)
  if (arr.length >= 3) {
    return {
      province: p?.label || '',
      city: c?.label || p?.label || '',
      district: d?.label || '',
    }
  }
  if (arr.length === 2) {
    return {
      province: p?.label || '',
      city: c?.label || p?.label || '',
      district: '',
    }
  }
  if (arr.length === 1) return { province: p?.label || '', city: '', district: '' }
  return { province: '', city: '', district: '' }
}

/** 将地址转为级联值数组（用于编辑时回显） */
export function addressToRegion(province?: string, city?: string, district?: string): string[] {
  return findPathByNames(province || '', city || '', district || '')
}

/**
 * 供页面直接绑定的级联选项（可在运行时替换为远程数据）。
 */
export const regionOptionsRef = ref<RegionOption[]>(regionOptions)

/**
 * 兼容调用方的异步初始化入口。
 * 当前使用内置静态数据，直接确保 options 已就绪。
 */
export async function loadBaiduRegion(): Promise<void> {
  if (!regionOptionsRef.value?.length) {
    regionOptionsRef.value = regionOptions
  }
}
