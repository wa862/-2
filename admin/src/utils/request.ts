import axios from 'axios'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
})

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

request.interceptors.response.use(
  (res) => res.data,
  (err) => {
    const st = err.response?.status
    // 403：多为 token 失效/无管理员权限，与 401 一样退回登录，避免整页「有 token 但全 403、无数据」
    if (st === 401 || st === 403) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user_info')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default request
