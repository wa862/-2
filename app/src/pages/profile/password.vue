<template>
  <view class="page">
    <view class="panel">
      <view class="section-head">
        <view class="section-mark"></view>
        <text class="section-title">修改密码</text>
      </view>
      <view class="password-line">
        <view class="lock-icon lock-blue">▣</view>
        <text class="password-label">当前密码</text>
        <input v-model="passwordForm.currentPassword" class="password-input" password placeholder="请输入当前密码" />
      </view>
      <view class="password-line">
        <view class="lock-icon lock-blue">▣</view>
        <text class="password-label">新密码</text>
        <input v-model="passwordForm.newPassword" class="password-input" password placeholder="至少6位" />
      </view>
      <view class="password-line">
        <view class="lock-icon lock-green">▣</view>
        <text class="password-label">确认密码</text>
        <input v-model="passwordForm.confirmPassword" class="password-input" password placeholder="再次输入新密码" />
      </view>
      <button class="primary-btn" :loading="saving" @click="savePassword">修改密码</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { updateProfile } from '@/api/auth'

const saving = ref(false)
const passwordForm = ref({ currentPassword: '', newPassword: '', confirmPassword: '' })

async function savePassword() {
  const { currentPassword, newPassword, confirmPassword } = passwordForm.value
  if (!currentPassword || !newPassword) return uni.showToast({ title: '请填写密码', icon: 'none' })
  if (newPassword.length < 6) return uni.showToast({ title: '新密码至少6位', icon: 'none' })
  if (newPassword !== confirmPassword) return uni.showToast({ title: '两次密码不一致', icon: 'none' })
  saving.value = true
  try {
    await updateProfile({ currentPassword, newPassword })
    passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' }
    uni.showToast({ title: '密码已修改', icon: 'success' })
    setTimeout(() => uni.navigateBack(), 500)
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  } finally {
    saving.value = false
  }
}
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 28rpx;
  box-sizing: border-box;
  background: #f5f9ff;
}
.panel {
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 12rpx 34rpx rgba(24, 55, 102, 0.08);
}
.section-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 24rpx;
}
.section-mark {
  width: 8rpx;
  height: 34rpx;
  border-radius: 8rpx;
  background: #2f78ff;
}
.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #1f2533;
}
.password-line {
  display: flex;
  align-items: center;
  gap: 18rpx;
  min-height: 84rpx;
  border-bottom: 1rpx solid #edf0f5;
}
.lock-icon {
  width: 34rpx;
  height: 34rpx;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20rpx;
}
.lock-blue { color: #2f78ff; background: #eef5ff; border: 1rpx solid #75a9ff; }
.lock-green { color: #23c66c; background: #eefbf4; border: 1rpx solid #6edc9a; }
.password-label {
  width: 150rpx;
  color: #252b3a;
  font-size: 27rpx;
}
.password-input {
  flex: 1;
  height: 80rpx;
  color: #1f2533;
  font-size: 26rpx;
}
.primary-btn {
  height: 78rpx;
  line-height: 78rpx;
  margin-top: 34rpx;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #3e80ff, #2f78ff);
  color: #fff;
  font-size: 29rpx;
}
</style>
