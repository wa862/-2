<template>
  <view class="page">
    <view v-if="!store.token" class="panel login-card">
      <text class="welcome">登录后享受完整服务</text>
      <button class="btn-primary" @click="goLogin">登录 / 注册</button>
    </view>
    <view v-else class="profile-wrap">
      <view class="hero-card">
        <view class="hero-main">
          <view class="avatar" @click="goProfileInfo">
            <image v-if="displayAvatar" :src="displayAvatar" class="avatar-img" mode="aspectFill" />
            <text v-else>{{ avatarLetter }}</text>
          </view>
          <view class="user-info">
            <text class="hero-name">{{ displayName }}</text>
            <view class="phone-row">
              <text class="phone-icon">▯</text>
              <text class="hero-phone">{{ displayPhone }}</text>
            </view>
          </view>
        </view>
        <view class="hero-gear">◎</view>
        <view class="hero-ring hero-ring-a"></view>
        <view class="hero-ring hero-ring-b"></view>
      </view>

      <view class="quick-panel">
        <view class="quick-item" @click="goOrders">
          <view class="quick-icon order-icon">≡</view>
          <text>我的订单</text>
        </view>
        <view class="quick-divider"></view>
        <view class="quick-item" @click="goCart">
          <view class="quick-icon cart-icon">●</view>
          <text>购物车</text>
        </view>
        <view class="quick-divider"></view>
        <view class="quick-item" @click="goStore">
          <view class="quick-icon store-icon">⌂</view>
          <text>附近门店</text>
        </view>
      </view>

      <view class="panel nav-panel" @click="goProfileInfo">
        <view class="section-head">
          <view class="section-mark"></view>
          <text class="section-title">个人信息</text>
        </view>
        <view class="summary-row">
          <view>
            <text class="summary-label">用户名</text>
            <text class="summary-value">{{ profileUsername }}</text>
          </view>
          <text class="nav-arrow">›</text>
        </view>
      </view>

      <view class="panel nav-panel" @click="goPassword">
        <view class="section-head">
          <view class="section-mark"></view>
          <text class="section-title">修改密码</text>
        </view>
        <view class="summary-row">
          <text class="summary-value">定期修改密码，保护账号安全</text>
          <text class="nav-arrow">›</text>
        </view>
      </view>

      <view class="panel nav-panel" @click="goAddresses">
        <view class="addr-head">
          <view class="section-head section-head-inline">
            <view class="section-mark"></view>
            <text class="section-title">收货地址</text>
          </view>
          <text class="nav-arrow">›</text>
        </view>
        <view v-if="!addressList.length" class="empty-wrap">暂无地址</view>
        <view v-for="a in addressPreview" :key="a.id" class="addr-item">
          <view class="pin">●</view>
          <view class="addr-info">
            <view class="addr-user">
              <text class="addr-name">{{ a.contactName }}</text>
              <text class="addr-phone">{{ a.phone }}</text>
            </view>
            <text class="addr-detail">{{ fullAddress(a) }}</text>
          </view>
        </view>
      </view>

      <button class="logout-btn" @click="logout">退出登录</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { getAddressList, type UserAddressItem } from '@/api/address'
import { fullAddress, resolveImageUrl } from '@/utils'

const store = useUserStore()
const addressList = ref<UserAddressItem[]>([])

const displayName = computed(() => {
  const user = store.user
  return (user && (user.username || user.phone)) || ''
})
const displayPhone = computed(() => {
  const user = store.user
  return (user && user.phone) || '未绑定手机号'
})
const profileUsername = computed(() => {
  const user = store.user
  return (user && user.username) || '-'
})
const avatarLetter = computed(() => (displayName.value || 'U').charAt(0).toUpperCase())
const displayAvatar = computed(() => {
  const user = store.user
  return resolveImageUrl(user && user.avatar)
})
const addressPreview = computed(() => addressList.value.slice(0, 2))

async function loadAddresses() {
  if (!store.token) return
  try { addressList.value = await getAddressList() } catch {}
}

function goLogin() { uni.navigateTo({ url: '/pages/login/login?redirect=/pages/profile/profile' }) }
function goOrders() { uni.navigateTo({ url: '/pages/order/list' }) }
function goCart() { uni.switchTab({ url: '/pages/cart/cart' }) }
function goStore() { uni.navigateTo({ url: '/pages/store/nearby' }) }
function goProfileInfo() { uni.navigateTo({ url: '/pages/profile/info' }) }
function goPassword() { uni.navigateTo({ url: '/pages/profile/password' }) }
function goAddresses() { uni.navigateTo({ url: '/pages/profile/address' }) }
function logout() {
  store.logout()
  uni.showToast({ title: '已退出', icon: 'none' })
}

