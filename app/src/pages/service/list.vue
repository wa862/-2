<template>
  <view class="page">
    <view class="hero">
      <view class="hero-copy">
        <text class="hero-title">专业干洗</text>
        <text class="hero-title blue">洁净如新</text>
        <text class="hero-sub">专业设备 · 健康呵护 · 上门取送</text>
        <view class="hero-tags">
          <view class="hero-tag">精细护理</view>
          <view class="hero-tag">安全无味</view>
          <view class="hero-tag">省时省心</view>
        </view>
      </view>
      <view class="coat-scene">
        <view class="hanger"></view>
        <view class="coat">
          <view class="lapel left"></view>
          <view class="lapel right"></view>
        </view>
      </view>
    </view>

    <view class="tool-row">
      <view class="tool-card" @click="showCoupon">
        <view class="tool-icon orange">券</view>
        <view>
          <text class="tool-title">优惠券</text>
          <text class="tool-sub">领取优惠</text>
        </view>
      </view>
      <view class="tool-card" @click="goOrders">
        <view class="tool-icon blue">单</view>
        <view>
          <text class="tool-title">我的订单</text>
          <text class="tool-sub">查看进度</text>
        </view>
      </view>
    </view>

    <view class="search-card">
      <view class="search-input-wrap">
        <text class="search-icon">⌕</text>
        <input v-model="keyword" class="search-input" placeholder="搜索服务名称" confirm-type="search" />
      </view>
      <button class="search-btn" type="primary" @click="updateRecommendation">搜索</button>
    </view>

    <scroll-view class="category-scroll" scroll-x>
      <view class="category-row">
        <view
          v-for="c in categories"
          :key="c.value"
          class="category-item"
          :class="{ active: activeCategory === c.value }"
          @click="activeCategory = c.value"
        >
          {{ c.label }}
        </view>
      </view>
    </scroll-view>

    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="errorMsg" class="empty-wrap">
      <text class="err">{{ errorMsg }}</text>
      <button size="mini" type="primary" @click="load">重新加载</button>
    </view>
    <view v-else-if="!filteredServices.length" class="empty-wrap">暂无相关服务</view>

    <template v-else>
      <view
        v-for="item in filteredServices"
        :key="item.id"
        class="service-card"
        :class="{ recommended: item.id === recommendedServiceId }"
        @click="goDetail(item.id)"
      >
        <image v-if="imageOf(item.image)" :src="imageOf(item.image)" class="thumb" mode="aspectFill" />
        <view v-else class="thumb ph">洗</view>
        <view class="service-main">
          <view class="name-row">
            <text class="name">{{ item.name }}</text>
            <text class="badge">{{ serviceBadge(item) }}</text>
          </view>
          <text class="desc">{{ serviceDesc(item) }}</text>
        </view>
        <view class="service-side">
          <text class="price">¥{{ minPrice(item) }}/件起</text>
          <view class="actions">
            <button size="mini" class="cart-btn" @click.stop="addCart(item)">🛒 加购</button>
            <button size="mini" type="primary" class="order-btn" @click.stop="goOrder(item)">预约</button>
          </view>
        </view>
      </view>
    </template>

    <view v-if="!loading && !errorMsg && filteredServices.length" class="end-line">
      <text></text>
      <span>没有更多了</span>
      <text></text>
    </view>

    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getServiceList, type ServiceItem } from '@/api/service'
import { addToCart } from '@/api/cart'
import { matchServiceCategory, parseServiceSpecs, listMinPrice, resolveImageUrl, requireLogin } from '@/utils'

const allServices = ref<ServiceItem[]>([])
const loading = ref(false)
const errorMsg = ref('')
const activeCategory = ref('全部')
const keyword = ref('')
const recommendedServiceId = ref<number | null>(null)

const categories = [
  { label: '全部服务', value: '全部' },
  { label: '衣物清洗', value: '日常衣物' },
  { label: '鞋包护理', value: '鞋类' },
  { label: '家居护理', value: '家居护理' },
  { label: '其他服务', value: '箱包/奢侈品' },
]

