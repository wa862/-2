<template>
  <view class="page">
    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!product" class="empty-wrap">商品不存在</view>
    <view v-else class="card">
      <image v-if="product.image" :src="resolveImageUrl(product.image)" class="hero-img" mode="aspectFit" />
      <view v-else class="hero-img ph">暂无图片</view>
      <text class="name">{{ product.name }}</text>
      <text class="price">¥{{ product.price }}</text>
      <text v-if="product.brand" class="meta">品牌：{{ product.brand }}</text>
      <text v-if="product.specification" class="meta">规格：{{ product.specification }}</text>
      <text class="desc">{{ product.description || '专业洗护商品，品质保证。' }}</text>
      <view class="qty-row">
        <text>数量</text>
        <view class="qty">
          <text @click="changeQty(-1)">−</text>
          <text>{{ quantity }}</text>
          <text @click="changeQty(1)">+</text>
        </view>
      </view>
      <CommentSection :targetType="'PRODUCT'" :targetId="product.id" :previewCount="2" />
      <button class="btn-primary add-btn" @click="addCart">加入购物车</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getProductDetail, type ProductItem } from '@/api/product'
import { addToCart } from '@/api/cart'
import CommentSection from '@/components/CommentSection.vue'
import { resolveImageUrl, requireLogin } from '@/utils'

const productId = ref(0)
const loading = ref(true)
const product = ref<ProductItem | null>(null)
const quantity = ref(1)

onLoad((q) => { productId.value = Number((q && q.id) || 0) })

function changeQty(d: number) {
  quantity.value = Math.max(1, Math.min(99, quantity.value + d))
}

function addCart() {
  if (!product.value || !requireLogin()) return
  addToCart('PRODUCT', product.value.id, undefined, quantity.value)
    .then(() => uni.showToast({ title: '已加入购物车', icon: 'success' }))
    .catch((e) => uni.showToast({ title: (e && e.message) || '失败', icon: 'none' }))
}

onMounted(async () => {
  if (!productId.value) return
  try { product.value = await getProductDetail(productId.value) } catch {}
  loading.value = false
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.hero-img { width: 100%; height: 400rpx; border-radius: 12rpx; background: #f5f7fa; margin-bottom: 20rpx; }
.hero-img.ph { display: flex; align-items: center; justify-content: center; color: #909399; }
.name { display: block; font-size: 36rpx; font-weight: 600; margin-bottom: 12rpx; }
.price { display: block; font-size: 40rpx; color: #ff4d4f; font-weight: 700; margin-bottom: 12rpx; }
.meta { display: block; font-size: 26rpx; color: #606266; margin-bottom: 8rpx; }
.desc { display: block; color: #606266; line-height: 1.6; margin: 16rpx 0; }
.qty-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24rpx; }
.qty { display: flex; gap: 24rpx; font-size: 32rpx; }
.add-btn { width: 100%; height: 88rpx; line-height: 88rpx; margin-top: 24rpx; }
</style>
