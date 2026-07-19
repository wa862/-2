<template>
  <view class="page">
    <view class="panel">
      <view class="avatar-box" @click="chooseAvatar">
        <image v-if="displayAvatar" :src="displayAvatar" class="avatar-img" mode="aspectFill" />
        <text v-else>{{ avatarLetter }}</text>
      </view>
      <text class="avatar-tip">点击修改头像</text>

      <view class="field">
        <text class="label">用户名</text>
        <input v-model="profileForm.username" class="input" placeholder="请输入用户名" />
      </view>
      <view class="field">
        <text class="label">姓名</text>
        <input v-model="profileForm.realName" class="input" placeholder="请输入姓名" />
      </view>
      <button class="primary-btn" :loading="saving" @click="saveProfile">保存资料</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { updateProfile } from '@/api/auth'
import { uploadFile } from '@/utils/request'
import { resolveImageUrl } from '@/utils'
import { BASE_URL } from '@/config'

const store = useUserStore()
const saving = ref(false)
const profileForm = ref({ username: '', realName: '', avatar: '' })

const avatarLetter = computed(() => {
  const user = store.user
  return ((user && (user.username || user.phone)) || 'U').charAt(0).toUpperCase()
})
const displayAvatar = computed(() => {
  const user = store.user
  return resolveImageUrl(profileForm.value.avatar || (user && user.avatar))
})

function syncProfile() {
  if (!store.user) return
  profileForm.value = {
    username: store.user.username || '',
    realName: store.user.realName || '',
    avatar: store.user.avatar || '',
  }
}

async function saveProfile() {
  saving.value = true
  try {
    const user = await updateProfile({
      username: profileForm.value.username,
      realName: profileForm.value.realName,
      avatar: profileForm.value.avatar,
    })
    store.setAuth(store.token, user)
    uni.showToast({ title: '保存成功', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  } finally {
    saving.value = false
  }
}

function chooseAvatar() {
  uni.chooseImage({
    count: 1,
    success: async (res) => {
      try {
        const data = await uploadFile<{ url?: string }>('/upload/product-image', res.tempFilePaths[0])
        const url = data.url || ''
        profileForm.value.avatar = url.startsWith('http') ? url : BASE_URL.replace('/api', '') + url
      } catch (e: any) {
        uni.showToast({ title: (e && e.message) || '上传失败', icon: 'none' })
      }
    },
  })
}

onShow(syncProfile)
onMounted(syncProfile)
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
  padding: 36rpx 32rpx;
  box-shadow: 0 12rpx 34rpx rgba(24, 55, 102, 0.08);
}
.avatar-box {
  width: 144rpx;
  height: 144rpx;
  margin: 8rpx auto 12rpx;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(135deg, #66a8ff, #2f78ff);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 54rpx;
  font-weight: 700;
}
.avatar-img { width: 100%; height: 100%; }
.avatar-tip {
  display: block;
  text-align: center;
  color: #8a909d;
  font-size: 25rpx;
  margin-bottom: 36rpx;
}
.field { margin-bottom: 24rpx; }
.label {
  display: block;
  color: #6f7684;
  font-size: 26rpx;
  margin-bottom: 12rpx;
}
.input {
  height: 82rpx;
  padding: 0 22rpx;
  border-radius: 12rpx;
  background: #f5f7fa;
  font-size: 28rpx;
  color: #1f2533;
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
