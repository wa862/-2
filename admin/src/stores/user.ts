import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface UserInfo {
  id: number
  username: string
  realName?: string
  phone?: string
  role: string
}

const ADMIN_USER_STORAGE_KEY = 'admin_user_info'

function loadAdminUser(): UserInfo | null {
  try {
    const raw = localStorage.getItem(ADMIN_USER_STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(localStorage.getItem('admin_token') || '')
  const user = ref<UserInfo | null>(token.value ? loadAdminUser() : null)

  function setAuth(t: string, u: UserInfo | null) {
    token.value = t
    user.value = u
    if (t) {
      localStorage.setItem('admin_token', t)
      if (u) localStorage.setItem(ADMIN_USER_STORAGE_KEY, JSON.stringify(u))
    } else {
      localStorage.removeItem('admin_token')
      localStorage.removeItem(ADMIN_USER_STORAGE_KEY)
    }
  }

  function logout() {
    setAuth('', null)
  }

  return { token, user, setAuth, logout }
})
