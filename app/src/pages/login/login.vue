<template>
  <view class="page">
    <view class="hero">
      <text class="logo">🧺</text>
      <text class="title">洗衣优选</text>
      <text class="sub">专业干洗 · 上门取件 · 48小时送回</text>
    </view>
    <view class="card form-card">
      <text class="form-title">用户登录</text>
      <input v-model="form.username" class="input" type="number" maxlength="11" placeholder="请输入手机号" />
      <input v-model="form.password" class="input" password placeholder="请输入密码" />
      <button class="btn-primary login-btn" :loading="loading" @click="onSubmit">登录</button>
      <view class="links">
        <text @click="goHome">返回首页</text>
        <text @click="goRegister">没有账号？去注册</text>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { login } from '@/api/auth'
import { useUserStore } from '@/stores/user'
import { goPage, isPhone } from '@/utils'

const store = useUserStore()
const loading = ref(false)
const redirect = ref('/pages/index/index')
const form = reactive({ username: '', password: '' })

onLoad((query) => {
  if (query && query.redirect) redirect.value = decodeURIComponent(String(query.redirect))
})

async function onSubmit() {
  const phone = form.username.trim()
  if (!phone || !form.password) {
    uni.showToast({ title: '请输入手机号和密码', icon: 'none' })
    return
  }
  if (!isPhone(phone)) {
    uni.showToast({ title: '请输入正确的手机号', icon: 'none' })
    return
  }
  loading.value = true
  try {
    const res = await login({ username: phone, password: form.password })
    store.setAuth(res.token, res.user)
    uni.showToast({ title: '登录成功', icon: 'success' })
    setTimeout(() => {
      goPage(redirect.value, true)
    }, 500)
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '登录失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

function goHome() { uni.switchTab({ url: '/pages/index/index' }) }
function goRegister() { uni.navigateTo({ url: '/pages/register/register' }) }
</script>

<style scoped lang="scss">
.page { min-height: 100vh; background: #f5f7fa; }
.hero {
  padding: 80rpx 40rpx 40rpx;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: #fff;
  text-align: center;
}
.logo { font-size: 72rpx; display: block; margin-bottom: 16rpx; }
.title { font-size: 40rpx; font-weight: 600; display: block; }
.sub { font-size: 26rpx; opacity: 0.9; margin-top: 12rpx; display: block; }
.form-card { margin: -40rpx 24rpx 24rpx; }
.form-title { display: block; text-align: center; font-size: 34rpx; font-weight: 600; margin-bottom: 32rpx; }
.input {
  background: #f5f7fa;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  font-size: 28rpx;
}
.login-btn { width: 100%; margin-top: 12rpx; height: 88rpx; line-height: 88rpx; }
.links {
  display: flex;
  justify-content: space-between;
  margin-top: 24rpx;
  font-size: 26rpx;
  color: #409eff;
}
</style>
