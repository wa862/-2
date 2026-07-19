<template>
  <div class="auth-page">
    <div class="auth-left">
      <div class="auth-hero">
        <div class="hero-logo">🧺</div>
        <h1 class="hero-title">洗衣优选 · 专业干洗服务</h1>
        <p class="hero-subtitle">上门取件 · 专业洗护 · 48 小时送回</p>
        <ul class="hero-list">
          <li>👕 精细衣物专属护理</li>
          <li>🚚 支持上门取送与到店自取</li>
          <li>🧼 在线下单 · 实时订单跟踪</li>
        </ul>
      </div>
    </div>
    <div class="auth-right">
      <el-card class="auth-card">
        <h2 class="auth-title">用户登录</h2>
        <p class="auth-desc">欢迎使用洗衣优选干洗服务平台</p>
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
            <el-button class="auth-btn" type="primary" :loading="loading" @click="onSubmit">登录</el-button>
          </el-form-item>
          <div class="auth-links">
            <router-link to="/home" class="link">返回首页</router-link>
            <span class="split">|</span>
            <span>没有账号？</span>
            <router-link to="/home/register" class="link-strong">去注册</router-link>
          </div>
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
    store.setAuth(res.token, res.user as any)
    ElMessage.success('登录成功')
    const redirect = (route.query.redirect as string) || '/home'
    router.push(redirect)
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: stretch;
  background: #f5f7fa;
}
.auth-left {
  flex: 1.2;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: #fff;
}
.auth-hero {
  max-width: 420px;
  padding: 40px 32px;
}
.hero-logo {
  width: 56px;
  height: 56px;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  margin-bottom: 18px;
}
.hero-title {
  font-size: 30px;
  font-weight: 600;
  margin-bottom: 8px;
}
.hero-subtitle {
  font-size: 18px;
  opacity: 0.9;
  margin-bottom: 18px;
}
.hero-list {
  list-style: none;
  padding: 0;
  margin: 0;
  font-size: 18px;
  line-height: 1.9;
}
.auth-right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
}
.auth-card {
  width: 380px;
  border-radius: 16px;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.08);
}
.auth-title {
  text-align: center;
  font-size: 26px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}
.auth-desc {
  text-align: center;
  font-size: 18px;
  color: #909399;
  margin-bottom: 20px;
}
.auth-btn {
  width: 100%;
  height: 40px;
  border-radius: 8px;
  font-size: 20px;
  font-weight: 600;
}
.auth-btn:hover {
  background: #337ecc;
}
.auth-links {
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 18px;
  color: #909399;
  margin-top: -8px;
}
.link {
  color: #409eff;
  text-decoration: none;
  margin: 0 6px;
}
.link-strong {
  color: #409eff;
  font-weight: 500;
  text-decoration: none;
  margin-left: 4px;
}
.split {
  margin: 0 6px;
  color: #c0c4cc;
}
@media (max-width: 960px) {
  .auth-page {
    flex-direction: column;
  }
  .auth-left {
    flex: none;
    padding: 24px 16px;
  }
  .auth-right {
    flex: none;
    padding: 24px 16px 40px;
  }
}
</style>
