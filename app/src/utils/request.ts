import { BASE_URL, TOKEN_KEY } from '@/config'

interface RequestOptions {
  url: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  data?: Record<string, unknown> | unknown
  header?: Record<string, string>
  params?: Record<string, string | number | boolean | undefined | null>
}

function buildUrl(url: string, params?: RequestOptions['params']) {
  if (!params) return BASE_URL + url
  const qs = Object.entries(params)
    .filter(([, v]) => v !== undefined && v !== null)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`)
    .join('&')
  return qs ? `${BASE_URL}${url}?${qs}` : BASE_URL + url
}

export function request<T = unknown>(options: RequestOptions): Promise<T> {
  const token = uni.getStorageSync(TOKEN_KEY)
  const fullUrl = buildUrl(options.url, options.params)
  return new Promise((resolve, reject) => {
    uni.request({
      url: fullUrl,
      method: options.method || 'GET',
      data: options.data as UniApp.RequestOptions['data'],
      timeout: 15000,
      header: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...options.header,
      },
      success: (res) => {
        if (res.statusCode === 401) {
          uni.removeStorageSync(TOKEN_KEY)
          uni.removeStorageSync('user_info')
          uni.showToast({ title: '请先登录', icon: 'none' })
          setTimeout(() => {
            uni.navigateTo({ url: '/pages/login/login' })
          }, 500)
          reject(new Error('未登录'))
          return
        }
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data as T)
          return
        }
        const data = res.data as { message?: string } | undefined
        const msg = (data && data.message) || `请求失败(${res.statusCode})`
        reject(new Error(msg))
      },
      fail: (err) => {
        console.error('[request fail]', fullUrl, err)
        reject(new Error('网络请求失败，请确认后端已启动且地址配置正确'))
      },
    })
  })
}

export function uploadFile<T = unknown>(url: string, filePath: string, name = 'file'): Promise<T> {
  const token = uni.getStorageSync(TOKEN_KEY)
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url: BASE_URL + url,
      filePath,
      name,
      header: token ? { Authorization: `Bearer ${token}` } : {},
      success: (res) => {
        if (res.statusCode === 401) {
          reject(new Error('未登录'))
          return
        }
        try {
          resolve(JSON.parse(res.data) as T)
        } catch {
          reject(new Error('上传失败'))
        }
      },
      fail: (err) => {
        console.error('[upload fail]', err)
        reject(new Error('上传失败'))
      },
    })
  })
}

export default request
