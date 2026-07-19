<template>
  <div class="orders-section">
    <!-- 评价弹窗 -->
    <el-dialog
      v-model="evalVisible"
      :title="(evalOrder?.orderType || 'SERVICE') === 'PRODUCT' ? '评价商品' : '评价服务'"
      width="420px"
      :close-on-click-modal="false"
      destroy-on-close
      @closed="onEvalClosed"
    >
      <el-form :model="evalForm" label-width="80px">
        <el-form-item label="评分">
          <el-rate v-model="evalForm.score" :max="5" show-text />
        </el-form-item>
        <el-form-item label="评价内容">
          <el-input v-model="evalForm.content" type="textarea" :rows="4" placeholder="选填，分享您的体验" maxlength="500" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="evalVisible = false">取消</el-button>
        <el-button type="primary" :loading="evalSubmitting" @click="submitEval">提交评价</el-button>
      </template>
    </el-dialog>
    <div class="section-header">
      <h2 class="section-title">我的订单</h2>
    </div>

    <!-- Tab 筛选 -->
    <div class="order-tabs">
      <div
        v-for="tab in tabs"
        :key="tab.key"
        class="tab-item"
        :class="{ active: activeTab === tab.key }"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </div>
    </div>

    <div v-loading="loading" class="order-list">
      <template v-if="filteredList.length">
        <div v-for="order in filteredList" :key="order.id" class="order-card">
          <div class="order-card-head">
            <span class="order-time">{{ formatTime(order.createdAt) }}</span>
            <span class="order-status-wrap">
              <span class="order-status">{{ statusText(order) }}</span>
              <el-icon v-if="isCompleted(order)" class="delete-icon" @click="removeOrder(order.id)">
                <Delete />
              </el-icon>
            </span>
          </div>
          <div class="order-card-body">
            <div class="order-item">
              <div class="item-img">
                <img
                  v-if="(order.orderType || 'SERVICE') === 'PRODUCT' ? order.productImage : order.serviceImage"
                  :src="(order.orderType || 'SERVICE') === 'PRODUCT' ? order.productImage : order.serviceImage"
                  :alt="(order.orderType || 'SERVICE') === 'PRODUCT' ? order.productName : order.serviceName"
                />
                <div v-else class="item-img-placeholder">{{ (order.orderType || 'SERVICE') === 'PRODUCT' ? '商品' : '服务' }}</div>
              </div>
              <div class="item-info">
                <div class="item-name">
                  {{ (order.orderType || 'SERVICE') === 'PRODUCT' ? (order.productName || '商城商品') : (order.serviceName || '干洗服务') }}
                </div>
                <div class="item-spec">数量: {{ order.quantity }} 件</div>
                <div class="item-price">¥{{ order.totalPrice }}</div>
              </div>
            </div>
          </div>
          <div class="order-card-foot">
            <span class="order-summary">共 {{ order.quantity }} 件商品 实付款 <em>¥{{ order.totalPrice }}</em></span>
            <div class="order-actions">
              <template v-if="order.payStatus === 'UNPAID' && !isCancelled(order)">
                <el-button size="small" @click="cancel(order.id)">取消订单</el-button>
                <el-button type="primary" size="small" @click="pay(order.id)">去支付</el-button>
              </template>
              <el-button
                v-else-if="
                  isCompleted(order) &&
                  !order.hasComment &&
                  ((order.orderType || 'SERVICE') === 'PRODUCT' ? !!order.productId : !!order.serviceId)
                "
                size="small"
                @click="onEvaluate(order)"
              >
                {{ (order.orderType || 'SERVICE') === 'PRODUCT' ? '评价商品' : '评价服务' }}
              </el-button>
            </div>
          </div>
        </div>
      </template>
      <el-empty v-else description="暂无订单" class="order-empty" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Delete } from '@element-plus/icons-vue'
import { myOrders, cancelOrder } from '@/api/order'
import { createPayment } from '@/api/payment'
import { createComment } from '@/api/comment'
import type { OrderItem } from '@/api/order'

const router = useRouter()
const list = ref<OrderItem[]>([])
const loading = ref(false)
const activeTab = ref('all')
const evalVisible = ref(false)
const evalSubmitting = ref(false)
const evalOrder = ref<OrderItem | null>(null)
const evalForm = ref({ score: 5, content: '' })

const tabs = [
  { key: 'all', label: '全部' },
  { key: 'unpaid', label: '待付款' },
  { key: 'received', label: '待收货' },
  { key: 'done', label: '已完成' },
  { key: 'cancelled', label: '已取消' },
]

const filteredList = computed(() => {
  const data = list.value
  if (activeTab.value === 'all') return data
  if (activeTab.value === 'unpaid') return data.filter((o) => o.payStatus === 'UNPAID')
  if (activeTab.value === 'received') return data.filter((o) => o.payStatus === 'PAID' && o.status !== 'COMPLETED')
  if (activeTab.value === 'done') return data.filter((o) => o.status === 'COMPLETED')
  if (activeTab.value === 'cancelled') return data.filter((o) => (o.status as string) === 'CANCELLED')
  return data
})

function formatTime(val: string | undefined) {
  if (!val) return ''
  return val.replace('T', ' ').slice(0, 19)
}

