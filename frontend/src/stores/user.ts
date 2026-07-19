import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface UserInfo {
  id: number
  username: string
  realName?: string
  phone?: string
  avatar?: string
  role: string
}

const USER_STORAGE_KEY = 'user_info'

function loadUser(): UserInfo | null {
  try {
    const raw = localStorage.getItem(USER_STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const user = ref<UserInfo | null>(token.value ? loadUser() : null)

  function setAuth(t: string, u: UserInfo | null) {
    token.value = t
    user.value = u
    if (t) {
      localStorage.setItem('token', t)
      if (u) localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(u))
    } else {
      localStorage.removeItem('token')
      localStorage.removeItem(USER_STORAGE_KEY)
    }
  }

  function logout() {
    setAuth('', null)
  }

  return { token, user, setAuth, logout }
})
