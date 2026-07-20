<template>
  <view class="page">
    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!service" class="empty-wrap">服务不存在</view>
    <view v-else class="card detail">
      <image v-if="service.image" :src="resolveImageUrl(service.image)" class="hero-img" mode="aspectFit" />
      <view v-else class="hero-img ph">暂无图片</view>
      <text class="name">{{ service.name }}</text>
      <view class="price-row">
        <text class="price">¥{{ minPrice }}/件</text>
        <text v-if="specs.length" class="suffix">起</text>
      </view>
      <text v-if="service.cycle" class="cycle">预计洗护周期：{{ service.cycle }}</text>
      <view v-if="specs.length" class="specs">
        <text class="label">规格</text>
        <view
          v-for="s in specs"
          :key="s.name"
          class="spec-item"
          :class="{ active: selectedSpecName === s.name }"
          @click="selectedSpecName = s.name"
        >
          <text>{{ s.name }}</text>
          <text>¥{{ s.price }}/件</text>
        </view>
      </view>
      <view class="qty-row">
        <text>数量</text>
        <view class="qty">
          <text @click="changeQty(-1)">−</text>
          <text>{{ quantity }}</text>
          <text @click="changeQty(1)">+</text>
        </view>
      </view>
      <text v-if="service.description" class="desc">{{ service.description }}</text>
      <CommentSection :targetType="'SERVICE'" :targetId="service.id" :previewCount="2" />
      <button class="btn-primary book-btn" @click="submitAction">{{ actionText }}</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getServiceList, type ServiceItem } from '@/api/service'
import { updateCartServiceSpec } from '@/api/cart'
import CommentSection from '@/components/CommentSection.vue'
import { parseServiceSpecs, resolveImageUrl } from '@/utils'

const serviceId = ref(0)
const cartId = ref(0)
const loading = ref(true)
const service = ref<ServiceItem | null>(null)
const quantity = ref(1)
const selectedSpecName = ref('')
const specs = computed(() => parseServiceSpecs(service.value ? service.value.specs : undefined))
const minPrice = computed(() => {
  if (specs.value.length) return Math.min(...specs.value.map((s) => s.price))
  return service.value && service.value.price !== undefined && service.value.price !== null ? service.value.price : 0
})
const actionText = computed(() => cartId.value ? '保存修改' : '立即预约')

onLoad((q) => {
  serviceId.value = Number((q && q.id) || 0)
  cartId.value = Number((q && q.cartId) || 0)
  quantity.value = Math.max(1, Math.min(99, Number((q && q.quantity) || 1)))
  selectedSpecName.value = q && q.specName ? decodeURIComponent(String(q.specName)) : ''
})

function changeQty(d: number) {
  quantity.value = Math.max(1, Math.min(99, quantity.value + d))
}

async function submitAction() {
  if (cartId.value) {
    try {
      await updateCartServiceSpec(cartId.value, selectedSpecName.value || undefined, quantity.value)
      uni.showToast({ title: '已保存', icon: 'success' })
      setTimeout(() => uni.navigateBack(), 350)
    } catch (e: any) {
      uni.showToast({ title: (e && e.message) || '保存失败', icon: 'none' })
    }
    return
  }
  goOrder()
}

function goOrder() {
  if (!service.value) return
  const specName = selectedSpecName.value || (specs.value.length ? specs.value[0].name : '')
  let url = `/pages/service/order-create?serviceId=${service.value.id}`
  if (specName) url += `&specName=${encodeURIComponent(specName)}`
  uni.navigateTo({ url })
}

onMounted(async () => {
  if (!serviceId.value) return
  try {
    const list = await getServiceList()
    service.value = list.find((s) => s.id === serviceId.value) || null
    if (!selectedSpecName.value && specs.value.length) selectedSpecName.value = specs.value[0].name
  } catch {}
  loading.value = false
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.hero-img { width: 100%; height: 400rpx; border-radius: 12rpx; background: #f5f7fa; margin-bottom: 20rpx; }
.hero-img.ph { display: flex; align-items: center; justify-content: center; color: #909399; }
.name { display: block; font-size: 36rpx; font-weight: 600; margin-bottom: 12rpx; }
.price-row { display: flex; align-items: baseline; gap: 8rpx; margin-bottom: 12rpx; }
.price { font-size: 40rpx; color: #ff4d4f; font-weight: 700; }
.suffix { font-size: 24rpx; color: #ff4d4f; }
.cycle { display: block; color: #606266; margin-bottom: 16rpx; }
.label { display: block; font-size: 26rpx; color: #909399; margin-bottom: 8rpx; }
.spec-item {
  display: flex;
  justify-content: space-between;
  padding: 16rpx;
  background: #f5f7fa;
  border: 2rpx solid transparent;
  border-radius: 8rpx;
  margin-bottom: 8rpx;
}
.spec-item.active {
  color: #2474ff;
  background: #eef5ff;
  border-color: #2474ff;
}
.qty-row { display: flex; justify-content: space-between; align-items: center; margin: 24rpx 0; }
.qty { display: flex; align-items: center; gap: 28rpx; font-size: 32rpx; }
.qty text {
  min-width: 44rpx;
  height: 44rpx;
  line-height: 44rpx;
  text-align: center;
}
.desc { display: block; color: #606266; line-height: 1.6; margin: 16rpx 0; }
.book-btn { margin-top: 32rpx; width: 100%; height: 88rpx; line-height: 88rpx; }
</style>
