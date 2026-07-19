<template>
  <view class="page">
    <view class="search-card">
      <view class="search-box">
        <text class="search-icon">⌕</text>
        <input
          v-model="keyword"
          class="search-input"
          placeholder="搜索附近：干洗店 / 洗衣店 / 商圈"
          confirm-type="search"
          @confirm="chooseNearbyArea"
        />
      </view>
      <button class="map-btn" @click="chooseNearbyArea">地图搜索</button>
    </view>

    <view class="hint-card">
      <view>
        <text class="hint-title">附近干洗店</text>
        <text class="hint-desc">
          {{ selectedAreaText || '先定位当前位置，再通过地图搜索附近干洗店' }}
        </text>
      </view>
      <button class="refresh-btn" :loading="locating" @click="locateUser">定位</button>
    </view>

    <view class="map-card">
      <map
        v-if="mapReady"
        class="map"
        :latitude="mapCenter.latitude"
        :longitude="mapCenter.longitude"
        :markers="mapMarkers"
        scale="14"
        show-location
      />
      <view v-else class="map-empty" @click="locateUser">
        <text>点击定位当前位置</text>
      </view>
    </view>

    <view v-if="nearbyStore" class="card selected-card">
      <text class="section-title">地图搜索结果</text>
      <view class="store-item">
        <view class="info">
          <text class="name">{{ nearbyStore.name }}</text>
          <text class="addr">{{ nearbyStore.address || '地图选点地址' }}</text>
        </view>
        <button class="select-btn" @click="selectNearbyStore">选择该门店</button>
      </view>
      <text class="match-tip">会自动匹配平台门店用于下单，页面展示地图中选中的门店名称和地址。</text>
    </view>

    <view class="card">
      <view class="section-row">
        <text class="section-title">平台下单门店</text>
        <button class="tiny-btn" :loading="loading" @click="loadStores">刷新</button>
      </view>
      <view v-if="!filteredStores.length" class="empty-wrap">暂无匹配门店，请换个关键词试试</view>
      <view v-for="s in filteredStores" :key="s.id" class="store-item">
        <view class="info">
          <text class="name">{{ s.name }}</text>
          <text class="addr">{{ s.address }}</text>
          <text v-if="s.phone" class="phone">{{ s.phone }}</text>
        </view>
        <button class="select-btn" @click="selectStore(s)">选择该门店</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { computed, ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getStoreList, type StoreItem } from '@/api/store'

const storeList = ref<StoreItem[]>([])
const loading = ref(false)
const locating = ref(false)
const keyword = ref('')
const selectedAreaText = ref('')
const nearbyStore = ref<{ name: string; address: string; latitude: number; longitude: number } | null>(null)
const mapCenter = ref({ latitude: 39.908823, longitude: 116.39747 })
const mapReady = ref(false)
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

const filteredStores = computed(() => {
  const kw = keyword.value.trim()
  if (!kw) return storeList.value
  if (isMapSearchKeyword(kw)) return storeList.value
  return storeList.value.filter((s) => {
    const text = `${s.name || ''} ${s.address || ''} ${s.phone || ''}`
    return text.includes(kw)
  })
})

