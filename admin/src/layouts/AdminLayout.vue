<template>
  <el-container class="admin-layout">
    <el-aside width="260px" class="aside">
      <div class="logo">干洗商城 · 管理后台</div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/dashboard">
          <el-icon><DataLine /></el-icon>
          <span>首页概览</span>
        </el-menu-item>
        <el-menu-item index="/service">
          <el-icon><Box /></el-icon>
          <span>服务管理</span>
        </el-menu-item>
        <el-menu-item index="/product">
          <el-icon><Goods /></el-icon>
          <span>商品管理</span>
        </el-menu-item>
        <el-menu-item index="/order">
          <el-icon><List /></el-icon>
          <span>订单管理</span>
        </el-menu-item>
        <el-menu-item index="/user">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/store">
          <el-icon><Location /></el-icon>
          <span>门店管理</span>
        </el-menu-item>
        <el-menu-item index="/comment">
          <el-icon><ChatDotRound /></el-icon>
          <span>评论管理</span>
        </el-menu-item>
        <el-menu-item index="/ai-knowledge">
          <el-icon><ChatLineRound /></el-icon>
          <span>AI知识库</span>
        </el-menu-item>
        <el-menu-item index="/settings">
          <el-icon><Setting /></el-icon>
          <span>系统设置</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container class="main-wrap">
      <el-header class="header">
        <span class="title">{{ pageTitle }}</span>
        <div class="right">
          <span class="username">{{ store.user?.username }}</span>
          <el-button type="primary" link @click="logout">退出</el-button>
        </div>
      </el-header>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { getCurrentUser } from '@/api/auth'
import { DataLine, Box, Goods, List, User, Location, ChatDotRound, ChatLineRound, Setting } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const store = useUserStore()

const activeMenu = computed(() => route.path)

onMounted(async () => {
  if (store.token && !store.user) {
    try {
      const user = await getCurrentUser()
      store.setAuth(store.token, user as any)
    } catch (_) {}
  }
})

const titleMap: Record<string, string> = {
  '/dashboard': '首页概览',
  '/service': '服务管理',
  '/product': '商品管理',
  '/order': '订单管理',
  '/user': '用户管理',
  '/store': '门店管理',
  '/comment': '评论管理',
  '/ai-knowledge': 'AI知识库',
  '/settings': '系统设置',
}
const pageTitle = computed(() => titleMap[route.path] || '管理后台')

function logout() {
  store.logout()
  router.push('/login')
}
</script>

<style scoped>
.admin-layout { height: 100vh; }
.aside { background: #304156; }
.logo {
  height: 70px;
  line-height: 70px;
  text-align: center;
  color: #fff;
  font-weight: 600;
  font-size: 22px;
}
.aside :deep(.el-menu-item) {
  height: 66px;
  line-height: 66px;
  font-size: 20px;
}
.aside :deep(.el-icon) {
  font-size: 23px;
}
.main-wrap { flex-direction: column; overflow: hidden; }
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
}
.title { font-size: 24px; font-weight: 600; }
.right { display: flex; align-items: center; gap: 12px; }
.username { color: #606266; font-size: 20px; }
.main { padding: 24px; background: #f0f2f5; overflow-y: auto; }
</style>