const filteredServices = computed(() => {
  let list = allServices.value
  if (activeCategory.value !== '全部') {
    list = list.filter((item) => matchCategory(item, activeCategory.value))
  }
  const kw = keyword.value.trim()
  if (kw) {
    list = list
      .map((service) => ({ service, score: getServiceScore(service, kw) }))
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .map((item) => item.service)
  }
  return list
})

function matchCategory(item: ServiceItem, category: string) {
  if (category === '家居护理') {
    const name = item.name || ''
    return ['窗帘', '沙发', '地毯', '被', '毯', '床品'].some((k) => name.includes(k))
  }
  return matchServiceCategory(item.name || '', category)
}

function parsedSpecs(item: ServiceItem) {
  return parseServiceSpecs(item.specs)
}

function minPrice(item: ServiceItem) {
  return listMinPrice(item.price, parsedSpecs(item)).toFixed(0)
}

function imageOf(url?: string) {
  if (!url || url.includes('th.bing.com')) return ''
  return resolveImageUrl(url)
}

function serviceBadge(item: ServiceItem) {
  const name = item.name || ''
  if (name.includes('西装')) return '精致护理'
  if (name.includes('羽绒服')) return '蓬松保暖'
  if (name.includes('大衣')) return '柔软呵护'
  if (name.includes('鞋')) return '洁净焕新'
  if (name.includes('衬衫') || name.includes('T恤')) return '日常清洁'
  return '专业护理'
}

function serviceDesc(item: ServiceItem) {
  if (item.description) return item.description.split(/[。；;]/)[0].slice(0, 18)
  if (item.cycle) return `预计${item.cycle}`
  return '专业清洗，贴心护理'
}

function goDetail(id: number) {
  uni.navigateTo({ url: `/pages/service/detail?id=${id}` })
}

function goOrder(item: ServiceItem) {
  const specs = parsedSpecs(item)
  const specName = specs.length ? specs[0].name : ''
  let url = `/pages/service/order-create?serviceId=${item.id}`
  if (specName) url += `&specName=${encodeURIComponent(specName)}`
  uni.navigateTo({ url })
}

function addCart(item: ServiceItem) {
  if (!requireLogin('/pages/service/list')) return
  const specs = parsedSpecs(item)
  const specName = specs.length ? specs[0].name : undefined
  addToCart('SERVICE', undefined, item.id, 1, specName)
    .then(() => uni.showToast({ title: '已加入购物车', icon: 'success' }))
    .catch((e) => uni.showToast({ title: (e && e.message) || '加入失败', icon: 'none' }))
}

function goOrders() {
  uni.navigateTo({ url: '/pages/order/list' })
}

function showCoupon() {
  uni.showToast({ title: '暂无可领取优惠券', icon: 'none' })
}

async function load() {
  loading.value = true
  errorMsg.value = ''
  try {
    const data = await getServiceList()
    allServices.value = Array.isArray(data) ? data : []
    updateRecommendation()
  } catch (e: any) {
    allServices.value = []
    errorMsg.value = (e && e.message) || '服务加载失败'
    console.error('[service/list]', e)
  } finally {
    loading.value = false
  }
}

function updateRecommendation() {
  const kw = keyword.value.trim()
  if (!kw || !allServices.value.length) {
    recommendedServiceId.value = null
    return
  }
  const best = allServices.value
    .map((service) => ({ service, score: getServiceScore(service, kw) }))
    .sort((a, b) => b.score - a.score)[0]
  recommendedServiceId.value = best && best.score >= 6 ? best.service.id : null
}

function getServiceScore(service: ServiceItem, input: string) {
  const searchable = [service.name, service.category, service.description, service.specs].filter(Boolean).join(' ')
  return getTextScore(searchable, input) + getTextScore(service.name || '', input)
}

function getTextScore(target: string, input: string) {
  const source = normalizeText(target)
  const tokens = extractTokens(input)
  let score = 0
  tokens.forEach((token) => {
    if (source.includes(token)) score += token.length >= 3 ? 8 : 5
  })
  const normalizedInput = normalizeText(input)
  if (source && normalizedInput.includes(source)) score += 10
  return score
}