const mapMarkers = computed(() => {
  const markers: any[] = []
  markers.push({
    id: 1,
    latitude: mapCenter.value.latitude,
    longitude: mapCenter.value.longitude,
    title: '当前位置',
    iconPath: '/static/tab/store-active.png',
    width: 28,
    height: 28,
  })
  if (nearbyStore.value) {
    markers.push({
      id: 2,
      latitude: nearbyStore.value.latitude,
      longitude: nearbyStore.value.longitude,
      title: nearbyStore.value.name,
      iconPath: '/static/tab/service-active.png',
      width: 32,
      height: 32,
    })
  }
  return markers
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

function chooseNearbyArea() {
  const searchKeyword = keyword.value.trim() || '干洗店'
  uni.chooseLocation({
    keyword: searchKeyword,
    success: (res) => {
      const title = (res.name || '').trim()
      const address = (res.address || '').trim()
      nearbyStore.value = {
        name: title || '附近干洗店',
        address,
        latitude: Number(res.latitude) || mapCenter.value.latitude,
        longitude: Number(res.longitude) || mapCenter.value.longitude,
      }
      mapCenter.value = {
        latitude: nearbyStore.value.latitude,
        longitude: nearbyStore.value.longitude,
      }
      mapReady.value = true
      selectedAreaText.value = title || address ? `已选择附近：${title || address}` : '已打开地图选择附近干洗店'
      uni.showToast({ title: '已搜索附近干洗店', icon: 'success' })
    },
    fail: () => uni.showToast({ title: '选点取消', icon: 'none' }),
  })
}

function isMapSearchKeyword(kw: string) {
  return ['干洗店', '洗衣店', '干洗', '洗衣', '附近干洗店', '附近洗衣店'].includes(kw)
}

function locateUser() {
  locating.value = true
  uni.getLocation({
    type: 'gcj02',
    success: (res) => {
      mapCenter.value = {
        latitude: res.latitude,
        longitude: res.longitude,
      }
      mapReady.value = true
      selectedAreaText.value = '已定位当前位置，可点击“地图搜索”查找附近干洗店'
      uni.showToast({ title: '定位成功', icon: 'success' })
    },
    fail: () => {
      uni.showModal({
        title: '定位失败',
        content: '请在小程序设置中允许使用位置信息，或直接点击“地图搜索”手动选择附近干洗店。',
        confirmText: '去设置',
        success: (res) => {
          if (res.confirm) uni.openSetting()
        },
      })
    },
    complete: () => {
      locating.value = false
    },
  })
}

function selectNearbyStore() {
  if (!nearbyStore.value) return
  const title = nearbyStore.value.name || ''
  const address = nearbyStore.value.address || ''
  const matched = storeList.value.find((s) => {
    const name = s.name || ''
    const addr = s.address || ''
    return (name && (title.includes(name) || name.includes(title))) ||
      (addr && address && (address.includes(addr) || addr.includes(address)))
  })
  const target = matched || storeList.value[0]
  if (!target) {
    uni.showToast({ title: '暂无平台门店，请先在管理端添加门店', icon: 'none' })
    return
  }
  selectStore(target, title || target.name, address || target.address || '')
}

async function loadStores() {
  loading.value = true
  try {
    storeList.value = await getStoreList()
  } catch {
    storeList.value = []
  } finally {
    loading.value = false
  }
}

onMounted(loadStores)
onMounted(locateUser)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 24rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f6fbff 0%, #f8fafc 58%, #ffffff 100%);
}

.search-card,
.hint-card,
.card {
  margin-bottom: 22rpx;
  border-radius: 22rpx;
  background: #fff;
  box-shadow: 0 14rpx 38rpx rgba(31, 89, 154, 0.08);
}

.search-card {
  padding: 22rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.search-box {
  flex: 1;
  height: 76rpx;
  padding: 0 22rpx;
  border-radius: 999rpx;
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: #f3f6fb;
}

.search-icon {
  color: #8b95a5;
  font-size: 34rpx;
}

.search-input {
  flex: 1;
  color: #111827;
  font-size: 28rpx;
}

.map-btn {
  width: 168rpx;
  height: 76rpx;
  line-height: 76rpx;
  border-radius: 999rpx;
  color: #fff;
  background: linear-gradient(135deg, #2f86ff, #1768f2);
  font-size: 28rpx;
  font-weight: 800;
}

.map-btn::after,
.refresh-btn::after,
.select-btn::after {
  border: 0;
}

.hint-card {
  padding: 24rpx;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16rpx;
}

.map-card {
  margin-bottom: 22rpx;
  border-radius: 22rpx;
  background: #fff;
  box-shadow: 0 14rpx 38rpx rgba(31, 89, 154, 0.08);
  overflow: hidden;
}

.map,
.map-empty {
  width: 100%;
  height: 360rpx;
}

.map-empty {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6b7280;
  font-size: 28rpx;
  background: linear-gradient(135deg, #edf5ff, #f8fbff);
}

.selected-card {
  border: 2rpx solid #409eff;
  background: #f7fbff;
}

.match-tip {
  display: block;
  margin: 0 0 18rpx;
  color: #6b7280;
  font-size: 24rpx;
  line-height: 1.5;
}

.section-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14rpx;
}

.hint-title {
  display: block;
  color: #111827;
  font-size: 34rpx;
  font-weight: 800;
}

.hint-desc {
  display: block;
  margin-top: 8rpx;
  color: #6b7280;
  font-size: 25rpx;
  line-height: 1.5;
}

.refresh-btn {
  width: 120rpx;
  height: 60rpx;
  line-height: 60rpx;
  border-radius: 999rpx;
  color: #2474ff;
  background: #eef5ff;
  font-size: 24rpx;
}

.tiny-btn {
  width: 104rpx;
  height: 54rpx;
  line-height: 54rpx;
  border-radius: 999rpx;
  color: #2474ff;
  background: #eef5ff;
  font-size: 23rpx;
}

.card {
  padding: 28rpx 28rpx 8rpx;
}

.section-title {
  display: block;
  color: #111827;
  font-size: 34rpx;
  font-weight: 800;
}

.empty-wrap {
  padding: 70rpx 0;
  color: #8b95a5;
  text-align: center;
  font-size: 28rpx;
}

.store-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18rpx;
  padding: 26rpx 0;
  border-bottom: 1rpx solid #e8edf5;
}

.store-item:last-child {
  border-bottom: 0;
}

.info {
  flex: 1;
  min-width: 0;
}

.name {
  display: block;
  margin-bottom: 8rpx;
  color: #111827;
  font-size: 30rpx;
  font-weight: 800;
}

.addr,
.phone {
  display: block;
  color: #6b7280;
  font-size: 25rpx;
  line-height: 1.45;
}

.select-btn {
  width: 168rpx;
  height: 64rpx;
  line-height: 64rpx;
  border-radius: 999rpx;
  color: #fff;
  background: linear-gradient(135deg, #2f86ff, #1768f2);
  font-size: 25rpx;
  font-weight: 800;
}
</style>
