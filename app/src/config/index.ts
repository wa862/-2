/**
 * 后端 API 根地址
 * - 微信开发者工具模拟器请用 127.0.0.1（比 localhost 更稳）
 * - 真机调试请改为电脑局域网 IP，如 http://192.168.1.100:8080/api
 * - 正式上线请改为 https 合法域名
 */
// #ifdef H5
export const BASE_URL = '/api'
// #endif

// #ifndef H5
export const BASE_URL = 'http://127.0.0.1:8080/api'
// #endif

export const TOKEN_KEY = 'token'
export const USER_KEY = 'user_info'
