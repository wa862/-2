<template>
  <view class="page">
    <scroll-view scroll-x class="tabs">
      <view
        v-for="tab in tabs"
        :key="tab.key"
        class="tab"
        :class="{ active: activeTab === tab.key }"
        @click="activeTab = tab.key"
      >{{ tab.label }}</view>
    </scroll-view>

    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!filteredList.length" class="empty-wrap">
      <text class="empty-title">暂无订单</text>
      <button class="empty-btn" @click="goService">去预约下单</button>
    </view>
    <view v-for="order in filteredList" :key="order.id" class="card order-card" @click="goDetail(order.id)">
      <view class="head">
        <text>{{ formatTime(order.createdAt) }}</text>
        <text class="status">{{ statusText(order) }}</text>
      </view>
      <view class="body">
        <image
          v-if="orderImage(order)"
          :src="resolveImageUrl(orderImage(order))"
          class="thumb"
          mode="aspectFill"
        />
        <view v-else class="thumb ph">{{ order.orderType === 'PRODUCT' ? '商品' : '服务' }}</view>
        <view class="info">
          <text class="name">{{ orderName(order) }}</text>
          <text class="qty">数量：{{ order.quantity }}</text>
          <text class="price">¥{{ order.totalPrice }}</text>
        </view>
      </view>
      <view class="foot">
        <text>实付款 ¥{{ order.totalPrice }}</text>
        <view class="actions">
          <button v-if="order.payStatus==='UNPAID' && order.status!=='CANCELLED'" size="mini" @click.stop="cancel(order.id)">取消</button>
          <button v-if="order.payStatus==='UNPAID' && order.status!=='CANCELLED'" size="mini" type="primary" @click.stop="pay(order.id)">去支付</button>
          <button
            v-if="order.status==='COMPLETED' && !order.hasComment"
            size="mini"
            @click.stop="openEval(order)"
          >评价</button>
        </view>
      </view>
    </view>

    <view v-if="evalVisible" class="mask" @click="evalVisible=false">
      <view class="dialog" @click.stop>
        <text class="dialog-title">提交评价</text>
        <view class="stars">
          <text v-for="n in 5" :key="n" :class="{ on: n <= evalScore }" @click="evalScore=n">★</text>
        </view>
        <textarea v-model="evalContent" placeholder="分享您的体验" class="textarea" />
        <button class="btn-primary" :loading="evalSubmitting" @click="submitEval">提交</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { myOrders, cancelOrder, type OrderItem } from '@/api/order'
import { createPayment } from '@/api/payment'
import { createComment } from '@/api/comment'
import { formatTime, resolveImageUrl, requireLogin } from '@/utils'

const list = ref<OrderItem[]>([])
const loading = ref(false)
const activeTab = ref('all')
const evalVisible = ref(false)
const evalSubmitting = ref(false)
const evalOrder = ref<OrderItem | null>(null)
const evalScore = ref(5)
const evalContent = ref('')

const tabs = [
  { key: 'all', label: '全部' },
  { key: 'unpaid', label: '待付款' },
  { key: 'processing', label: '处理中' },
  { key: 'pickup', label: '待上门取衣' },
  { key: 'received', label: '待支付' },
  { key: 'done', label: '已完成' },
]

const filteredList = computed(() => {
  const data = list.value
  if (activeTab.value === 'all') return data
  if (activeTab.value === 'unpaid') return data.filter((o) => o.payStatus === 'UNPAID')
  if (activeTab.value === 'processing') return data.filter((o) => o.payStatus !== 'UNPAID' && !['COMPLETED', 'CANCELLED', 'AWAIT_PICKUP'].includes(o.status))
  if (activeTab.value === 'pickup') return data.filter((o) => o.status === 'AWAIT_PICKUP')
  if (activeTab.value === 'received') return data.filter((o) => o.payStatus === 'PAID' && o.status !== 'COMPLETED')
  if (activeTab.value === 'done') return data.filter((o) => o.status === 'COMPLETED')
  return data
})

function orderName(o: OrderItem) {
  return o.orderType === 'PRODUCT' ? (o.productName || '商城商品') : (o.serviceName || '干洗服务')
}
function orderImage(o: OrderItem) {
  return o.orderType === 'PRODUCT' ? o.productImage : o.serviceImage
}

function goDetail(id: number) {
  uni.navigateTo({
    url: '/pages/order/detail?id=' + id,
    fail: (err) => {
      uni.showToast({ title: (err && err.errMsg) || '打开订单详情失败', icon: 'none' })
    },
  })
}

function goService() {
  uni.switchTab({ url: '/pages/service/list' })
}

function statusText(order: OrderItem) {
  if (order.payStatus === 'UNPAID' || order.status === 'PENDING') return '待付款'
  if (order.status === 'CANCELLED') return '已取消'
  if (order.status === 'COMPLETED') return order.orderType === 'PRODUCT' ? '交易完成' : '已完成'
  const map: Record<string, string> = {
    AWAIT_PICKUP: '待上门取衣', WASHING: '清洁中', READY_PICKUP: '待自提', DELIVERING: '送回途中', SHIPPING: '配送中',
  }
  return map[order.status] || '处理中'
}

