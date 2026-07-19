<template>
  <view class="page">
    <view v-if="!store.token" class="empty-wrap">
      <button class="btn-primary" size="mini" @click="goLogin">去登录</button>
    </view>
    <view v-else-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!payment" class="empty-wrap">支付单不存在</view>
    <view v-else-if="payment.status==='PAID'" class="card paid">
      <text class="icon">✓</text>
      <text>已支付成功</text>
      <button class="btn-primary" @click="goOrders">返回订单</button>
    </view>
    <view v-else>
      <view class="card amount">
        <text class="label">支付金额</text>
        <text class="value">¥{{ formatAmount(payment.amount) }}</text>
        <text class="order-no">订单号：{{ payment.orderNo }}</text>
      </view>
      <view class="card">
        <text class="section-title">支付方式</text>
        <view
          v-for="m in methods"
          :key="m.key"
          class="method"
          :class="{ active: payMethod === m.key }"
          @click="payMethod = m.key"
        >
          <text class="icon">{{ m.icon }}</text>
          <view><text class="name">{{ m.name }}</text><text class="desc">{{ m.desc }}</text></view>
        </view>
      </view>
      <button class="btn-primary pay-btn" :loading="paying" @click="doPay">
        确认支付 ¥{{ formatAmount(payment.amount) }}
      </button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { getPayment, confirmPayment, type PaymentItem } from '@/api/payment'
import { requireLogin } from '@/utils'

const store = useUserStore()
const payment = ref<PaymentItem | null>(null)
const loading = ref(true)
const paying = ref(false)
const paymentId = ref(0)
const payMethod = ref('WECHAT')

const methods = [
  { key: 'WECHAT', icon: '微', name: '微信支付', desc: '小程序环境推荐使用' },
  { key: 'ALIPAY', icon: '支', name: '支付宝', desc: '演示环境模拟' },
  { key: 'SIMULATE', icon: '💳', name: '模拟支付', desc: '点击即完成支付' },
]

onLoad((q) => {
  if (!requireLogin('/pages/order/pay')) return
  paymentId.value = Number((q && q.paymentId) || 0)
})

async function doPay() {
  if (!payment.value) return
  paying.value = true
  try {
    await confirmPayment(payment.value.id, payMethod.value)
    payment.value = { ...payment.value, status: 'PAID' }
    uni.showToast({ title: '支付成功', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '支付失败', icon: 'none' })
  } finally {
    paying.value = false
  }
}

function goLogin() { uni.navigateTo({ url: '/pages/login/login' }) }
function goOrders() { uni.redirectTo({ url: '/pages/order/list' }) }
function formatAmount(amount?: number) { return typeof amount === 'number' ? amount.toFixed(2) : '0.00' }

onMounted(async () => {
  if (!paymentId.value) { loading.value = false; return }
  try { payment.value = await getPayment(paymentId.value) } catch {}
  loading.value = false
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.paid { text-align: center; padding: 60rpx 24rpx; }
.paid .icon { display: block; font-size: 80rpx; color: #67c23a; margin-bottom: 16rpx; }
.amount { text-align: center; padding: 40rpx 24rpx; }
.label { display: block; color: #909399; margin-bottom: 8rpx; }
.value { display: block; font-size: 56rpx; color: #ff4d4f; font-weight: 700; }
.order-no { display: block; font-size: 24rpx; color: #909399; margin-top: 12rpx; }
.method {
  display: flex;
  gap: 16rpx;
  padding: 20rpx;
  border: 2rpx solid #ebeef5;
  border-radius: 12rpx;
  margin-bottom: 12rpx;
}
.method.active { border-color: #409eff; background: #ecf5ff; }
.method .icon { font-size: 36rpx; font-weight: 700; width: 56rpx; text-align: center; }
.name { display: block; font-weight: 500; }
.desc { display: block; font-size: 24rpx; color: #909399; }
.pay-btn { width: 100%; height: 88rpx; line-height: 88rpx; margin-top: 24rpx; }
</style>
