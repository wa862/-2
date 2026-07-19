<template>
  <view class="page">
    <view class="card">
      <text class="tip">选择系统门店，或使用微信地图选点辅助定位</text>
      <button size="mini" :loading="locating" @click="locate">重新定位</button>
      <button size="mini" @click="chooseLocation">地图选点</button>
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

function selectStore(s: StoreItem) {
  if (from.value === 'order-create' && serviceId.value) {
    let url = `/pages/service/order-create?serviceId=${serviceId.value}&storeId=${s.id}`
    url += `&storeName=${encodeURIComponent(s.name || '该门店')}`
    if (s.address) url += `&storeAddress=${encodeURIComponent(s.address)}`
    if (specName.value) url += `&specName=${encodeURIComponent(specName.value)}`
    if (quantity.value) url += `&quantity=${encodeURIComponent(quantity.value)}`
    if (remark.value) url += `&remark=${encodeURIComponent(remark.value)}`
    uni.redirectTo({ url })
    uni.showToast({ title: `已选择${s.name}`, icon: 'success' })
    return
  }
  if (from.value === 'cart') {
    uni.switchTab({ url: '/pages/cart/cart' })
    uni.setStorageSync('selected_store', JSON.stringify({ id: s.id, name: s.name, address: s.address || '' }))
    uni.showToast({ title: `已选择${s.name}`, icon: 'success' })
    return
  }
  if (from.value === 'checkout' && cartIds.value) {
    let url = `/pages/checkout/checkout?ids=${encodeURIComponent(cartIds.value)}&storeId=${s.id}`
    url += `&storeName=${encodeURIComponent(s.name || '该门店')}`
    if (s.address) url += `&storeAddress=${encodeURIComponent(s.address)}`
    if (addressId.value) url += `&addressId=${encodeURIComponent(addressId.value)}`
    if (deliveryType.value) url += `&deliveryType=${encodeURIComponent(deliveryType.value)}`
    if (pickupDate.value) url += `&pickupDate=${encodeURIComponent(pickupDate.value)}`
    if (urgent.value) url += `&urgent=${encodeURIComponent(urgent.value)}`
    uni.redirectTo({ url })
    uni.showToast({ title: `已选择${s.name}`, icon: 'success' })
    return
  }
  uni.setStorageSync('selected_store', JSON.stringify({ id: s.id, name: s.name }))
  uni.navigateBack()
  uni.showToast({ title: `已选择${s.name}`, icon: 'success' })
}

function locate() {
  locating.value = true
  uni.getLocation({
    type: 'gcj02',
    success: () => uni.showToast({ title: '定位成功', icon: 'success' }),
    fail: () => uni.showToast({ title: '定位失败，请授权', icon: 'none' }),
    complete: () => { locating.value = false },
  })
}

function chooseLocation() {
  uni.chooseLocation({
    success: () => uni.showToast({ title: '已选点', icon: 'success' }),
    fail: () => uni.showToast({ title: '选点取消', icon: 'none' }),
  })
}

onMounted(async () => {
  try { storeList.value = await getStoreList() } catch {}
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.tip { display: block; font-size: 26rpx; color: #909399; margin-bottom: 16rpx; }
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
