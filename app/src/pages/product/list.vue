<template>
  <view class="page">
    <view class="search-bar">
      <view class="search-input-wrap">
        <text class="search-icon">⌕</text>
        <input v-model="keyword" class="search-input" placeholder="搜索商品，如：洗衣液" confirm-type="search" />
      </view>
      <button class="search-btn" type="primary" @click="updateRecommendation">搜索</button>
    </view>

    <scroll-view class="category-bar" scroll-x>
      <view class="category-row">
        <view
          v-for="cat in categories"
          :key="cat.name"
          class="category-item"
          :class="{ active: activeCategory === cat.name }"
          @click="activeCategory = cat.name"
        >
          <view class="category-icon" :class="cat.color">{{ cat.icon }}</view>
          <text>{{ cat.name }}</text>
        </view>
      </view>
    </scroll-view>

    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="errorMsg" class="empty-wrap">
      <text class="err">{{ errorMsg }}</text>
      <button size="mini" type="primary" class="retry" @click="load">重新加载</button>
    </view>
    <view v-else-if="!filteredList.length" class="empty-wrap">暂无商品</view>

    <view
      v-for="item in filteredList"
      :key="item.id"
      class="product-item"
      :class="{ recommended: item.id === recommendedProductId }"
      @click="goDetail(item.id)"
    >
      <image v-if="imageOf(item.image)" :src="imageOf(item.image)" class="thumb" mode="aspectFill" />
      <view v-else class="thumb ph">暂无</view>
      <view class="info">
        <view class="title-line">
          <text v-if="tagText(item)" class="tag" :class="tagClass(item)">{{ tagText(item) }}</text>
          <text class="name">{{ item.name }}</text>
        </view>
        <text class="desc">{{ productDesc(item) }}</text>
        <text class="price">¥{{ item.price }}</text>
      </view>
      <view class="cart-action" @click.stop="addCart(item)">
        <view class="cart-icon">🛒</view>
        <button size="mini" type="primary">加入购物车</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getProductList, type ProductItem } from '@/api/product'
import { addToCart } from '@/api/cart'
import { resolveImageUrl, requireLogin } from '@/utils'

const list = ref<ProductItem[]>([])
const loading = ref(false)
const errorMsg = ref('')
const keyword = ref('')
const recommendedProductId = ref<number | null>(null)
const activeCategory = ref('全部分类')

const categories = [
  { name: '洗衣清洁', icon: '衣', color: 'blue' },
  { name: '衣物护理', icon: '护', color: 'pink' },
  { name: '晾晒用品', icon: '晾', color: 'orange' },
  { name: '清洁工具', icon: '刷', color: 'green' },
  { name: '全部分类', icon: '▦', color: 'purple' },
]

const filteredList = computed(() => {
  const kw = keyword.value.trim()
  const source = activeCategory.value === '全部分类'
    ? list.value
    : list.value.filter((product) => matchCategory(product, activeCategory.value))
  if (!kw) return source
  return source
    .map((product) => ({ product, score: getProductScore(product, kw) }))
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .map((item) => item.product)
})

function goDetail(id: number) {
  uni.navigateTo({ url: `/pages/product/detail?id=${id}` })
}

function addCart(item: ProductItem) {
  if (!requireLogin('/pages/product/list')) return
  addToCart('PRODUCT', item.id, undefined, 1)
    .then(() => uni.showToast({ title: '已加入购物车', icon: 'success' }))
    .catch((e) => uni.showToast({ title: (e && e.message) || '失败', icon: 'none' }))
}

async function load() {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await getProductList()
    list.value = Array.isArray(data) ? data : []
    updateRecommendation()
    if (!list.value.length) console.warn('[product/list] 接口返回空列表')
  } catch (e: any) {
    list.value = []
    errorMsg.value = (e && e.message) || '商品加载失败'
    console.error('[product/list]', e)
  } finally {
    loading.value = false
  }
}

