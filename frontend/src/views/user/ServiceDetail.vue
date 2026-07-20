<template>
  <div class="service-detail-page">
    <el-button link type="primary" @click="goBack" class="back">← 返回</el-button>

    <div v-if="loading" class="loading">
      <el-icon class="is-loading">
        <Loading />
      </el-icon>
      加载中...
    </div>

    <div v-else-if="service" class="detail-card">
      <div class="detail-img">
        <img v-if="service.image" :src="service.image" :alt="service.name" />
        <div v-else class="placeholder">暂无图片</div>
      </div>

      <div class="detail-info">
        <h1 class="detail-name">{{ service.name }}</h1>

        <div class="detail-price">
          <span>¥{{ unitPrice }}/件</span>
          <span v-if="parsedSpecs.length" class="price-rise">起</span>
        </div>

        <div v-if="service.cycle" class="detail-cycle">预计洗护周期：{{ service.cycle }}</div>

        <div v-if="parsedSpecs.length" class="detail-specs">
          <div class="label">规格（不同款不同价）</div>
          <el-radio-group v-model="selectedSpecName" class="spec-radio-group">
            <el-radio v-for="s in parsedSpecs" :key="s.name" :label="s.name" class="spec-radio">
              {{ s.name }} ¥{{ s.price }}/件
            </el-radio>
          </el-radio-group>
        </div>

        <div v-if="isFromCart" class="quantity-section">
          <div class="label">数量</div>
          <div class="quantity-wrap">
            <button type="button" class="qty-btn" :disabled="quantity <= 1" @click="quantity = Math.max(1, quantity - 1)">−</button>
            <span class="qty-num">{{ quantity }}</span>
            <button type="button" class="qty-btn" :disabled="quantity >= 99" @click="quantity = Math.min(99, quantity + 1)">+</button>
          </div>
        </div>

        <div v-if="service.description" class="detail-desc">{{ service.description }}</div>

        <CommentSection :target-type="'SERVICE'" :target-id="service.id" collapsed :preview-count="1" />

        <div class="detail-actions">
          <el-button v-if="isFromCart" type="primary" size="large" @click="updateCart">更新购物车</el-button>
          <el-button v-else type="primary" size="large" @click="goOrder">立即预约</el-button>
        </div>
      </div>
    </div>

    <el-empty v-else description="服务不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Loading } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getServiceList } from '@/api/service'
import { removeCartItem, addToCart } from '@/api/cart'
import CommentSection from '@/components/CommentSection.vue'
import type { ServiceItem as ServiceItemApi } from '@/api/service'

const route = useRoute()
const router = useRouter()

const serviceId = computed(() => Number(route.params.id))
const cartId = computed(() => Number(route.query.cartId))
const isFromCart = computed(() => cartId.value > 0)

const loading = ref(true)
const service = ref<ServiceItemApi | null>(null)
const quantity = ref(1)

type SpecOption = { name: string; price: number }
function parseServiceSpecs(raw?: string): SpecOption[] {
  if (!raw?.trim()) return []
  return raw
    .split(/[;,，]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => {
      const [name, priceStr] = part.split('|').map((s) => s.trim())
      const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
      if (!name || Number.isNaN(price) || price <= 0) return null
      return { name, price }
    })
    .filter((x): x is SpecOption => !!x)
}

const parsedSpecs = computed(() => parseServiceSpecs(service.value?.specs))
const selectedSpecName = ref('')

const unitPrice = computed(() => {
  const specs = parsedSpecs.value
  if (!service.value) return 0
  if (!specs.length) return Number(service.value.price) || 0
  const hit = specs.find((s) => s.name === selectedSpecName.value)
  return hit ? hit.price : specs[0].price
})

function syncSpecFromRoute() {
  const specs = parsedSpecs.value
  const q = route.query.specName
  const fromQ = typeof q === 'string' ? decodeURIComponent(q).trim() : ''
  if (specs.length) {
    if (fromQ && specs.some((s) => s.name === fromQ)) {
      selectedSpecName.value = fromQ
    } else if (!selectedSpecName.value || !specs.some((s) => s.name === selectedSpecName.value)) {
      selectedSpecName.value = specs[0].name
    }
  } else {
    selectedSpecName.value = ''
  }
}

function syncQuantityFromRoute() {
  const q = route.query.quantity
  if (typeof q === 'string') {
    quantity.value = Math.max(1, Math.min(99, Number(q) || 1))
  }
}

onMounted(async () => {
  const id = serviceId.value
  if (!id) return
  loading.value = true
  try {
    const list = await getServiceList()
    service.value = list.find((s) => s.id === id) || null
    if (service.value) {
      syncSpecFromRoute()
      syncQuantityFromRoute()
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '加载服务详情失败')
  } finally {
    loading.value = false
  }
})

function goBack() {
  if (isFromCart.value) {
    router.push('/home/user/cart')
  } else {
    router.push('/home/user/service')
  }
}

function goOrder() {
  if (!service.value) return
  const specs = parsedSpecs.value
  const specName = specs.length ? selectedSpecName.value : undefined
  router.push({
    path: '/home/user/order/create',
    query: {
      serviceId: String(service.value.id),
      ...(specName ? { specName } : {}),
      quantity: String(quantity.value),
    },
  })
}

async function updateCart() {
  if (!service.value || cartId.value <= 0) return
  loading.value = true
  try {
    await removeCartItem(cartId.value)
    await addToCart('SERVICE', undefined, service.value.id, quantity.value, selectedSpecName.value || undefined)
    ElMessage.success('购物车已更新')
    router.push('/home/user/cart')
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '更新失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.service-detail-page { background: #fff; padding: 24px; border-radius: 8px; }
.back { margin-bottom: 16px; }
.loading { padding: 40px; text-align: center; color: #909399; }
.detail-card { display: flex; gap: 40px; }
.detail-img { width: 400px; flex-shrink: 0; border-radius: 8px; overflow: hidden; background: #f5f7fa; }
.detail-img img { width: 100%; height: 100%; object-fit: contain; display: block; }
.detail-img .placeholder { height: 300px; display: flex; align-items: center; justify-content: center; color: #909399; }
.detail-info { flex: 1; }
.detail-name { font-size: 28px; margin-bottom: 12px; }
.detail-price { font-size: 32px; color: #ff4d4f; font-weight: bold; margin-bottom: 12px; display: flex; gap: 8px; align-items: baseline; }
.price-rise { font-size: 18px; color: #ff4d4f; font-weight: 500; }
.detail-cycle { color: #606266; margin-bottom: 14px; }
.detail-desc { color: #606266; line-height: 1.6; margin: 16px 0; }
.detail-specs { margin-bottom: 12px; }
.label { font-size: 18px; color: #909399; margin-bottom: 8px; }
.spec-radio-group { display: flex; flex-direction: column; gap: 8px; }
.spec-radio :deep(.el-radio) { margin-bottom: 8px; }
.spec-radio :deep(.el-radio__label) { font-size: 16px; }
.detail-actions { margin-top: 18px; }

.quantity-section { margin-bottom: 12px; }
.quantity-wrap {
  display: inline-flex;
  align-items: center;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  overflow: hidden;
  background: #FFF;
}
.qty-btn {
  width: 44px;
  height: 44px;
  border: none;
  background: #f5f7fa;
  color: #606266;
  font-size: 24px;
  cursor: pointer;
  transition: background 0.2s;
}
.qty-btn:hover:not(:disabled) { background: #ebeef5; }
.qty-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.qty-num {
  min-width: 48px;
  text-align: center;
  font-size: 24px;
  font-weight: 600;
  color: #303133;
}
</style>
