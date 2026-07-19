<template>
  <div class="detail-page">
    <el-button link type="primary" @click="$router.push('/home/user/product')" class="back">← 返回商城</el-button>
    <div v-if="loading" class="loading"><el-icon class="is-loading"><Loading /></el-icon> 加载中...</div>
    <div v-else-if="product" class="detail-card">
      <div class="detail-img">
        <img v-if="product.image" :src="product.image" :alt="product.name" />
        <div v-else class="placeholder">暂无图片</div>
      </div>
      <div class="detail-info">
        <h1 class="detail-name">{{ product.name }}</h1>
        <div class="detail-price">¥{{ product.price }}</div>
        <div class="detail-attrs">
          <div v-if="product.brand">品牌：{{ product.brand }}</div>
          <div v-if="product.manufacturer">厂家：{{ product.manufacturer }}</div>
          <div v-if="product.productionDate">生产日期：{{ product.productionDate }}</div>
          <div v-if="product.specification">规格：{{ product.specification }}</div>
        </div>
        <div v-if="product.description" class="detail-desc">{{ product.description }}</div>
        <div v-else class="detail-desc">专业洗护商品，品质保证。</div>
        <div class="detail-meta">分类：{{ product.category }} · 库存 {{ product.stock }}</div>
        <el-input-number v-model="quantity" :min="1" :max="product.stock || 999" class="qty-input" />
        <el-button type="primary" size="large" @click="addCart">加入购物车</el-button>

        <CommentSection :target-type="'PRODUCT'" :target-id="product.id" collapsed :preview-count="1" />
      </div>
    </div>
    <el-empty v-else description="商品不存在" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Loading } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getProductDetail } from '@/api/product'
import { addToCart } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import CommentSection from '@/components/CommentSection.vue'
import type { ProductItem } from '@/api/product'

const route = useRoute()
const router = useRouter()
const store = useUserStore()
const product = ref<ProductItem | null>(null)
const loading = ref(true)
const quantity = ref(1)

const id = computed(() => Number(route.params.id))

onMounted(async () => {
  if (!id.value) return
  loading.value = true
  try {
    product.value = await getProductDetail(id.value)
  } catch (_) {
    product.value = null
  }
  loading.value = false
})

function addCart() {
  if (!product.value) return
  if (!store.token) {
    ElMessage.warning('请先登录')
    router.push('/home/login')
    return
  }
  addToCart('PRODUCT', product.value.id, undefined, quantity.value).then(() => {
    ElMessage.success('已加入购物车')
  }).catch((e: any) => {
    const status = e?.response?.status
    const msg = e?.response?.data?.message || (status === 404 ? '购物车接口未就绪，请重启后端' : status === 401 ? '请先登录' : status === 500 ? '服务器错误，请确认已执行 database 脚本并重启后端' : '加入失败')
    ElMessage.error(msg)
  })
}

</script>

<style scoped>
.detail-page { background: #fff; padding: 24px; border-radius: 8px; }
.back { margin-bottom: 16px; }
.loading { padding: 40px; text-align: center; color: #909399; }
.detail-card { display: flex; gap: 40px; }
.detail-img { width: 400px; flex-shrink: 0; border-radius: 8px; overflow: hidden; background: #f5f7fa; }
.detail-img img { width: 100%; height: 100%; object-fit: contain; display: block; }
.detail-img .placeholder { height: 300px; display: flex; align-items: center; justify-content: center; color: #909399; }
.detail-info { flex: 1; }
.detail-name { font-size: 28px; margin-bottom: 12px; }
.detail-price { font-size: 32px; color: #ff4d4f; font-weight: bold; margin-bottom: 16px; }
.detail-desc { color: #606266; line-height: 1.6; margin-bottom: 12px; }
.detail-meta { font-size: 18px; color: #909399; margin-bottom: 20px; }
.qty-input { margin-right: 12px; margin-bottom: 16px; }
</style>
