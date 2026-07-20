<template>
  <el-container class="front-layout">
    <el-header class="header">
      <router-link to="/home" class="brand">洗衣优选 | 专业干洗</router-link>
      <el-menu :default-active="activeMenu" mode="horizontal" router class="nav-menu">
        <el-menu-item index="/home">首页</el-menu-item>
        <el-menu-item index="/home/user/service">干洗服务</el-menu-item>
        <el-menu-item index="/home/user/product">商城</el-menu-item>
        <el-menu-item index="/home/user/cart">购物车</el-menu-item>
        <el-menu-item index="/home/user/store">附近门店</el-menu-item>
        <el-menu-item index="/home/user/ai">AI客服</el-menu-item>
        <el-menu-item index="/home/user/order">我的订单</el-menu-item>
      </el-menu>
      <div class="right">
        <NotificationBell v-if="store.token" />
        <template v-if="store.token">
          <el-dropdown @command="handleCommand">
            <span class="user-avatar-wrapper">
              <el-avatar :size="42" class="user-avatar" :src="headerAvatarUrl">
                {{ (store.user?.username || 'U').charAt(0).toUpperCase() }}
              </el-avatar>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item disabled>
                  {{ store.user?.username || '已登录用户' }}
                </el-dropdown-item>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
        <template v-else>
          <el-button text @click="$router.push('/home/login')">登录</el-button>
          <el-button type="primary" @click="$router.push('/home/register')">注册</el-button>
        </template>
      </div>
    </el-header>
    <el-main class="main">
      <router-view />
    </el-main>
    <button
      v-if="!isAiPage"
      class="ai-float"
      :class="{ dragging: aiDragging }"
      :style="{ top: `${aiFloatTop}px` }"
      type="button"
      aria-label="智能AI客服"
      @click="handleAiClick"
      @pointerdown="startAiDrag"
    >
      <span class="ai-bubble">AI</span>
      <span class="ai-text">智能客服</span>
    </button>
  </el-container>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { getCurrentUser } from '@/api/auth'
import NotificationBell from '@/components/NotificationBell.vue'

const route = useRoute()
const router = useRouter()
const store = useUserStore()
const activeMenu = computed(() => route.path)
const isAiPage = computed(() => route.path === '/home/user/ai')
const aiFloatTop = ref(0)
const aiDragging = ref(false)
const aiMoved = ref(false)
const dragStartY = ref(0)
const dragStartTop = ref(0)
const aiFloatHeight = 58
const aiFloatStorageKey = 'front_ai_float_top'

function resolveAvatarUrl(url: string | undefined): string {
  if (!url?.trim()) return ''
  const u = url.trim()
  if (u.startsWith('http://') || u.startsWith('https://')) return u
  return u.startsWith('/') ? u : '/' + u
}
const headerAvatarUrl = computed(() => resolveAvatarUrl(store.user?.avatar))

onMounted(async () => {
  initAiFloatPosition()
  if (store.token) {
    try {
      const user = await getCurrentUser()
      store.setAuth(store.token, user as any)
    } catch (_) {}
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('pointermove', onAiDrag)
  window.removeEventListener('pointerup', stopAiDrag)
  window.removeEventListener('resize', clampAiFloatPosition)
})

function handleCommand(cmd: string) {
  if (cmd === 'profile') {
    router.push('/home/user/profile')
  } else if (cmd === 'logout') {
    store.logout()
    router.push('/home')
  }
}

function initAiFloatPosition() {
  const saved = Number(localStorage.getItem(aiFloatStorageKey))
  aiFloatTop.value = Number.isFinite(saved) && saved > 0
    ? saved
    : Math.max(92, window.innerHeight - 126)
  clampAiFloatPosition()
  window.addEventListener('resize', clampAiFloatPosition)
}

function clampAiFloatPosition() {
  const minTop = 88
  const maxTop = Math.max(minTop, window.innerHeight - aiFloatHeight - 24)
  aiFloatTop.value = Math.min(maxTop, Math.max(minTop, aiFloatTop.value))
}

function startAiDrag(e: PointerEvent) {
  aiDragging.value = true
  aiMoved.value = false
  dragStartY.value = e.clientY
  dragStartTop.value = aiFloatTop.value
  window.addEventListener('pointermove', onAiDrag)
  window.addEventListener('pointerup', stopAiDrag)
}

function onAiDrag(e: PointerEvent) {
  if (!aiDragging.value) return
  const dy = e.clientY - dragStartY.value
  if (Math.abs(dy) > 4) aiMoved.value = true
  aiFloatTop.value = dragStartTop.value + dy
  clampAiFloatPosition()
}

function stopAiDrag() {
  if (!aiDragging.value) return
  aiDragging.value = false
  localStorage.setItem(aiFloatStorageKey, String(aiFloatTop.value))
  window.removeEventListener('pointermove', onAiDrag)
  window.removeEventListener('pointerup', stopAiDrag)
}

function handleAiClick() {
  if (aiMoved.value) return
  router.push('/home/user/ai')
}
</script>

<style scoped>
.front-layout { min-height: 100vh; flex-direction: column; }
.header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  min-height: 56px;
  padding: 0 24px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
}
.brand {
  font-size: 18px;
  font-weight: 600;
  color: #409eff;
  text-decoration: none;
  margin-right: 24px;
  white-space: nowrap;
}
.search-box { width: 240px; margin-right: 16px; }
.nav-menu {
  flex: 1;
  border: none;
  min-height: 56px;
}
.nav-menu :deep(.el-menu-item) {
  height: 56px;
  line-height: 56px;
  padding: 0 14px;
  font-size: 14px;
}
.right { display: flex; align-items: center; gap: 16px; }
.user-avatar-wrapper {
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
}
.user-avatar {
  background-color: #409eff;
  color: #fff;
  font-size: 20px;
  border: 2px solid #fff;
  box-shadow: 0 2px 10px rgba(64, 158, 255, 0.24);
}
.main { padding: 16px 24px; background: #f5f7fa; }
.ai-float {
  position: fixed;
  right: 34px;
  z-index: 2000;
  display: flex;
  align-items: center;
  gap: 10px;
  height: 58px;
  padding: 0 18px 0 12px;
  border: none;
  border-radius: 999px;
  background: linear-gradient(135deg, #55b8ff 0%, #2f78ff 100%);
  color: #fff;
  box-shadow: 0 12px 28px rgba(47, 120, 255, 0.32);
  cursor: grab;
  user-select: none;
  touch-action: none;
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.ai-float.dragging {
  cursor: grabbing;
  transition: box-shadow 0.18s ease;
}
.ai-float:hover {
  transform: translateY(-2px);
  box-shadow: 0 16px 34px rgba(47, 120, 255, 0.38);
}
.ai-bubble {
  width: 38px;
  height: 34px;
  border-radius: 14px 14px 14px 5px;
  background: rgba(255,255,255,0.95);
  color: #2f78ff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 800;
}
.ai-text {
  font-size: 17px;
  font-weight: 700;
  white-space: nowrap;
}
</style>