async function load() {
  if (!requireLogin('/pages/order/list')) return
  loading.value = true
  try { list.value = await myOrders() } catch {}
  loading.value = false
}

async function cancel(id: number) {
  try {
    await cancelOrder(id)
    uni.showToast({ title: '已取消', icon: 'success' })
    load()
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

async function pay(orderId: number) {
  try {
    const p = await createPayment(orderId)
    uni.navigateTo({ url: `/pages/order/pay?paymentId=${p.id}` })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

function openEval(order: OrderItem) {
  evalOrder.value = order
  evalScore.value = 5
  evalContent.value = ''
  evalVisible.value = true
}

async function submitEval() {
  if (!evalOrder.value) return
  evalSubmitting.value = true
  try {
    await createComment(evalOrder.value.id, evalContent.value, evalScore.value)
    evalVisible.value = false
    uni.showToast({ title: '评价成功', icon: 'success' })
    load()
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  } finally {
    evalSubmitting.value = false
  }
}

onShow(load)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 0 22rpx 40rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f8fbff 0%, #f4f7fb 100%);
}
.tabs {
  position: sticky;
  top: 0;
  z-index: 5;
  white-space: nowrap;
  margin: 0 -22rpx 20rpx;
  padding: 0 22rpx;
  background: #fff;
  border-bottom: 1rpx solid #edf1f7;
}
.tab {
  position: relative;
  display: inline-block;
  padding: 28rpx 28rpx 24rpx;
  color: #687386;
  font-size: 27rpx;
  font-weight: 500;
}
.tab.active {
  color: #2474ff;
  font-weight: 800;
}
.tab.active::after {
  content: '';
  position: absolute;
  left: 50%;
  bottom: 0;
  width: 54rpx;
  height: 6rpx;
  border-radius: 8rpx;
  background: #2474ff;
  transform: translateX(-50%);
}
.order-card {
  padding: 28rpx;
  margin-bottom: 18rpx;
  border-radius: 18rpx;
  background: #fff;
  box-shadow: 0 10rpx 32rpx rgba(32, 93, 168, 0.07);
}
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #a0a8b5;
  font-size: 25rpx;
  margin-bottom: 18rpx;
}
.status {
  color: #1683ff;
  font-size: 27rpx;
  font-weight: 700;
}
.body {
  position: relative;
  display: flex;
  gap: 22rpx;
  min-height: 132rpx;
  padding-right: 36rpx;
  margin-bottom: 16rpx;
}
.body::after {
  content: '›';
  position: absolute;
  right: 4rpx;
  top: 42rpx;
  color: #c1c8d2;
  font-size: 52rpx;
  line-height: 1;
}
.thumb {
  width: 124rpx;
  height: 124rpx;
  border-radius: 10rpx;
  flex-shrink: 0;
  background: #f5f7fa;
}
.thumb.ph {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  color: #909399;
}
.info {
  flex: 1;
  min-width: 0;
}
.name {
  display: block;
  color: #111827;
  font-size: 28rpx;
  font-weight: 600;
  line-height: 1.4;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 10rpx;
}
.qty {
  display: block;
  color: #7b8798;
  font-size: 25rpx;
  margin-bottom: 12rpx;
}
.price {
  display: block;
  color: #ff3b30;
  font-size: 28rpx;
  font-weight: 800;
}
.foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #687386;
  font-size: 27rpx;
}
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 18rpx;
}
.actions button {
  width: 128rpx;
  height: 58rpx;
  line-height: 58rpx;
  padding: 0;
  border-radius: 10rpx;
  font-size: 25rpx;
}
.actions button[type='primary'] {
  background: linear-gradient(135deg, #35cf59, #19b63f);
}
.mask {
  position: fixed;
  inset: 0;
  z-index: 30;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
}
.dialog { width: 100%; background: #fff; border-radius: 16rpx; padding: 32rpx; }
.dialog-title { font-size: 32rpx; font-weight: 600; display: block; margin-bottom: 20rpx; }
.stars text { font-size: 48rpx; color: #dcdfe6; margin-right: 8rpx; }
.stars text.on { color: #f7ba2a; }
.textarea { width: 100%; min-height: 160rpx; background: #f5f7fa; border-radius: 8rpx; padding: 16rpx; margin: 20rpx 0; box-sizing: border-box; }
.empty-wrap {
  padding: 120rpx 24rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24rpx;
  color: #909399;
  font-size: 28rpx;
}
.empty-title { color: #909399; }
.empty-btn {
  width: 230rpx;
  height: 72rpx;
  line-height: 72rpx;
  border-radius: 999rpx;
  color: #fff;
  background: #2474ff;
  font-size: 28rpx;
}
.empty-btn::after { border: 0; }
</style>
