import request from '@/utils/request'

export interface UserItem {
  id: number
  username: string
  realName?: string
  phone?: string
  role: string
  status?: number
  createdAt?: string
  updatedAt?: string
}

export function getUserList() {
  return request.get<any, UserItem[]>('/user/list')
}

export function updateUser(id: number, data: Partial<UserItem>) {
  return request.put<any, UserItem>(`/user/${id}`, data)
}