onShow(loadAddresses)
onMounted(loadAddresses)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 24rpx 28rpx 48rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f5f9ff 0%, #f8fbff 42%, #ffffff 100%);
}
.profile-wrap { position: relative; }
.panel {
  background: #fff;
  border-radius: 20rpx;
  padding: 28rpx 32rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 12rpx 34rpx rgba(24, 55, 102, 0.08);
}
.login-card { text-align: center; padding: 70rpx 28rpx; }
.welcome { display: block; margin-bottom: 28rpx; color: #606266; }
.hero-card {
  position: relative;
  min-height: 220rpx;
  padding: 44rpx 40rpx 84rpx;
  border-radius: 24rpx;
  overflow: hidden;
  background: linear-gradient(135deg, #66a8ff 0%, #2f78ff 100%);
  box-shadow: 0 18rpx 42rpx rgba(47, 120, 255, 0.25);
}
.hero-main {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  gap: 28rpx;
}
.avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  background: rgba(255,255,255,0.95);
  color: #2f78ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48rpx;
  font-weight: 700;
  overflow: hidden;
  border: 5rpx solid rgba(255,255,255,0.9);
}
.avatar-img { width: 100%; height: 100%; }
.hero-name {
  display: block;
  color: #fff;
  font-size: 36rpx;
  font-weight: 700;
  line-height: 1.3;
}
.phone-row {
  display: flex;
  align-items: center;
  gap: 10rpx;
  margin-top: 12rpx;
}
.phone-icon, .hero-phone { color: rgba(255,255,255,0.95); font-size: 26rpx; }
.hero-gear {
  position: absolute;
  z-index: 2;
  top: 38rpx;
  right: 34rpx;
  color: #fff;
  font-size: 44rpx;
  font-weight: 700;
}
.hero-ring {
  position: absolute;
  border-radius: 50%;
  border: 2rpx solid rgba(255,255,255,0.08);
  background: rgba(255,255,255,0.08);
}
.hero-ring-a { width: 260rpx; height: 260rpx; right: 28rpx; bottom: -76rpx; }
.hero-ring-b { width: 170rpx; height: 170rpx; right: -46rpx; top: 0; background: rgba(40, 105, 230, 0.24); }
.quick-panel {
  position: relative;
  z-index: 3;
  display: flex;
  align-items: center;
  margin: -58rpx 18rpx 24rpx;
  padding: 26rpx 0;
  background: #fff;
  border-radius: 18rpx;
  box-shadow: 0 14rpx 38rpx rgba(29, 55, 92, 0.13);
}
.quick-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  color: #202637;
  font-size: 28rpx;
}
.quick-divider { width: 1rpx; height: 72rpx; background: #e6eaf0; }
.quick-icon {
  width: 54rpx;
  height: 54rpx;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 32rpx;
  font-weight: 700;
}
.order-icon { background: linear-gradient(180deg, #6fc4ff, #238bff); }
.cart-icon { background: linear-gradient(180deg, #ffc942, #ff9d15); border-radius: 50% 50% 12rpx 12rpx; }
.store-icon { background: linear-gradient(180deg, #7be88b, #39c966); border-radius: 14rpx 14rpx 8rpx 8rpx; }
.section-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
  margin-bottom: 24rpx;
}
.section-head-inline { margin-bottom: 0; }
.nav-panel { cursor: pointer; }
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
.summary-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  min-height: 58rpx;
}
.summary-label {
  display: block;
  color: #8a909d;
  font-size: 25rpx;
  margin-bottom: 8rpx;
}
.summary-value {
  display: block;
  color: #1f2533;
  font-size: 28rpx;
}
.nav-arrow { color: #9aa2af; font-size: 48rpx; line-height: 1; }
.addr-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}
.addr-item {
  display: flex;
  align-items: center;
  gap: 18rpx;
  padding: 24rpx 0;
  border-bottom: 1rpx dashed #e2e6ee;
}
.addr-item:last-child { border-bottom: none; padding-bottom: 4rpx; }
.pin {
  width: 54rpx;
  height: 54rpx;
  border-radius: 50%;
  background: #eaf2ff;
  color: #2f78ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26rpx;
}
.addr-info { flex: 1; min-width: 0; }
.addr-user {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin-bottom: 6rpx;
}
.addr-name {
  color: #1f2533;
  font-size: 30rpx;
  font-weight: 700;
}
.addr-phone {
  color: #6f7684;
  font-size: 26rpx;
}
.addr-detail {
  display: block;
  color: #6f7684;
  font-size: 25rpx;
  line-height: 1.45;
}
.logout-btn {
  height: 74rpx;
  line-height: 74rpx;
  margin-top: 28rpx;
  background: #fff8f8;
  color: #ff4d4f;
  border: 1rpx solid #ffd1d1;
  border-radius: 18rpx;
  font-size: 29rpx;
}
</style>