function extractTokens(input: string) {
  const normalized = normalizeText(input)
    .replace(/(我想|我要|我需要|帮我|给我|选择|挑选|推荐|预约|下单|一下|一个|一件|服务|衣物|衣服|洗|清洗|干洗|护理|保养|的)/g, ' ')
    .trim()
  const tokens = normalized.split(/\s+/).filter(Boolean)
  if (normalized && normalized.length <= 8) tokens.push(normalized)
  return Array.from(new Set(tokens.filter((token) => token.length >= 2)))
}

function normalizeText(text: string) {
  return String(text || '').toLowerCase().replace(/[，。！？、,.!?;；:\s]/g, '')
}

watch(keyword, updateRecommendation)
onShow(load)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 20rpx 22rpx 40rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f8fbff 0%, #f4f8fc 100%);
}
.hero {
  position: relative;
  height: 250rpx;
  padding: 34rpx;
  box-sizing: border-box;
  border-radius: 20rpx;
  overflow: hidden;
  background:
    radial-gradient(circle at 78% 44%, rgba(255,255,255,0.76), transparent 30%),
    linear-gradient(135deg, #eef7ff 0%, #cae3ff 100%);
  box-shadow: 0 12rpx 34rpx rgba(42, 103, 186, 0.08);
}
.hero-copy {
  position: relative;
  z-index: 1;
}
.hero-title {
  display: block;
  color: #111827;
  font-size: 38rpx;
  font-weight: 900;
  line-height: 1.18;
}
.hero-title.blue {
  color: #2b7fff;
}
.hero-sub {
  display: block;
  color: #64748b;
  font-size: 24rpx;
  margin-top: 16rpx;
}
.hero-tags {
  display: flex;
  gap: 12rpx;
  width: 390rpx;
  margin-top: 28rpx;
  padding: 14rpx 16rpx;
  border-radius: 14rpx;
  background: rgba(255,255,255,0.78);
  box-shadow: 0 8rpx 20rpx rgba(59, 130, 246, 0.08);
}
.hero-tag {
  flex: 1;
  color: #58708d;
  font-size: 20rpx;
  text-align: center;
}
.coat-scene {
  position: absolute;
  right: 24rpx;
  bottom: 0;
  width: 230rpx;
  height: 230rpx;
}
.hanger {
  position: absolute;
  left: 36rpx;
  top: 26rpx;
  width: 150rpx;
  height: 48rpx;
  border-top: 6rpx solid #99acc3;
  border-left: 6rpx solid #99acc3;
  border-radius: 16rpx 0 0 0;
}
.coat {
  position: absolute;
  left: 54rpx;
  top: 58rpx;
  width: 136rpx;
  height: 166rpx;
  border-radius: 36rpx 36rpx 18rpx 18rpx;
  background: linear-gradient(135deg, #bcdcff, #8ebff4);
  box-shadow: 0 12rpx 30rpx rgba(80, 139, 205, 0.22);
}
.lapel {
  position: absolute;
  top: 26rpx;
  width: 44rpx;
  height: 90rpx;
  background: rgba(255,255,255,0.38);
}
.lapel.left {
  left: 25rpx;
  transform: skewY(18deg);
}
.lapel.right {
  right: 25rpx;
  transform: skewY(-18deg);
}
.tool-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 18rpx;
  margin-top: 20rpx;
}
.tool-card,
.search-card {
  display: flex;
  align-items: center;
  border-radius: 18rpx;
  background: #fff;
  box-shadow: 0 10rpx 30rpx rgba(32, 93, 168, 0.07);
}
.tool-card {
  gap: 18rpx;
  padding: 24rpx;
}
.tool-icon {
  width: 64rpx;
  height: 64rpx;
  border-radius: 16rpx;
  color: #fff;
  font-size: 25rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
}
.tool-icon.orange { background: linear-gradient(135deg, #ffbd64, #ff8a30); }
.tool-icon.blue { background: linear-gradient(135deg, #78b8ff, #2b7fff); }
.tool-title,
.tool-sub {
  display: block;
}
.tool-title {
  color: #111827;
  font-size: 28rpx;
  font-weight: 800;
}
.tool-sub {
  color: #8a94a6;
  font-size: 22rpx;
  margin-top: 6rpx;
}
.search-card {
  margin-top: 18rpx;
  padding: 14rpx;
  gap: 12rpx;
}
.search-input-wrap {
  flex: 1;
  min-width: 0;
  height: 70rpx;
  padding: 0 20rpx;
  display: flex;
  align-items: center;
  border-radius: 36rpx;
  background: #f6f8fb;
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
  font-size: 26rpx;
}
.search-btn {
  width: 110rpx;
  height: 66rpx;
  line-height: 66rpx;
  padding: 0;
  border-radius: 22rpx;
  background: linear-gradient(135deg, #3c8dff, #2474ff);
  font-size: 26rpx;
}
.category-scroll {
  white-space: nowrap;
  margin-top: 24rpx;
  margin-bottom: 18rpx;
}
.category-row {
  display: inline-flex;
  gap: 58rpx;
  padding: 0 8rpx 12rpx;
}
.category-item {
  position: relative;
  color: #687386;
  font-size: 28rpx;
  font-weight: 600;
  line-height: 58rpx;
}
.category-item.active {
  color: #111827;
  font-weight: 900;
}
.category-item.active::after {
  content: '';
  position: absolute;
  left: 50%;
  bottom: 0;
  width: 54rpx;
  height: 6rpx;
  border-radius: 8rpx;
  background: #2474ff;
  transform: translateX(-50%);
}
.service-card {
  position: relative;
  display: flex;
  align-items: center;
  min-height: 154rpx;
  padding: 20rpx;
  margin-bottom: 16rpx;
  border-radius: 18rpx;
  background: #fff;
  box-shadow: 0 8rpx 28rpx rgba(32, 93, 168, 0.07);
}
.service-card.recommended {
  border: 2rpx solid #409eff;
}
.thumb {
  width: 132rpx;
  height: 132rpx;
  border-radius: 14rpx;
  flex-shrink: 0;
  background: #eef3f8;
}
.thumb.ph {
  color: #2b7fff;
  font-size: 36rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
}
.service-main {
  flex: 1;
  min-width: 0;
  padding: 0 18rpx;
}
.name-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  min-width: 0;
}
.name {
  min-width: 0;
  color: #111827;
  font-size: 30rpx;
  font-weight: 900;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.badge {
  flex: 0 0 auto;
  padding: 5rpx 12rpx;
  border-radius: 18rpx;
  color: #2b7fff;
  background: #eaf4ff;
  font-size: 20rpx;
}
.desc {
  display: block;
  color: #7b8798;
  font-size: 24rpx;
  margin-top: 18rpx;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.service-side {
  width: 178rpx;
  flex-shrink: 0;
  text-align: right;
}
.price {
  display: block;
  color: #ff3b30;
  font-size: 28rpx;
  font-weight: 900;
  margin-bottom: 22rpx;
}
.actions {
  display: flex;
  justify-content: flex-end;
  gap: 12rpx;
}
.cart-btn,
.order-btn {
  width: 76rpx;
  height: 48rpx;
  line-height: 48rpx;
  padding: 0;
  border-radius: 26rpx;
  font-size: 22rpx;
}
.cart-btn {
  color: #5f6b7a;
  background: #fff;
  border: 1rpx solid #d9e0ea;
}
.order-btn {
  background: linear-gradient(135deg, #3c8dff, #2474ff);
}
.end-line {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 26rpx;
  color: #c0c7d2;
  font-size: 24rpx;
  padding: 24rpx 0 10rpx;
}
.end-line text {
  width: 90rpx;
  height: 1rpx;
  background: #d8dee8;
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
  margin-bottom: 20rpx;
}
</style>
