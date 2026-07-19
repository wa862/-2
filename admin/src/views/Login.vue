<template>
  <div class="admin-auth-page">
    <div class="admin-auth-left">
      <div class="admin-hero">
        <div class="hero-logo">🧺</div>
        <h1 class="hero-title">干洗商城 · 管理后台</h1>
        <p class="hero-subtitle">实时掌控订单、用户与门店运营数据</p>
        <ul class="hero-list">
          <li>📊 仪表盘：今日订单、交易额一目了然</li>
          <li>🧺 服务与商品统一配置和上下架管理</li>
          <li>📍 门店与附近门店数据联动</li>
          <li>⭐ 用户评论与评价统一审核</li>
        </ul>
      </div>
    </div>

    <div class="admin-auth-right">
      <el-card class="auth-card">
        <h2 class="auth-title">管理员登录</h2>
        <p class="auth-desc">仅限平台管理员使用，请妥善保管账号密码</p>
        <el-form :model="form" label-width="0" @submit.prevent="onSubmit">
          <el-form-item>
            <el-input v-model="form.username" placeholder="请输入手机号" maxlength="11" inputmode="numeric">
              <template #prefix>📱</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password>
              <template #prefix>🔒</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-button class="auth-btn" type="primary" :loading="loading" @click="onSubmit">
              登录后台
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { login } from '@/api/auth'

const router = useRouter()
const route = useRoute()
const store = useUserStore()
const loading = ref(false)
const form = reactive({ username: '', password: '' })

const PHONE_REG = /^1[3-9]\d{9}$/
async function onSubmit() {
  const phone = (form.username || '').trim()
  if (!phone || !form.password) {
    ElMessage.warning('请输入手机号和密码')
    return
  }
  if (!PHONE_REG.test(phone)) {
    ElMessage.warning('请输入正确的手机号')
    return
  }
  loading.value = true
  try {
    const res = await login({ username: phone, password: form.password })
    if (!res.user || (res.user.role !== 'ADMIN' && res.user.role !== 'SUPPERADMIN')) {
      ElMessage.error('仅管理员账号可以登录后台')
      return
    }
    store.setAuth(res.token, res.user as any)
    ElMessage.success('登录成功')
    const redirect = (route.query.redirect as string) || '/dashboard'
    router.push(redirect)
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.admin-auth-page {
  min-height: 100vh;
  display: flex;
  align-items: stretch;
  background: #f5f7fa;
}

.admin-auth-left {
  flex: 1.2;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1f2f98, #4f8dfd);
  color: #fff;
}

.admin-hero {
  max-width: 420px;
  padding: 40px 32px;
}

.hero-logo {
  width: 66px;
  height: 66px;
  border-radius: 33px;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 34px;
  margin-bottom: 18px;
}

.hero-title {
  font-size: 34px;
  font-weight: 600;
  margin-bottom: 8px;
}

.hero-subtitle {
  font-size: 20px;
  opacity: 0.9;
  margin-bottom: 18px;
}

.hero-list {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: 19px;
  line-height: 1.9;
}

.admin-auth-right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 32px;
}

.auth-card {
  width: 420px;
  border-radius: 16px;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.08);
}

.auth-title {
  text-align: center;
  font-size: 30px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 6px;
}

.auth-desc {
  text-align: center;
  font-size: 19px;
  color: #909399;
  margin-bottom: 24px;
}

.auth-btn {
  width: 100%;
  height: 50px;
  border-radius: 8px;
  font-size: 20px;
  font-weight: 600;
}

@media (max-width: 960px) {
  .admin-auth-page {
    flex-direction: column;
  }
  .admin-auth-left {
    flex: none;
    padding: 24px 16px;
  }
  .admin-auth-right {
    flex: none;
    padding: 24px 16px 40px;
  }
}
</style>
