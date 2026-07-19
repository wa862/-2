/**
 * 后端 API 根地址
 * - 微信开发者工具模拟器/真机调试请用电脑局域网 IP
 * - 如果更换网络，请重新查看电脑 IPv4 地址并同步修改
 * - 正式上线请改为 https 合法域名
 */
// #ifdef H5
export const BASE_URL = '/api'
// #endif

// #ifndef H5
export const BASE_URL = 'http://127.0.0.1:8080/api'
// #endif

export const API_FALLBACK_URLS = [
  BASE_URL,
  // #ifndef H5
  'http://10.129.136.243:8080/api',
  // #endif
]

export const TOKEN_KEY = 'token'
export const USER_KEY = 'user_info'
