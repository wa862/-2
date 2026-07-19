<template>
  <view class="page">
    <view class="card">
      <text class="tip">定位当前位置，并在微信地图中搜索附近干洗店</text>
      <view v-if="locationText" class="location-text">{{ locationText }}</view>
      <view class="toolbar">
        <button size="mini" :loading="locating" @click="locate">重新定位</button>
        <button size="mini" type="primary" @click="chooseLocation">地图选择附近干洗店</button>
      </view>
    </view>

    <view v-if="mapStore" class="card selected-card">
      <text class="section-title">地图选中的附近干洗店</text>
      <view class="store-item">
        <view class="info">
          <text class="name">{{ mapStore.name }}</text>
          <text class="addr">{{ mapStore.address }}</text>
        </view>
        <button size="mini" type="primary" @click="selectMapStore">选择该门店</button>
      </view>
    </view>

    <view class="card">
      <text class="section-title">平台门店</text>
      <view v-if="!storeList.length" class="empty-wrap">暂无门店数据</view>
      <view v-for="s in storeList" :key="s.id" class="store-item">
        <view class="info">
          <text class="name">{{ s.name }}</text>
          <text class="addr">{{ s.address }}</text>
          <text v-if="s.phone" class="phone">{{ s.phone }}</text>
        </view>
        <button size="mini" type="primary" @click="selectStore(s)">选择</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getStoreList, type StoreItem } from '@/api/store'

const storeList = ref<StoreItem[]>([])
const locating = ref(false)
const locationText = ref('')
const mapStore = ref<{ name: string; address: string; latitude?: number; longitude?: number } | null>(null)
const from = ref('')
const serviceId = ref('')
const specName = ref('')
const quantity = ref('')
const remark = ref('')
const cartIds = ref('')
const addressId = ref('')
const deliveryType = ref('')
const pickupDate = ref('')
const urgent = ref('')

onLoad((q) => {
  from.value = String((q && q.from) || '')
  serviceId.value = String((q && q.serviceId) || '')
  specName.value = q && q.specName ? decodeURIComponent(String(q.specName)) : ''
  quantity.value = String((q && q.quantity) || '')
  remark.value = q && q.remark ? decodeURIComponent(String(q.remark)) : ''
  cartIds.value = String((q && q.ids) || '')
  addressId.value = String((q && q.addressId) || '')
  deliveryType.value = q && q.deliveryType ? decodeURIComponent(String(q.deliveryType)) : ''
  pickupDate.value = q && q.pickupDate ? decodeURIComponent(String(q.pickupDate)) : ''
  urgent.value = String((q && q.urgent) || '')
})

function selectStore(s: StoreItem, displayName?: string, displayAddress?: string) {
  if (from.value === 'order-create' && serviceId.value) {
    let url = `/pages/service/order-create?serviceId=${serviceId.value}&storeId=${s.id}`
    url += `&storeName=${encodeURIComponent(displayName || s.name || '该门店')}`
    const address = displayAddress || s.address || ''
    if (address) url += `&storeAddress=${encodeURIComponent(address)}`
    if (specName.value) url += `&specName=${encodeURIComponent(specName.value)}`
    if (quantity.value) url += `&quantity=${encodeURIComponent(quantity.value)}`
    if (remark.value) url += `&remark=${encodeURIComponent(remark.value)}`
    uni.redirectTo({ url })
    uni.showToast({ title: `已选择${displayName || s.name}`, icon: 'success' })
    return
  }
  if (from.value === 'cart') {
    uni.switchTab({ url: '/pages/cart/cart' })
    uni.setStorageSync('selected_store', JSON.stringify({
      id: s.id,
      name: displayName || s.name,
      address: displayAddress || s.address || '',
    }))
    uni.showToast({ title: `已选择${displayName || s.name}`, icon: 'success' })
    return
  }
  if (from.value === 'checkout' && cartIds.value) {
    let url = `/pages/checkout/checkout?ids=${encodeURIComponent(cartIds.value)}&storeId=${s.id}`
    url += `&storeName=${encodeURIComponent(displayName || s.name || '该门店')}`
    const address = displayAddress || s.address || ''
    if (address) url += `&storeAddress=${encodeURIComponent(address)}`
    if (addressId.value) url += `&addressId=${encodeURIComponent(addressId.value)}`
    if (deliveryType.value) url += `&deliveryType=${encodeURIComponent(deliveryType.value)}`
    if (pickupDate.value) url += `&pickupDate=${encodeURIComponent(pickupDate.value)}`
    if (urgent.value) url += `&urgent=${encodeURIComponent(urgent.value)}`
    uni.redirectTo({ url })
    uni.showToast({ title: `已选择${displayName || s.name}`, icon: 'success' })
    return
  }
  uni.setStorageSync('selected_store', JSON.stringify({
    id: s.id,
    name: displayName || s.name,
    address: displayAddress || s.address || '',
  }))
  uni.navigateBack()
  uni.showToast({ title: `已选择${displayName || s.name}`, icon: 'success' })
}

function locate() {
  locating.value = true
  uni.getLocation({
    type: 'gcj02',
    success: (res) => {
      locationText.value = `当前位置：${res.latitude.toFixed(5)}, ${res.longitude.toFixed(5)}`
      uni.showToast({ title: '定位成功', icon: 'success' })
    },
    fail: () => uni.showToast({ title: '定位失败，请授权', icon: 'none' }),
    complete: () => { locating.value = false },
  })
}

function chooseLocation() {
  uni.chooseLocation({
    keyword: '干洗店',
    success: (res) => {
      mapStore.value = {
        name: res.name || '附近干洗店',
        address: res.address || '',
        latitude: res.latitude,
        longitude: res.longitude,
      }
      uni.showToast({ title: '已选择地图门店', icon: 'success' })
    },
    fail: () => uni.showToast({ title: '选点取消', icon: 'none' }),
  })
}

function selectMapStore() {
  if (!mapStore.value) return
  const title = mapStore.value.name.trim()
  const matched = storeList.value.find((s) => s.name && (s.name.includes(title) || title.includes(s.name)))
  const target = matched || storeList.value[0]
  if (!target) {
    uni.showToast({ title: '暂无可关联的平台门店', icon: 'none' })
    return
  }
  selectStore(target, title || target.name, mapStore.value.address || target.address || '')
}

onMounted(async () => {
  try { storeList.value = await getStoreList() } catch {}
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.tip { display: block; font-size: 26rpx; color: #909399; margin-bottom: 16rpx; }
.location-text {
  margin-bottom: 14rpx;
  color: #606266;
  font-size: 24rpx;
}
.toolbar {
  display: flex;
  gap: 14rpx;
}
.selected-card {
  border: 2rpx solid #409eff;
  background: #ecf5ff;
}
.store-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #ebeef5;
}
.info { flex: 1; margin-right: 16rpx; }
.name { display: block; font-size: 30rpx; font-weight: 600; margin-bottom: 8rpx; }
.addr, .phone { display: block; font-size: 24rpx; color: #909399; }
</style>
