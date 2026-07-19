import request from '@/utils/request'

export interface LoginReq { username: string; password: string }
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
export interface ProfileUpdateReq {
  username?: string
  realName?: string
  avatar?: string
  currentPassword?: string
  newPassword?: string
}

export const login = (data: LoginReq) => request<AuthRes>({ url: '/auth/login', method: 'POST', data })
export const register = (data: RegisterReq) => request<AuthRes>({ url: '/auth/register', method: 'POST', data })
export const getCaptcha = () => request<{ captchaEnabled?: boolean; img: string; uuid: string }>({ url: '/captchaImage' })
export const getCurrentUser = () => request<AuthRes['user']>({ url: '/auth/me' })
export const updateProfile = (data: ProfileUpdateReq) => request<AuthRes['user']>({ url: '/auth/profile', method: 'PUT', data })
