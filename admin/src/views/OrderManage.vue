<template>
  <el-card shadow="hover">
    <template #header>
      <span>订单列表</span>
      <span class="header-tip">履约状态须按顺序点击「下一步」推进，不可跳步</span>
    </template>
    <div class="filter-row">
      <el-input
        v-model="searchKeyword"
        placeholder="订单编号 / 用户 / 手机号 / 服务"
        clearable
        class="search-input"
        @keyup.enter="applySearch"
      >
        <template #append>
          <el-button :icon="Search" @click="applySearch">搜索</el-button>
        </template>
      </el-input>
      <el-select v-model="statusFilter" placeholder="全部状态" clearable class="filter-select" @change="applySearch">
        <el-option label="待付款" value="PENDING" />
        <el-option label="待取衣(上门)" value="AWAIT_PICKUP" />
        <el-option label="待交衣(到店)" value="AWAIT_DROP" />
        <el-option label="已取衣/已收衣" value="PICKED" />
        <el-option label="已收衣(店)" value="RECEIVED" />
        <el-option label="清洁中" value="WASHING" />
        <el-option label="待送回" value="READY_RETURN" />
        <el-option label="送回中" value="RETURNING" />
        <el-option label="待自提" value="READY_PICKUP" />
        <el-option label="待发货(商品)" value="AWAIT_SHIP" />
        <el-option label="配送中" value="SHIPPING" />
        <el-option label="已完成" value="COMPLETED" />
        <el-option label="已取消" value="CANCELLED" />
      </el-select>
      <el-select v-model="query.orderType" placeholder="订单类型" clearable class="filter-select" @change="applySearch">
        <el-option label="干洗服务订单" value="SERVICE" />
        <el-option label="商品购买订单" value="PRODUCT" />
      </el-select>
      <el-select v-model="query.deliveryType" placeholder="配送方式" clearable class="filter-select" @change="applySearch">
        <el-option label="上门取送" value="DOOR_TO_DOOR" />
        <el-option label="到店自取" value="IN_STORE" />
      </el-select>
    </div>
    <el-table v-loading="loading" :data="list" stripe>
      <el-table-column prop="orderNo" label="订单编号" width="160" />
      <el-table-column prop="userName" label="用户" width="80" />
      <el-table-column prop="userPhone" label="手机号" width="110" />
      <el-table-column prop="serviceName" label="服务" min-width="120" />
      <el-table-column prop="orderType" label="订单类型" width="110">
        <template #default="{ row }">{{ row.orderType === 'PRODUCT' ? '商品订单' : '干洗服务订单' }}</template>
      </el-table-column>
      <el-table-column prop="quantity" label="数量" width="70" align="center" />
      <el-table-column prop="totalPrice" label="金额" width="90" align="right">
        <template #default="{ row }">¥{{ row.totalPrice }}</template>
      </el-table-column>
      <el-table-column prop="deliveryType" label="配送" width="90">
        <template #default="{ row }">{{ row.deliveryType === 'IN_STORE' ? '到店自取' : '上门取送' }}</template>
      </el-table-column>
      <el-table-column prop="storeName" label="门店" width="100" show-overflow-tooltip />
      <el-table-column prop="status" label="当前状态" width="120">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)">{{ statusText(row) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="payStatus" label="支付" width="80">
        <template #default="{ row }">{{ payStatusText(row.payStatus) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="280" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link @click="openDetail(row)">查看</el-button>
          <el-button
            v-if="advancePreview(row)"
            type="primary"
            size="small"
            :loading="advancingId === row.id"
            @click="doAdvance(row)"
          >
            下一步：{{ advancePreview(row) }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      v-model:current-page="page"
      v-model:page-size="size"
      :page-sizes="[10, 20, 50, 100]"
      :total="total"
      layout="total, sizes, prev, pager, next"
      style="margin-top: 16px"
      @current-change="loadList"
      @size-change="onSizeChange"
    />
    <el-empty v-if="!loading && !list.length" description="暂无订单" />

    <el-dialog v-model="detailVisible" title="订单详情" width="520px">
      <template v-if="currentOrder">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单编号">{{ currentOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="用户">{{ currentOrder.userName }} {{ currentOrder.userPhone }}</el-descriptions-item>
          <el-descriptions-item label="服务">{{ currentOrder.serviceName }}</el-descriptions-item>
          <el-descriptions-item label="订单类型">{{ currentOrder.orderType === 'PRODUCT' ? '商品订单' : '干洗服务订单' }}</el-descriptions-item>
          <el-descriptions-item label="数量">{{ currentOrder.quantity }}</el-descriptions-item>
          <el-descriptions-item label="金额">¥{{ currentOrder.totalPrice }}</el-descriptions-item>
          <el-descriptions-item label="配送方式">{{ currentOrder.deliveryType === 'IN_STORE' ? '到店自取' : '上门取送' }}</el-descriptions-item>
          <el-descriptions-item label="门店">{{ currentOrder.storeName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="当前状态">{{ statusText(currentOrder) }}</el-descriptions-item>
          <el-descriptions-item v-if="advancePreview(currentOrder)" label="下一可操作">
            可推进为「{{ advancePreview(currentOrder) }}」
          </el-descriptions-item>
          <el-descriptions-item label="支付状态">{{ payStatusText(currentOrder.payStatus) }}</el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ currentOrder.createdAt }}</el-descriptions-item>
          <el-descriptions-item v-if="currentOrder.remark" label="备注">{{ currentOrder.remark }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="advancePreview(currentOrder)" style="margin-top: 16px">
          <el-button type="primary" :loading="advancingId === currentOrder.id" @click="doAdvance(currentOrder)">
            推进下一步：{{ advancePreview(currentOrder) }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { getOrderList, advanceOrder, type OrderItem, type OrderListRes } from '@/api/order'

const list = ref<OrderItem[]>([])
const loading = ref(false)
const total = ref(0)
const page = ref(1)
const size = ref(20)
const statusFilter = ref<string>('')
const searchKeyword = ref('')
const query = reactive({
  orderType: '',
  deliveryType: '',
})
const advancingId = ref<number | null>(null)

function applySearch() {
  page.value = 1
  loadList()
}

function onSizeChange() {
  page.value = 1
  loadList()
}

function loadList() {
  loading.value = true
  const kw = searchKeyword.value?.trim() || undefined
  getOrderList({
    page: page.value - 1,
    size: size.value,
    keyword: kw,
    orderType: query.orderType || undefined,
    deliveryType: query.deliveryType || undefined,
    status: statusFilter.value || undefined,
  })
    .then((res: any) => {
      const data = res as OrderListRes
      const content = data?.content ?? (Array.isArray(data) ? data : [])
      list.value = content
      total.value = data?.totalElements ?? (Array.isArray(data) ? data.length : 0)
    })
    .catch(() => {
      list.value = []
      total.value = 0
    })
    .finally(() => {
      loading.value = false
    })
}

/** 与后端 OrderService.computeNextFulfillmentStatus 一致，用于按钮文案 */
function nextStepCode(row: OrderItem): string | null {
  const s = row.status
  if (row.payStatus !== 'PAID' || s === 'CANCELLED' || s === 'COMPLETED') return null

  if (row.orderType === 'PRODUCT') {
    if (s === 'AWAIT_SHIP') return 'SHIPPING'
    if (s === 'SHIPPING') return 'COMPLETED'
    return null
  }

  const inStore = row.deliveryType === 'IN_STORE'
  if (inStore) {
    if (s === 'AWAIT_DROP') return 'RECEIVED'
    if (s === 'RECEIVED') return 'WASHING'
    if (s === 'WASHING') return 'READY_PICKUP'
    if (s === 'READY_PICKUP') return 'COMPLETED'
    return null
  }

  if (s === 'PICKUP' || s === 'AWAIT_PICKUP') return 'PICKED'
  if (s === 'PICKED') return 'WASHING'
  if (s === 'WASHING') return 'READY_RETURN'
  if (s === 'READY' || s === 'READY_RETURN') return 'RETURNING'
  if (s === 'DELIVERING' || s === 'RETURNING') return 'COMPLETED'
  if (s === 'DELIVERED') return 'COMPLETED'
  return null
}

const nextLabelMap: Record<string, string> = {
  PICKED: '已取衣',
  RECEIVED: '已收衣',
  WASHING: '清洁中',
  READY_RETURN: '待送回',
  RETURNING: '送回中',
  READY_PICKUP: '待自提',
  COMPLETED: '已完成',
  SHIPPING: '配送中',
}

function advancePreview(row: OrderItem | null): string | null {
  if (!row) return null
  const code = nextStepCode(row)
  if (!code) return null
  return nextLabelMap[code] || code
}

function doAdvance(row: OrderItem) {
  const label = advancePreview(row)
  ElMessageBox.confirm(`确认将订单推进为「${label}」？`, '推进状态', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消',
  })
    .then(() => {
      advancingId.value = row.id
      return advanceOrder(row.id)
    })
    .then((updated: OrderItem) => {
      ElMessage.success('已推进到下一步')
      if (currentOrder.value?.id === row.id && updated) currentOrder.value = { ...currentOrder.value, ...updated }
      loadList()
    })
    .catch((e: any) => {
      if (e !== 'cancel') {
        ElMessage.error(e?.response?.data?.message || e?.message || '操作失败')
      }
    })
    .finally(() => {
      advancingId.value = null
    })
}

function statusTagType(st: string) {
  const map: Record<string, string> = {
    PENDING: 'warning',
    AWAIT_PICKUP: 'warning',
    AWAIT_DROP: 'warning',
    AWAIT_SHIP: 'warning',
    PICKUP: 'warning',
    PICKED: 'primary',
    RECEIVED: 'primary',
    WASHING: 'primary',
    READY: 'primary',
    READY_RETURN: 'primary',
    READY_PICKUP: 'success',
    DELIVERING: 'primary',
    RETURNING: 'primary',
    DELIVERED: 'success',
    SHIPPING: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'info',
  }
  return map[st] || 'info'
}

function statusText(row: OrderItem | { status: string; orderType?: string; deliveryType?: string }) {
  const s = row.status
  const orderType = (row.orderType || 'SERVICE') === 'PRODUCT' ? 'PRODUCT' : 'SERVICE'
  const isInStore = orderType === 'SERVICE' && row.deliveryType === 'IN_STORE'
  const map: Record<string, string> = {
    PENDING: '待付款',
    AWAIT_PICKUP: '待取衣',
    // 干洗服务：到店自取需要“交衣到门店”这一步
    AWAIT_DROP: isInStore ? '待交衣(到店)' : '待送洗(请顾客送衣到店)',
    AWAIT_SHIP: '待发货',
    PICKUP: '待取衣',
    PICKED: '已取衣',
    RECEIVED: '已收衣',
    WASHING: '清洁中',
    READY: '待送回',
    READY_RETURN: '待送回',
    READY_PICKUP: isInStore ? '待自提' : '待到店取衣',
    DELIVERING: '送回中',
    RETURNING: '送回中',
    DELIVERED: '已送达',
    SHIPPING: '配送中',
    COMPLETED: '已完成',
    CANCELLED: '已取消',
  }
  return map[s] || s
}

function payStatusText(s: string) {
  const map: Record<string, string> = {
    UNPAID: '未支付',
    PAID: '已支付',
    REFUNDED: '已退款',
  }
  return map[s] || s
}

const detailVisible = ref(false)
const currentOrder = ref<OrderItem | null>(null)
function openDetail(row: OrderItem) {
  currentOrder.value = row
  detailVisible.value = true
}

onMounted(loadList)
</script>

<style scoped>
.filter-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.filter-row :deep(.el-input__inner),
.filter-row :deep(.el-select__placeholder),
.filter-row :deep(.el-input__wrapper),
.filter-row :deep(.el-select__wrapper) {
  font-size: 20px;
}
.search-input {
  width: 320px;
  max-width: 100%;
}
.filter-select {
  width: 150px;
}
.header-tip {
  float: right;
  font-size: 18px;
  color: #909399;
  font-weight: normal;
}

:deep(.el-card__header) {
  font-size: 28px;
  font-weight: 600;
}

:deep(.el-table th .cell) {
  font-size: 20px;
  font-weight: 600;
}

:deep(.el-table .cell) {
  font-size: 19px;
}

:deep(.el-tag) {
  font-size: 18px;
  padding: 0 14px;
  height: 36px;
  line-height: 34px;
}

:deep(.el-button) {
  font-size: 18px;
}

:deep(.el-button--small) {
  font-size: 18px;
  padding: 12px 18px;
  height: auto;
}

:deep(.el-pagination) {
  font-size: 19px;
}
</style>