function statusText(order: OrderItem) {
  if (order.payStatus === 'UNPAID' || order.status === 'PENDING') return '待付款'
  if (order.status === 'CANCELLED') return '已取消'
  if (order.status === 'COMPLETED') return (order.orderType || 'SERVICE') === 'PRODUCT' ? '交易完成' : '已完成'

  const isInStore = (order.orderType || 'SERVICE') === 'SERVICE' && order.deliveryType === 'IN_STORE'

  const map: Record<string, string> = {
    AWAIT_PICKUP: '待上门取衣',
    // 干洗服务：到店自取需要“交衣到门店”这一步
    AWAIT_DROP: isInStore ? '待交衣(到店)' : '待送衣到店',
    AWAIT_SHIP: '待发货',
    PICKUP: '待上门取衣',
    PICKED: '已取衣，洗护中',
    RECEIVED: '已收衣',
    WASHING: '清洁中',
    READY: '待送回',
    READY_RETURN: '待送回',
    // 干洗服务：到店自提
    READY_PICKUP: isInStore ? '待自提(到店取衣)' : '待到店取衣',
    DELIVERING: '送回途中',
    RETURNING: '送回途中',
    DELIVERED: '已送达',
    SHIPPING: '商品配送中',
  }

  return map[order.status] || '处理中'
}

function isCompleted(order: OrderItem) {
  return order.status === 'COMPLETED'
}

function isCancelled(order: OrderItem) {
  return order.status === 'CANCELLED'
}

function removeOrder(_id: number) {
  ElMessage.info('删除订单功能可后续对接接口')
}

function onEvaluate(order: OrderItem) {
  evalOrder.value = order
  evalForm.value = { score: 5, content: '' }
  evalVisible.value = true
}

function onEvalClosed() {
  evalOrder.value = null
  evalForm.value = { score: 5, content: '' }
}

async function submitEval() {
  const order = evalOrder.value
  if (!order) return
  evalSubmitting.value = true
  try {
    await createComment(order.id, evalForm.value.content || '', evalForm.value.score)
    ElMessage.success('评价成功')
    evalVisible.value = false
    load()
  } catch (e: any) {
    const msg = e?.response?.data?.message || e?.message || '评价失败'
    ElMessage.error(msg)
  } finally {
    evalSubmitting.value = false
  }
}

async function load() {
  loading.value = true
  try {
    list.value = await myOrders(0, 50)
  } catch (e: any) {
    if (e?.response?.status === 401 || e?.response?.status === 403) {
      ElMessage.warning('请先登录')
      router.push('/home/login')
    }
  } finally {
    loading.value = false
  }
}

async function pay(orderId: number) {
  try {
    const payment = await createPayment(orderId)
    router.push({ path: '/home/user/order/pay', query: { paymentId: String(payment.id) } })
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '创建支付单失败')
  }
}

async function cancel(orderId: number) {
  try {
    await cancelOrder(orderId)
    ElMessage.success('订单已取消')
    load()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '取消失败')
  }
}

onMounted(load)
</script>

<style scoped>
.orders-section {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 26px;
}
.section-header { margin-bottom: 20px; }
.section-title {
  font-size: 40px;
  font-weight: 600;
  color: #303133;
  text-align: center;
  margin: 0;
}

.order-tabs {
  display: flex;
  gap: 0;
  border-bottom: 1px solid #e4e7ed;
  margin-bottom: 20px;
}
.tab-item {
  padding: 16px 28px;
  font-size: 28px;
  color: #606266;
  cursor: pointer;
  position: relative;
}
.tab-item:hover { color: #409eff; }
.tab-item.active {
  color: #f56c6c;
  font-weight: 500;
}
.tab-item.active::after {
  content: '';
  position: absolute;
  left: 24px;
  right: 24px;
  bottom: -1px;
  height: 2px;
  background: #f56c6c;
}

.order-list { min-height: 120px; }
.order-empty { padding: 40px 0; }

.order-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  margin-bottom: 16px;
  overflow: hidden;
}
.order-card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #fafafa;
  border-bottom: 1px solid #ebeef5;
}
.order-time { font-size: 24px; color: #909399; }
.order-status-wrap { display: flex; align-items: center; gap: 8px; }
.order-status { font-size: 28px; color: #303133; }
.delete-icon { cursor: pointer; color: #909399; font-size: 28px; }
.delete-icon:hover { color: #f56c6c; }

.order-card-body { padding: 20px; }
.order-item {
  display: flex;
  gap: 20px;
}
.item-img {
  width: 120px;
  height: 120px;
  border-radius: 6px;
  overflow: hidden;
  background: #f5f7fa;
  flex-shrink: 0;
}
.item-img img { width: 100%; height: 100%; object-fit: cover; }
.item-img-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  color: #909399;
}
.item-info { flex: 1; min-width: 0; }
.item-name { font-size: 30px; color: #303133; margin-bottom: 8px; }
.item-spec { font-size: 24px; color: #909399; margin-bottom: 6px; }
.item-price { font-size: 32px; color: #f56c6c; font-weight: 600; }

.order-card-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-top: 1px solid #f0f0f0;
  background: #fafafa;
}
.order-summary { font-size: 24px; color: #606266; }
.order-summary em { color: #f56c6c; font-weight: 600; font-style: normal; margin-left: 4px; }
.order-actions { flex-shrink: 0; }
.order-actions :deep(.el-button) {
  font-size: 24px;
  padding: 12px 20px;
}
.order-actions :deep(.el-button.el-button--small) {
  font-size: 24px !important;
  padding: 12px 20px !important;
  height: auto !important;
}
</style>
