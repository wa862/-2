<template>
  <div class="product-page">
    <div class="page-header">
      <div>
        <h2>商品商城</h2>
        <p class="tip">洗衣液、护理产品、去渍剂、衣架、洗衣袋等常用洗护商品。</p>
      </div>
      <div class="search-wrap">
        <el-input
          v-model="keyword"
          placeholder="搜索商城商品，如：洗衣液、护理剂"
          clearable
        >
          <template #append>
            <el-button type="primary">搜索</el-button>
          </template>
        </el-input>
      </div>
    </div>
    <el-empty v-if="!filteredList.length && !loading" description="暂无商品" />
    <el-row v-else :gutter="20">
      <el-col v-for="item in filteredList" :key="item.id" :span="6">
        <el-card shadow="hover" class="product-card" @click="openDetail(item)">
          <div class="product-img">
            <img v-if="item.image" :src="item.image" :alt="item.name" @error="onImgError" />
            <div v-else class="product-img-placeholder">暂无图片</div>
          </div>
          <div class="product-name">{{ item.name }}</div>
          <div class="product-price">¥{{ item.price }}</div>
          <el-button type="primary" size="small" class="add-cart-btn" @click.stop="addCart(item)">加入购物车</el-button>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog v-model="detailVisible" title="商品详情" width="480px" class="detail-dialog">
      <template v-if="detailItem">
        <div class="detail-img">
          <img v-if="detailItem.image" :src="detailItem.image" :alt="detailItem.name" />
          <div v-else class="detail-img-ph">暂无图片</div>
        </div>
        <div class="detail-name">{{ detailItem.name }}</div>
        <div class="detail-price">¥{{ detailItem.price }}</div>
        <div class="detail-extra">
          <span v-if="detailItem.brand">品牌：{{ detailItem.brand }}</span>
          <span v-if="detailItem.specification">规格：{{ detailItem.specification }}</span>
        </div>
        <div class="detail-desc">{{ detailItem.description || '专业洗护商品，品质保证。' }}</div>
        <div class="detail-actions">
          <el-button type="primary" @click="addCart(detailItem); detailVisible = false">加入购物车</el-button>
          <el-button @click="goDetail(detailItem.id); detailVisible = false">查看详情页</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getProductList } from '@/api/product'
import { addToCart } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import type { ProductItem } from '@/api/product'

const router = useRouter()
const store = useUserStore()
const list = ref<ProductItem[]>([])
const loading = ref(false)
const keyword = ref('')
const detailVisible = ref(false)
const detailItem = ref<ProductItem | null>(null)

const filteredList = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return list.value
  return list.value.filter((p) => (p.name || '').toLowerCase().includes(kw))
})

function openDetail(item: ProductItem) {
  detailItem.value = item
  detailVisible.value = true
}

function goDetail(id: number) {
  router.push(`/home/user/product/${id}`)
}

function addCart(item: ProductItem) {
  if (!store.token) {
    ElMessage.warning('请先登录')
    router.push('/home/login')
    return
  }
  addToCart('PRODUCT', item.id, undefined, 1).then(() => {
    ElMessage.success('已加入购物车')
  }).catch((e: any) => {
    const status = e?.response?.status
    const msg = e?.response?.data?.message || (status === 404 ? '购物车接口未就绪，请重启后端' : status === 401 ? '请先登录' : status === 500 ? '服务器错误，请确认已执行 database 脚本并重启后端' : '加入失败')
    ElMessage.error(msg)
  })
}

function onImgError(e: Event) {
  const el = e.target as HTMLImageElement
  if (el) el.style.display = 'none'
}

onMounted(async () => {
  loading.value = true
  try {
    list.value = await getProductList()
  } catch (e: any) {
    const msg = e?.response?.data?.message || '商品列表加载失败，请确认已执行 database 脚本并重启后端'
    ElMessage.error(msg)
  }
  loading.value = false
})
</script>

<style scoped>
.product-page { background: #fff; padding: 16px; border-radius: 8px; }
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 8px;
}
.product-page h2 { margin-bottom: 4px; font-size: 18px; }
.tip { color: #909399; margin-bottom: 14px; font-size: 14px; }
.search-wrap { width: 240px; margin-bottom: 4px; }
.product-card { cursor: pointer; }
.product-img { height: 160px; border-radius: 6px; margin-bottom: 8px; overflow: hidden; background: #f5f7fa; }
.product-img img { width: 100%; height: 100%; object-fit: contain; display: block; background: #f5f7fa; }
.product-img-placeholder { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: #909399; font-size: 14px; }
.product-name { font-weight: 500; margin-bottom: 6px; font-size: 14px; }
.product-price { color: #ff4d4f; font-weight: bold; margin-bottom: 6px; font-size: 16px; }
.add-cart-btn { width: 100%; border-radius: 12px; }
.detail-dialog .detail-img { width: 100%; height: 160px; border-radius: 6px; overflow: hidden; background: #f5f7fa; margin-bottom: 8px; }
.detail-dialog .detail-img img { width: 100%; height: 100%; object-fit: contain; }
.detail-img-ph { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: #909399; font-size: 14px; }
.detail-name { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
.detail-price { font-size: 18px; color: #ff4d4f; font-weight: bold; margin-bottom: 8px; }
.detail-desc { font-size: 14px; color: #606266; margin-bottom: 12px; line-height: 1.5; }
.detail-actions { display: flex; gap: 8px; }
</style>
