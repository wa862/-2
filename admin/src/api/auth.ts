import request from '@/utils/request'

export interface LoginReq {
  username: string
  password: string
}

export interface AuthRes {
  token: string
  expireAt: number
  user: { id: number; username: string; realName?: string; phone?: string; role: string }
}

export function login(data: LoginReq) {
  return request.post<any, AuthRes>('/auth/login', data)
}

/** 根据当前 token 获取用户信息（刷新页面后恢复用） */
export function getCurrentUser() {
  return request.get<any, AuthRes['user']>('/auth/me')
}
