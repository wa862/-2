<template>
  <div class="order-detail-page">
    <div class="detail-header">
      <el-button text class="back-btn" @click="router.back()">返回</el-button>
      <h2>订单详情</h2>
    </div>

    <el-skeleton v-if="loading" :rows="6" animated />

    <template v-else-if="order">
      <section class="status-card">
        <div>
          <div class="status-label">当前状态</div>
          <div class="status-text">{{ statusText(order) }}</div>
        </div>
        <el-tag :type="order.payStatus === 'PAID' ? 'success' : order.status === 'CANCELLED' ? 'info' : 'warning'" size="large">
          {{ order.payStatus === 'PAID' ? '已支付' : order.status === 'CANCELLED' ? '已取消' : '待支付' }}
        </el-tag>
      </section>

      <section class="detail-section">
        <h3>订单商品</h3>
        <div class="goods-row">
          <div class="goods-img">
            <img v-if="itemImage" :src="itemImage" :alt="itemName" />
            <div v-else class="goods-placeholder">{{ itemTypeText }}</div>
          </div>
          <div class="goods-info">
            <div class="goods-name">{{ itemName }}</div>
            <div class="goods-meta">{{ itemTypeText }} · 数量 {{ order.quantity }} 件</div>
            <div v-if="order.remark" class="goods-remark">备注：{{ order.remark }}</div>
          </div>
          <div class="goods-price">¥{{ order.totalPrice }}</div>
        </div>
      </section>

      <section class="detail-section">
        <h3>订单信息</h3>
        <div class="info-grid">
          <div class="info-row">
            <span>订单编号</span>
            <strong>{{ order.orderNo }}</strong>
          </div>
          <div class="info-row">
            <span>下单时间</span>
            <strong>{{ formatTime(order.createdAt) }}</strong>
          </div>
          <div class="info-row">
            <span>配送方式</span>
            <strong>{{ deliveryText(order.deliveryType) }}</strong>
          </div>
          <div v-if="order.pickupDate" class="info-row">
            <span>预约时间</span>
            <strong>{{ formatTime(order.pickupDate) }}</strong>
          </div>
          <div v-if="order.payTime" class="info-row">
            <span>支付时间</span>
            <strong>{{ formatTime(order.payTime) }}</strong>
          </div>
          <div class="info-row total-row">
            <span>实付款</span>
            <strong>¥{{ order.totalPrice }}</strong>
          </div>
        </div>
      </section>

      <div class="detail-actions">
        <el-button v-if="order.payStatus === 'UNPAID' && order.status !== 'CANCELLED'" @click="cancel">取消订单</el-button>
        <el-button v-if="order.payStatus === 'UNPAID' && order.status !== 'CANCELLED'" type="primary" @click="pay">去支付</el-button>
      </div>
    </template>

    <el-empty v-else description="订单不存在" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { cancelOrder, getOrderDetail, myOrders } from '@/api/order'
import { createPayment } from '@/api/payment'
import type { OrderItem } from '@/api/order'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref<OrderItem | null>(null)

const itemTypeText = computed(() => (order.value?.orderType || 'SERVICE') === 'PRODUCT' ? '商品' : '服务')
const itemName = computed(() => {
  const current = order.value
  if (!current) return ''
  return (current.orderType || 'SERVICE') === 'PRODUCT'
    ? current.productName || '商城商品'
    : current.serviceName || '干洗服务'
})
const itemImage = computed(() => {
  const current = order.value
  if (!current) return ''
  return (current.orderType || 'SERVICE') === 'PRODUCT' ? current.productImage : current.serviceImage
})

function formatTime(val?: string) {
  if (!val) return '-'
  return val.replace('T', ' ').slice(0, 19)
}

function deliveryText(type?: string) {
  if (type === 'IN_STORE') return '到店办理'
  if (type === 'PICKUP') return '上门取送'
  return '上门取送'
}

function statusText(current: OrderItem) {
  if (current.payStatus === 'UNPAID' || current.status === 'PENDING') return '待付款'
  if (current.status === 'CANCELLED') return '已取消'
  if (current.status === 'COMPLETED') return (current.orderType || 'SERVICE') === 'PRODUCT' ? '交易完成' : '已完成'
  const map: Record<string, string> = {
    AWAIT_PICKUP: '待上门取衣',
    AWAIT_DROP: current.deliveryType === 'IN_STORE' ? '待交衣到店' : '待送衣到店',
    PICKED: '已取衣，洗护中',
    WASHING: '清洁中',
    READY: '待送回',
    READY_PICKUP: '待自提',
    DELIVERING: '送回途中',
    DELIVERED: '已送达',
    SHIPPING: '商品配送中',
  }
  return map[current.status] || '处理中'
}

async function load() {
  const id = Number(route.params.id)
  if (!id) return
  loading.value = true
  try {
    order.value = await getOrderDetail(id)
  } catch {
    const list = await myOrders(0, 100)
    order.value = list.find((item) => item.id === id) || null
  } finally {
    loading.value = false
  }
}

async function pay() {
  if (!order.value) return
  try {
    const payment = await createPayment(order.value.id)
    router.push({ path: '/home/user/order/pay', query: { paymentId: String(payment.id) } })
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '创建支付单失败')
  }
}

async function cancel() {
  if (!order.value) return
  try {
    await cancelOrder(order.value.id)
    ElMessage.success('订单已取消')
    load()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '取消失败')
  }
}

onMounted(load)
</script>

<style scoped>
.order-detail-page {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 16px;
}
.detail-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}
.detail-header h2 {
  margin: 0;
  font-size: 32px;
  color: #303133;
}
.back-btn {
  font-size: 18px;
}
.status-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-radius: 8px;
  background: linear-gradient(135deg, #eef6ff, #ffffff);
  border: 1px solid #d8ecff;
  margin-bottom: 16px;
}
.status-label {
  color: #606266;
  font-size: 18px;
  margin-bottom: 8px;
}
.status-text {
  color: #303133;
  font-size: 32px;
  font-weight: 700;
}
.detail-section {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 16px;
}
.detail-section h3 {
  margin: 0 0 16px;
  font-size: 24px;
  color: #303133;
}
.goods-row {
  display: flex;
  align-items: center;
  gap: 20px;
}
.goods-img {
  width: 120px;
  height: 120px;
  flex-shrink: 0;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f7fa;
}
.goods-img img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.goods-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}
.goods-info {
  flex: 1;
  min-width: 0;
}
.goods-name {
  color: #303133;
  font-size: 26px;
  font-weight: 700;
  margin-bottom: 8px;
}
.goods-meta,
.goods-remark {
  color: #606266;
  font-size: 18px;
  line-height: 1.6;
}
.goods-price {
  color: #f56c6c;
  font-size: 30px;
  font-weight: 700;
}
.info-grid {
  display: grid;
  gap: 0;
}
.info-row {
  display: flex;
  justify-content: space-between;
  gap: 24px;
  padding: 14px 0;
  border-bottom: 1px solid #f0f0f0;
  color: #606266;
  font-size: 18px;
}
.info-row:last-child {
  border-bottom: none;
}
.info-row strong {
  color: #303133;
  font-weight: 500;
  text-align: right;
}
.total-row strong {
  color: #f56c6c;
  font-size: 24px;
  font-weight: 700;
}
.detail-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
