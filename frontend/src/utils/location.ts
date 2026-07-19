const DEFAULT_BAIDU_AK = 'S32mnPt9bygJ8kW0OtyyPfzjTdZXAc3R'

function getAk() {
  return (import.meta as any)?.env?.VITE_BAIDU_MAP_AK || DEFAULT_BAIDU_AK
}

let baiduMapLoadingPromise: Promise<any> | null = null
let hiddenMap: any = null

export interface GeoAddressResult {
  latitude: number
  longitude: number
  province: string
  city: string
  district: string
  street: string
  streetNumber: string
  fullAddress: string
}

export interface AddressCandidate {
  title: string
  address: string
  province: string
  city: string
  district: string
  fullAddress: string
}

export function loadBaiduMapSdk(): Promise<any> {
  const w = window as any
  if (w.BMap) return Promise.resolve(w.BMap)
  if (baiduMapLoadingPromise) return baiduMapLoadingPromise

  const ak = getAk()
  baiduMapLoadingPromise = new Promise((resolve, reject) => {
    const existing = document.getElementById('baidu-map-sdk')
    if (existing) {
      const timer = window.setInterval(() => {
        if ((window as any).BMap) {
          window.clearInterval(timer)
          resolve((window as any).BMap)
        }
      }, 100)
      window.setTimeout(() => {
        window.clearInterval(timer)
        if (!(window as any).BMap) reject(new Error('百度地图SDK加载超时'))
      }, 12000)
      return
    }

    const script = document.createElement('script')
    script.id = 'baidu-map-sdk'
    script.type = 'text/javascript'
    ;(window as any).__baiduMapInitCallback = () => resolve((window as any).BMap)
    script.src = `https://api.map.baidu.com/api?v=3.0&ak=${ak}&callback=__baiduMapInitCallback`
    script.onerror = () => reject(new Error('百度地图SDK加载失败'))
    document.body.appendChild(script)
  })

  return baiduMapLoadingPromise
}

function ensureHiddenMap(BMap: any) {
  if (hiddenMap) return hiddenMap
  const id = 'baidu-hidden-map'
  let el = document.getElementById(id)
  if (!el) {
    el = document.createElement('div')
    el.id = id
    el.style.cssText = 'position:fixed;left:-10000px;top:-10000px;width:1px;height:1px;overflow:hidden;'
    document.body.appendChild(el)
  }
  hiddenMap = new BMap.Map(id)
  hiddenMap.centerAndZoom(new BMap.Point(116.404, 39.915), 12)
  return hiddenMap
}

export async function getCurrentLocationAddress(): Promise<GeoAddressResult> {
  const BMap = await loadBaiduMapSdk()
  return new Promise((resolve, reject) => {
    const geolocation = new BMap.Geolocation()
    geolocation.getCurrentPosition(
      (r: any) => {
        if (geolocation.getStatus() !== (window as any).BMAP_STATUS_SUCCESS || !r?.point) {
          reject(new Error('定位失败'))
          return
        }
        const point = r.point
        const gc = new BMap.Geocoder()
        gc.getLocation(point, (geores: any) => {
          const comp = geores?.addressComponents || {}
          resolve({
            latitude: point.lat,
            longitude: point.lng,
            province: comp.province || '',
            city: comp.city || '',
            district: comp.district || '',
            street: comp.street || '',
            streetNumber: comp.streetNumber || '',
            fullAddress: geores?.address || '',
          })
        })
      },
      { enableHighAccuracy: true }
    )
  })
}

export async function searchAddressByKeyword(keyword: string, city = ''): Promise<AddressCandidate[]> {
  const kw = (keyword || '').trim()
  if (!kw) return []
  const BMap = await loadBaiduMapSdk()
  const map = ensureHiddenMap(BMap)
  return new Promise((resolve) => {
    const local = new BMap.LocalSearch(map, {
      onSearchComplete: async (results: any) => {
        const list: AddressCandidate[] = []
        const gc = new BMap.Geocoder()
        const count = results?.getCurrentNumPois ? results.getCurrentNumPois() : 0
        for (let i = 0; i < count; i++) {
          const poi = results.getPoi(i)
          if (!poi?.point) continue
          // 通过逆地理补齐省/市/区，保证三栏可选
          const detail = await new Promise<{
            province: string
            city: string
            district: string
            fullAddress: string
          }>((res) => {
            gc.getLocation(poi.point, (geores: any) => {
              const comp = geores?.addressComponents || {}
              res({
                province: comp.province || '',
                city: comp.city || city || '',
                district: comp.district || '',
                fullAddress: geores?.address || [poi.title, poi.address].filter(Boolean).join(' '),
              })
            })
          })
          list.push({
            title: poi.title || '',
            address: poi.address || '',
            province: detail.province,
            city: detail.city,
            district: detail.district,
            fullAddress: detail.fullAddress,
          })
        }
        resolve(list.slice(0, 10))
      },
    })
    if (city) local.searchInCity(kw, city)
    else local.search(kw)
  })
}