function updateRecommendation() {
  const kw = keyword.value.trim()
  if (!kw || !list.value.length) {
    recommendedProductId.value = null
    return
  }
  const best = list.value
    .map((product) => ({ product, score: getProductScore(product, kw) }))
    .sort((a, b) => b.score - a.score)[0]
  recommendedProductId.value = best && best.score >= 6 ? best.product.id : null
}

function imageOf(url?: string) {
  if (!url || url.includes('th.bing.com')) return ''
  return resolveImageUrl(url)
}

function productDesc(product: ProductItem) {
  if (product.description) return product.description.split(/[。；;]/)[0].slice(0, 18)
  if (product.specification) return product.specification
  return product.category || '品质洗护用品'
}

function tagText(product: ProductItem) {
  if (product.sales >= 30) return '热销'
  if (product.sales >= 15) return '推荐'
  if (product.id % 3 === 0) return '新品'
  return ''
}

function tagClass(product: ProductItem) {
  const tag = tagText(product)
  if (tag === '热销') return 'hot'
  if (tag === '推荐') return 'recommend'
  return 'new'
}

function matchCategory(product: ProductItem, category: string) {
  const text = normalizeText([product.name, product.category, product.description, product.specification].filter(Boolean).join(' '))
  if (category === '洗衣清洁') return ['洗衣液', '洗衣粉', '清洁', '去渍', '喷雾', '除菌'].some((k) => text.includes(k))
  if (category === '衣物护理') return ['柔顺', '护理', '护衣', '香氛', '皮具', '保养'].some((k) => text.includes(k))
  if (category === '晾晒用品') return ['衣架', '晾', '收纳', '防尘', '夹'].some((k) => text.includes(k))
  if (category === '清洁工具') return ['刷', '工具', '清洁布', '滚筒', '除毛'].some((k) => text.includes(k))
  return true
}

function getProductScore(product: ProductItem, input: string) {
  const tokens = extractTokens(input)
  if (!tokens.length) return 0
  const searchable = normalizeText([
    product.name,
    product.category,
    product.brand,
    product.specification,
    product.description,
  ].filter(Boolean).join(' '))
  const name = normalizeText(product.name || '')
  let score = 0
  tokens.forEach((token) => {
    if (name.includes(token)) score += token.length >= 3 ? 8 : 5
    else if (searchable.includes(token)) score += token.length >= 3 ? 5 : 3
  })
  if (name && normalizeText(input).includes(name)) score += 10
  return score
}

function extractTokens(input: string) {
  const normalized = normalizeText(input)
    .replace(/(我想|我要|我需要|帮我|给我|选择|挑选|推荐|一下|一个|一件|商品|产品|东西|买|洗|清洗|干洗|护理|保养|的)/g, ' ')
    .trim()
  const tokens = normalized.split(/\s+/).filter(Boolean)
  if (normalized && normalized.length <= 8) tokens.push(normalized)
  return Array.from(new Set(tokens.filter((token) => token.length >= 2)))
}

function normalizeText(text: string) {
  return String(text || '').toLowerCase().replace(/[，。！？、,.!?;；:\s]/g, '')
}

