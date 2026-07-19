import { defineStore } from 'pinia'
import { ref } from 'vue'
import { TOKEN_KEY, USER_KEY } from '@/config'

export interface UserInfo {
  id: number
  username: string
  realName?: string
  phone?: string
  avatar?: string
  role: string
}

function loadUser(): UserInfo | null {
  try {
    const raw = uni.getStorageSync(USER_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export const useUserStore = defineStore('user', () => {
  const token = ref<string>(uni.getStorageSync(TOKEN_KEY) || '')
  const user = ref<UserInfo | null>(token.value ? loadUser() : null)

  function setAuth(t: string, u: UserInfo | null) {
    token.value = t
    user.value = u
    if (t) {
      uni.setStorageSync(TOKEN_KEY, t)
      if (u) uni.setStorageSync(USER_KEY, JSON.stringify(u))
    } else {
      uni.removeStorageSync(TOKEN_KEY)
      uni.removeStorageSync(USER_KEY)
    }
  }

  function logout() {
    setAuth('', null)
  }

  return { token, user, setAuth, logout }
})
