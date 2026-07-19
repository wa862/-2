<template>
  <div class="service-detail-page">
    <el-button link type="primary" @click="$router.push('/home/user/service')" class="back">← 返回干洗服务</el-button>

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
          <span>¥{{ minPrice }}/件</span>
          <span v-if="parsedSpecs.length" class="price-rise">起</span>
        </div>

        <div class="detail-cycle" v-if="service.cycle">预计洗护周期：{{ service.cycle }}</div>

        <div v-if="parsedSpecs.length" class="detail-specs">
          <div class="label">规格（不同款不同价）</div>
          <div class="spec-list">
            <div v-for="s in parsedSpecs" :key="s.name" class="spec-item">
              <span class="spec-name">{{ s.name }}</span>
              <span class="spec-price">¥{{ s.price }}/件</span>
            </div>
          </div>
        </div>

        <div v-if="service.description" class="detail-desc">{{ service.description }}</div>

        <CommentSection :target-type="'SERVICE'" :target-id="service.id" collapsed :preview-count="1" />

        <div class="detail-actions">
          <el-button type="primary" size="large" @click="goOrder">立即预约</el-button>
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
import CommentSection from '@/components/CommentSection.vue'
import type { ServiceItem as ServiceItemApi } from '@/api/service'

const route = useRoute()
const router = useRouter()

const serviceId = computed(() => Number(route.params.id))

const loading = ref(true)
const service = ref<ServiceItemApi | null>(null)

type SpecOption = { name: string; price: number }
function parseServiceSpecs(raw?: string): SpecOption[] {
  if (!raw?.trim()) return []
  // 兼容 OrderCreate.vue 的写法：如 "长款|199,短款|149"
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

const minPrice = computed(() => {
  const specs = parsedSpecs.value
  if (specs.length) return Math.min(...specs.map((s) => s.price))
  return service.value?.price ?? 0
})

onMounted(async () => {
  const id = serviceId.value
  if (!id) return
  loading.value = true
  try {
    const list = await getServiceList()
    service.value = list.find((s) => s.id === id) || null
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '加载服务详情失败')
  } finally {
    loading.value = false
  }
})

function goOrder() {
  if (!service.value) return
  const specs = parsedSpecs.value
  const specName = specs.length ? specs[0].name : undefined
  router.push({
    path: '/home/user/order/create',
    query: {
      serviceId: String(service.value.id),
      ...(specName ? { specName } : {}),
    },
  })
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
.spec-list { display: flex; flex-direction: column; gap: 8px; }
.spec-item { display: flex; justify-content: space-between; padding: 10px 12px; border: 1px solid #ebeef5; border-radius: 6px; }
.spec-name { color: #606266; }
.spec-price { color: #303133; font-weight: 600; }
.detail-actions { margin-top: 18px; }
</style>

