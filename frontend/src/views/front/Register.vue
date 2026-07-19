<template>
  <div class="auth-page">
    <div class="auth-left">
      <div class="auth-hero">
        <div class="hero-logo">👕</div>
        <h1 class="hero-title">新用户注册 · 享受专业洗护</h1>
        <p class="hero-subtitle">一次注册，全渠道使用干洗、到店自取与商城服务</p>
        <ul class="hero-list">
          <li>🧺 在线下单 · 实时查看订单状态</li>
          <li>🏪 附近门店一键选择，支持到店自取</li>
          <li>📱 手机号登录，安全便捷</li>
        </ul>
      </div>
    </div>
    <div class="auth-right">
      <el-card class="auth-card">
        <h2 class="auth-title">用户注册</h2>
        <p class="auth-desc">手机号 + 密码 + 图片验证码，保护您的账号安全</p>
        <el-form :model="form" label-width="0" @submit.prevent="onSubmit">
          <el-form-item>
            <el-input v-model="form.username" placeholder="请输入用户名" maxlength="20">
              <template #prefix>👤</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.phone" placeholder="请输入手机号" maxlength="20">
              <template #prefix>📱</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password>
              <template #prefix>🔒</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.confirmPassword" type="password" placeholder="请再次输入密码" show-password>
              <template #prefix>✅</template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <div class="captcha-row">
              <el-input
                v-model="form.captchaCode"
                placeholder="请输入验证码"
                maxlength="6"
                class="captcha-input"
              >
                <template #prefix>🔐</template>
              </el-input>
              <img
                v-if="captchaUrl"
                :src="captchaUrl"
                alt="验证码"
                class="captcha-img"
                @click="loadCaptcha"
              />
              <el-button text type="primary" @click="loadCaptcha">看不清？换一张</el-button>
            </div>
          </el-form-item>
          <el-form-item>
            <el-button class="auth-btn register-btn" type="primary" :loading="loading" @click="onSubmit">
              注册
            </el-button>
          </el-form-item>
          <div class="auth-links">
            <span>已有账号？</span>
            <router-link to="/home/login" class="link-strong">去登录</router-link>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { register, getCaptcha, type RegisterReq } from '@/api/auth'

const router = useRouter()
const route = useRoute()
const store = useUserStore()
const loading = ref(false)
const captchaEnabled = ref(true)
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
    captchaEnabled.value = res.captchaEnabled ?? true
    if (captchaEnabled.value) {
      captchaUrl.value = 'data:image/gif;base64,' + res.img
      uuid.value = res.uuid
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '验证码获取失败')
  }
}

async function onSubmit() {
  if (!form.username.trim()) {
    ElMessage.warning('请输入用户名')
    return
  }
  if (!form.phone.trim()) {
    ElMessage.warning('请输入手机号')
    return
  }
  if (!form.password || form.password.length < 6) {
    ElMessage.warning('密码至少 6 位')
    return
  }
  if (form.password !== form.confirmPassword) {
    ElMessage.warning('两次输入的密码不一致')
    return
  }
  if (!uuid.value || !form.captchaCode.trim()) {
    ElMessage.warning('请输入验证码')
    return
  }
  const data: RegisterReq = {
    username: form.username.trim(),
    password: form.password,
    phone: form.phone.trim(),
    code: form.captchaCode.trim(),
    uuid: uuid.value,
  }
  loading.value = true
  try {
    const res = await register(data)
    store.setAuth(res.token, res.user as any)
    ElMessage.success('注册并登录成功')
    const redirect = (route.query.redirect as string) || '/home'
    router.push(redirect)
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '注册失败')
    loadCaptcha()
  } finally {
    loading.value = false
  }
}

onMounted(loadCaptcha)
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
  width: 420px;
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
.register-btn {
  background: #67c23a;
  border-color: #67c23a;
}
.register-btn:hover {
  background: #5daf34;
  border-color: #5daf34;
}
.auth-links {
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 18px;
  color: #909399;
  margin-top: -8px;
}
.link-strong {
  color: #409eff;
  font-weight: 500;
  text-decoration: none;
  margin-left: 4px;
}
.captcha-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.captcha-input {
  max-width: 120px;
}
.captcha-img {
  width: 100px;
  height: 40px;
  border-radius: 4px;
  cursor: pointer;
  border: 1px solid #ebeef5;
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