onShow(load)
watch(keyword, updateRecommendation)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 20rpx 22rpx 34rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f8fbff 0%, #f4f7fb 100%);
}
.search-bar {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-bottom: 20rpx;
  padding: 10rpx;
  border-radius: 42rpx;
  background: #fff;
  box-shadow: 0 10rpx 30rpx rgba(32, 93, 168, 0.08);
}
.search-input-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  min-width: 0;
  height: 72rpx;
  padding: 0 18rpx;
  box-sizing: border-box;
}
.search-icon {
  color: #9aa3af;
  font-size: 40rpx;
  margin-right: 12rpx;
}
.search-input {
  flex: 1;
  min-width: 0;
  color: #111827;
  font-size: 28rpx;
}
.search-btn {
  width: 128rpx;
  height: 70rpx;
  line-height: 70rpx;
  padding: 0;
  border-radius: 36rpx;
  background: linear-gradient(135deg, #3488ff, #2474ff);
  font-size: 28rpx;
  box-shadow: 0 10rpx 24rpx rgba(36, 116, 255, 0.25);
}
.category-bar {
  width: 100%;
  margin-bottom: 20rpx;
  white-space: nowrap;
}
.category-row {
  display: inline-flex;
  min-width: 100%;
  padding: 22rpx 8rpx;
  box-sizing: border-box;
  border-radius: 20rpx;
  background: #fff;
  box-shadow: 0 10rpx 30rpx rgba(32, 93, 168, 0.06);
}
.category-item {
  width: 142rpx;
  text-align: center;
  color: #111827;
  font-size: 24rpx;
}
.category-icon {
  width: 64rpx;
  height: 64rpx;
  margin: 0 auto 12rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 25rpx;
  font-weight: 800;
}
.category-item.active text { color: #2474ff; font-weight: 700; }
.category-icon.blue { color: #2f7df4; background: #eaf4ff; }
.category-icon.pink { color: #f16285; background: #fff0f4; }
.category-icon.orange { color: #f59e0b; background: #fff4db; }
.category-icon.green { color: #21bd62; background: #eaf9ef; }
.category-icon.purple { color: #815fe8; background: #f0ebff; }
.product-item {
  display: flex;
  position: relative;
  gap: 24rpx;
  min-height: 214rpx;
  padding: 22rpx;
  margin-bottom: 18rpx;
  border-radius: 20rpx;
  background: #fff;
  box-shadow: 0 10rpx 32rpx rgba(32, 93, 168, 0.07);
}
.product-item.recommended {
  border: 2rpx solid #409eff;
  box-shadow: 0 8rpx 24rpx rgba(64, 158, 255, 0.16);
}
.thumb {
  width: 184rpx;
  height: 184rpx;
  border-radius: 16rpx;
  flex-shrink: 0;
  background: #f5f8fc;
}
.thumb.ph {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  font-size: 24rpx;
}
.info {
  flex: 1;
  min-width: 0;
  padding-right: 178rpx;
}
.title-line {
  display: flex;
  align-items: center;
  gap: 10rpx;
  min-width: 0;
  margin-top: 10rpx;
}
.tag {
  flex: 0 0 auto;
  height: 34rpx;
  line-height: 34rpx;
  padding: 0 10rpx;
  border-radius: 8rpx;
  color: #fff;
  font-size: 21rpx;
}
.tag.hot { background: #2f80ed; }
.tag.recommend { background: #44c767; }
.tag.new { background: #ff9f1c; }
.name {
  min-width: 0;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
  line-height: 1.35;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.desc {
  display: block;
  color: #7b8798;
  font-size: 25rpx;
  line-height: 1.5;
  margin-top: 14rpx;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.price {
  display: block;
  color: #ff3b30;
  font-size: 34rpx;
  font-weight: 800;
  margin-top: 22rpx;
}
.cart-action {
  position: absolute;
  right: 22rpx;
  top: 50%;
  width: 164rpx;
  transform: translateY(-50%);
  text-align: center;
}
.cart-icon {
  width: 68rpx;
  height: 68rpx;
  line-height: 68rpx;
  margin: 0 auto 26rpx;
  border-radius: 50%;
  background: #f2f6fb;
  color: #7b8798;
  font-size: 32rpx;
}
.cart-action button {
  width: 164rpx;
  height: 60rpx;
  line-height: 60rpx;
  padding: 0;
  border-radius: 32rpx;
  background: linear-gradient(135deg, #3488ff, #2474ff);
  font-size: 25rpx;
}
.empty-wrap {
  padding: 80rpx 24rpx;
  text-align: center;
  color: #909399;
  font-size: 28rpx;
}
.err {
  display: block;
  color: #f56c6c;
  margin-bottom: 24rpx;
  line-height: 1.5;
}
.retry { margin-top: 8rpx; }
</style>
