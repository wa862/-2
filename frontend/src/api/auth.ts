import request from '@/utils/request'

export interface LoginReq {
  username: string
  password: string
}

export interface RegisterReq {
  username: string
  password: string
  realName?: string
  phone?: string
  code: string
  uuid: string
}

export interface AuthRes {
  token: string
  expireAt: number
  user: { id: number; username: string; realName?: string; phone?: string; avatar?: string; role: string }
}

export function login(data: LoginReq) {
  return request.post<any, AuthRes>('/auth/login', data)
}

export function register(data: RegisterReq) {
  return request.post<any, AuthRes>('/auth/register', data)
}

export function getCaptcha() {
  return request.get<any, { captchaEnabled?: boolean; img: string; uuid: string }>('/captchaImage')
}

/** 根据当前 token 获取用户信息（刷新页面后恢复用） */
export function getCurrentUser() {
  return request.get<any, AuthRes['user']>('/auth/me')
}

export interface ProfileUpdateReq {
  username?: string
  realName?: string
  avatar?: string
  /** 修改密码时必填 */
  currentPassword?: string
  newPassword?: string
}

/** 更新个人信息（姓名、密码）；手机号不可修改 */
export function updateProfile(data: ProfileUpdateReq) {
  return request.put<any, AuthRes['user']>('/auth/profile', data)
}
