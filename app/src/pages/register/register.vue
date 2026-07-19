<template>
  <view class="page">
    <view class="hero">
      <text class="logo">👕</text>
      <text class="title">新用户注册</text>
      <text class="sub">手机号 + 密码 + 验证码</text>
    </view>
    <view class="card form-card">
      <input v-model="form.username" class="input" placeholder="请输入用户名" maxlength="20" />
      <input v-model="form.phone" class="input" type="number" maxlength="11" placeholder="请输入手机号" />
      <input v-model="form.password" class="input" password placeholder="请输入密码（至少6位）" />
      <input v-model="form.confirmPassword" class="input" password placeholder="请再次输入密码" />
      <view class="captcha-row">
        <input v-model="form.captchaCode" class="input captcha-input" placeholder="验证码" maxlength="6" />
        <image v-if="captchaUrl" :src="captchaUrl" class="captcha-img" @click="loadCaptcha" />
        <text class="refresh" @click="loadCaptcha">换一张</text>
      </view>
      <button class="btn-primary register-btn" :loading="loading" @click="onSubmit">注册</button>
      <view class="links"><text @click="goLogin">已有账号？去登录</text></view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { register, getCaptcha } from '@/api/auth'
import { useUserStore } from '@/stores/user'

const store = useUserStore()
const loading = ref(false)
const captchaUrl = ref('')
const uuid = ref('')
const form = reactive({
  username: '',
  phone: '',
  password: '',
  confirmPassword: '',
  captchaCode: '',
})

async function loadCaptcha() {
  try {
    const res = await getCaptcha()
    captchaUrl.value = 'data:image/gif;base64,' + res.img
    uuid.value = res.uuid
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '验证码获取失败', icon: 'none' })
  }
}

async function onSubmit() {
  if (!form.username.trim()) return uni.showToast({ title: '请输入用户名', icon: 'none' })
  if (!form.phone.trim()) return uni.showToast({ title: '请输入手机号', icon: 'none' })
  if (!form.password || form.password.length < 6) return uni.showToast({ title: '密码至少6位', icon: 'none' })
  if (form.password !== form.confirmPassword) return uni.showToast({ title: '两次密码不一致', icon: 'none' })
  if (!uuid.value || !form.captchaCode.trim()) return uni.showToast({ title: '请输入验证码', icon: 'none' })
  loading.value = true
  try {
    const res = await register({
      username: form.username.trim(),
      password: form.password,
      phone: form.phone.trim(),
      code: form.captchaCode.trim(),
      uuid: uuid.value,
    })
    store.setAuth(res.token, res.user)
    uni.showToast({ title: '注册成功', icon: 'success' })
    setTimeout(() => uni.switchTab({ url: '/pages/index/index' }), 500)
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '注册失败', icon: 'none' })
    loadCaptcha()
  } finally {
    loading.value = false
  }
}

function goLogin() { uni.navigateBack() }
onMounted(loadCaptcha)
</script>

<style scoped lang="scss">
.page { min-height: 100vh; background: #f5f7fa; }
.hero {
  padding: 60rpx 40rpx 40rpx;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: #fff;
  text-align: center;
}
.logo { font-size: 64rpx; display: block; margin-bottom: 12rpx; }
.title { font-size: 36rpx; font-weight: 600; display: block; }
.sub { font-size: 24rpx; opacity: 0.9; margin-top: 8rpx; display: block; }
.form-card { margin: -30rpx 24rpx 24rpx; }
.input {
  background: #f5f7fa;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
  font-size: 28rpx;
}
.captcha-row { display: flex; align-items: center; gap: 12rpx; margin-bottom: 20rpx; }
.captcha-input { flex: 1; margin-bottom: 0; }
.captcha-img { width: 180rpx; height: 72rpx; border-radius: 8rpx; }
.refresh { font-size: 24rpx; color: #409eff; white-space: nowrap; }
.register-btn { width: 100%; height: 88rpx; line-height: 88rpx; background: #67c23a; }
.links { text-align: center; margin-top: 24rpx; color: #409eff; font-size: 26rpx; }
</style>
