<template>
  <view class="page">
    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!order" class="empty-wrap">订单不存在</view>
    <view v-else>
      <view class="status-card">
        <text class="status">{{ statusText(order) }}</text>
        <text class="order-no">订单号：{{ order.orderNo }}</text>
      </view>

      <view class="card">
        <view class="goods">
          <image
            v-if="orderImage(order)"
            :src="resolveImageUrl(orderImage(order))"
            class="thumb"
            mode="aspectFill"
          />
          <view v-else class="thumb ph">{{ order.orderType === 'PRODUCT' ? '商品' : '服务' }}</view>
          <view class="goods-info">
            <text class="name">{{ orderName(order) }}</text>
            <text class="sub">数量：{{ order.quantity }}</text>
            <text class="price">¥{{ order.totalPrice }}</text>
          </view>
        </view>
      </view>

      <view class="card">
        <view class="row"><text>订单类型</text><text>{{ order.orderType === 'PRODUCT' ? '商城商品' : '干洗服务' }}</text></view>
        <view class="row"><text>支付状态</text><text>{{ payStatusText(order.payStatus) }}</text></view>
        <view class="row"><text>配送方式</text><text>{{ deliveryText(order.deliveryType) }}</text></view>
        <view v-if="order.pickupDate" class="row"><text>取衣日期</text><text>{{ order.pickupDate }}</text></view>
        <view class="row"><text>下单时间</text><text>{{ formatTime(order.createdAt) }}</text></view>
        <view v-if="order.remark" class="row remark"><text>备注</text><text>{{ order.remark }}</text></view>
      </view>

      <view class="card total-card">
        <text>实付款</text>
        <text class="total">¥{{ order.totalPrice }}</text>
      </view>

      <view class="actions">
        <button
          v-if="order.payStatus==='UNPAID' && order.status!=='CANCELLED'"
          @click="cancel(order.id)"
        >取消订单</button>
        <button
          v-if="order.payStatus==='UNPAID' && order.status!=='CANCELLED'"
          class="btn-primary"
          type="primary"
          @click="pay(order.id)"
        >去支付</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { cancelOrder, getOrderDetail, myOrders, type OrderItem } from '@/api/order'
import { createPayment } from '@/api/payment'
import { formatTime, resolveImageUrl, requireLogin } from '@/utils'

const orderId = ref(0)
const loading = ref(true)
const order = ref<OrderItem | null>(null)

onLoad((q) => {
  if (!requireLogin('/pages/order/list')) return
  orderId.value = Number((q && q.id) || 0)
  load()
})

function orderName(o: OrderItem) {
  return o.orderType === 'PRODUCT' ? (o.productName || '商城商品') : (o.serviceName || '干洗服务')
}

function orderImage(o: OrderItem) {
  return o.orderType === 'PRODUCT' ? o.productImage : o.serviceImage
}

function statusText(o: OrderItem) {
  if (o.payStatus === 'UNPAID' || o.status === 'PENDING') return '待付款'
  if (o.status === 'CANCELLED') return '已取消'
  if (o.status === 'COMPLETED') return o.orderType === 'PRODUCT' ? '交易完成' : '已完成'
  const map: Record<string, string> = {
    AWAIT_PICKUP: '待上门取衣',
    WASHING: '清洁中',
    READY_PICKUP: '待自提',
    DELIVERING: '送回途中',
    SHIPPING: '配送中',
  }
  return map[o.status] || '处理中'
}

function payStatusText(status: string) {
  if (status === 'PAID') return '已支付'
  if (status === 'UNPAID') return '未支付'
  return status || '-'
}

function deliveryText(type?: string) {
  if (type === 'DOOR_TO_DOOR') return '上门取送'
  if (type === 'IN_STORE') return '到店自取'
  return type || '-'
}

async function load() {
  if (!orderId.value) {
    loading.value = false
    return
  }
  loading.value = true
  try {
    order.value = await getOrderDetail(orderId.value)
  } catch {
    try {
      const list = await myOrders()
      order.value = list.find((item) => item.id === orderId.value) || null
    } catch {
      order.value = null
    }
  } finally {
    loading.value = false
  }
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

async function pay(id: number) {
  try {
    const p = await createPayment(id)
    uni.navigateTo({ url: `/pages/order/pay?paymentId=${p.id}` })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 22rpx 22rpx 44rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f8fbff 0%, #f4f7fb 100%);
}
.status-card {
  padding: 34rpx 30rpx;
  border-radius: 18rpx;
  background: linear-gradient(135deg, #4da2ff, #2474ff);
  color: #fff;
  margin-bottom: 18rpx;
  box-shadow: 0 12rpx 30rpx rgba(36, 116, 255, 0.22);
}
.status {
  display: block;
  font-size: 38rpx;
  font-weight: 800;
  margin-bottom: 12rpx;
}
.order-no {
  display: block;
  font-size: 25rpx;
  opacity: 0.9;
}
.card {
  padding: 28rpx;
  margin-bottom: 18rpx;
  border-radius: 18rpx;
  background: #fff;
  box-shadow: 0 10rpx 32rpx rgba(32, 93, 168, 0.07);
}
.goods {
  display: flex;
  gap: 22rpx;
}
.thumb {
  width: 136rpx;
  height: 136rpx;
  border-radius: 12rpx;
  background: #f5f7fa;
  flex-shrink: 0;
}
.thumb.ph {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  font-size: 24rpx;
}
.goods-info {
  flex: 1;
  min-width: 0;
}
.name {
  display: block;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
  line-height: 1.4;
  margin-bottom: 10rpx;
}
.sub {
  display: block;
  color: #7b8798;
  font-size: 25rpx;
  margin-bottom: 12rpx;
}
.price {
  display: block;
  color: #ff3b30;
  font-size: 30rpx;
  font-weight: 800;
}
.row {
  display: flex;
  justify-content: space-between;
  gap: 24rpx;
  padding: 18rpx 0;
  border-bottom: 1rpx solid #edf1f7;
  color: #687386;
  font-size: 27rpx;
}
.row text:last-child {
  color: #111827;
  text-align: right;
}
.row:last-child {
  border-bottom: none;
}
.remark {
  align-items: flex-start;
}
.total-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}
.total {
  color: #ff3b30;
  font-size: 38rpx;
  font-weight: 900;
}
.actions {
  display: flex;
  gap: 18rpx;
}
.actions button {
  flex: 1;
  height: 82rpx;
  line-height: 82rpx;
  border-radius: 14rpx;
  font-size: 28rpx;
}
.empty-wrap {
  padding: 120rpx 24rpx;
  text-align: center;
  color: #909399;
  font-size: 28rpx;
}
</style>
