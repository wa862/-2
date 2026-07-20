<template>
  <view class="page">
    <view v-if="!store.token" class="empty-wrap">
      <button class="btn-primary" size="mini" @click="goLogin">去登录</button>
    </view>
    <view v-else-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!selectedList.length" class="empty-wrap">未选择商品</view>
    <view v-else>
      <view class="card">
        <text class="section-title">收货地址</text>
        <radio-group @change="onAddressChange">
          <label v-for="a in addressList" :key="a.id" class="radio-item">
            <radio :value="String(a.id)" :checked="selectedAddressId===a.id" />
            <view>
              <text>{{ a.contactName }} {{ maskPhone(a.phone) }}</text>
              <text class="sub">{{ fullAddress(a) }}</text>
            </view>
          </label>
        </radio-group>
      </view>

      <view v-if="serviceItems.length" class="card">
        <text class="section-title">取送方式</text>
        <radio-group @change="onDeliveryChange">
          <label class="radio-item"><radio value="DOOR_TO_DOOR" :checked="deliveryType==='DOOR_TO_DOOR'" />上门取送</label>
          <label class="radio-item"><radio value="IN_STORE" :checked="deliveryType==='IN_STORE'" />到店自取</label>
        </radio-group>
        <text class="section-title">取衣日期</text>
        <picker mode="date" :value="pickupDate" :start="minPickupDate" @change="onDateChange">
          <view class="picker">{{ pickupDate }}</view>
        </picker>
        <label class="radio-item"><checkbox :checked="urgent" @click="urgent=!urgent" />加急</label>
        <view class="label-row">
          <text class="section-title">选择门店</text>
          <text class="nearby-link" @click="goNearbyStore">查看附近门店</text>
        </view>
        <view class="selected-store-card" @click="goNearbyStore">
          <view class="store-radio active"><text>✓</text></view>
          <view class="store-main">
            <view class="store-title-line">
              <text class="store-name">{{ selectedStoreText }}</text>
              <text v-if="selectedStoreId" class="selected-tag">已选择</text>
            </view>
            <text class="store-addr">{{ selectedStoreAddressText || '点击定位选择附近门店' }}</text>
          </view>
          <text class="store-change">更换</text>
        </view>
      </view>

      <view v-if="serviceItems.length" class="card">
        <text class="section-title">干洗服务</text>
        <view v-for="item in serviceItems" :key="item.id" class="line">
          <text>{{ item.name }} × {{ item.quantity }}</text>
          <text class="price">¥{{ (item.price * item.quantity).toFixed(2) }}</text>
        </view>
      </view>
      <view v-if="productItems.length" class="card">
        <text class="section-title">商品</text>
        <view v-for="item in productItems" :key="item.id" class="line">
          <text>{{ item.name }} × {{ item.quantity }}</text>
          <text class="price">¥{{ (item.price * item.quantity).toFixed(2) }}</text>
        </view>
      </view>

      <view class="card total-card">
        <text>实付合计：</text>
        <text class="price big">¥{{ payTotal.toFixed(2) }}</text>
      </view>

      <button class="btn-primary submit" :loading="submitting" @click="submit">提交订单</button>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { getCartList, removeCartItem, type CartItem } from '@/api/cart'
import { getAddressList, type UserAddressItem } from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import { createOrder, createProductOrder } from '@/api/order'
import { fullAddress, maskPhone, addDaysISO, requireLogin } from '@/utils'

const store = useUserStore()
const loading = ref(true)
const submitting = ref(false)
const cartIds = ref<number[]>([])
const selectedList = ref<CartItem[]>([])
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(null)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(null)
const selectedStoreName = ref('')
const selectedStoreAddress = ref('')
const deliveryType = ref('DOOR_TO_DOOR')
const pickupDate = ref(addDaysISO(3))
const urgent = ref(false)
const minPickupDate = addDaysISO(1)

const serviceItems = computed(() => selectedList.value.filter((i) => i.itemType === 'SERVICE'))
const productItems = computed(() => selectedList.value.filter((i) => i.itemType === 'PRODUCT'))
const payTotal = computed(() =>
  selectedList.value.reduce((s, i) => s + Number(i.price) * i.quantity, 0)
)
const selectedStore = computed(() => storeList.value.find((s) => s.id === selectedStoreId.value) || null)
const selectedStoreText = computed(() => selectedStoreName.value || (selectedStore.value ? selectedStore.value.name : '') || '请选择门店')
const selectedStoreAddressText = computed(() => selectedStoreAddress.value || (selectedStore.value ? selectedStore.value.address : '') || '')

onLoad((q) => {
  if (!requireLogin('/pages/checkout/checkout')) return
  cartIds.value = String((q && q.ids) || '').split(',').map(Number).filter(Boolean)
  if (q && q.addressId) selectedAddressId.value = Number(q.addressId)
  if (q && q.storeId) selectedStoreId.value = Number(q.storeId)
  if (q && q.storeName) selectedStoreName.value = decodeURIComponent(String(q.storeName))
  if (q && q.storeAddress) selectedStoreAddress.value = decodeURIComponent(String(q.storeAddress))
  if (q && q.deliveryType) deliveryType.value = String(q.deliveryType)
  if (q && q.pickupDate) pickupDate.value = String(q.pickupDate)
  if (q && q.urgent) urgent.value = String(q.urgent) === 'true'
})

function onAddressChange(e: any) { selectedAddressId.value = Number(e.detail.value) }
function onDeliveryChange(e: any) { deliveryType.value = e.detail.value }
function onDateChange(e: any) { pickupDate.value = e.detail.value }
function goLogin() { uni.navigateTo({ url: '/pages/login/login' }) }
function goNearbyStore() {
  let url = `/pages/store/nearby?from=checkout&ids=${cartIds.value.join(',')}`
  if (selectedAddressId.value) url += `&addressId=${selectedAddressId.value}`
  if (deliveryType.value) url += `&deliveryType=${encodeURIComponent(deliveryType.value)}`
  if (pickupDate.value) url += `&pickupDate=${encodeURIComponent(pickupDate.value)}`
  if (urgent.value) url += '&urgent=true'
  uni.navigateTo({ url })
}

async function submit() {
  if (!selectedAddressId.value) return uni.showToast({ title: '请选择地址', icon: 'none' })
  submitting.value = true
  try {
    for (const item of serviceItems.value) {
      await createOrder(
        item.serviceId!,
        item.quantity,
        undefined,
        selectedAddressId.value,
        deliveryType.value,
        selectedStoreId.value || undefined,
        item.serviceSpecName,
        pickupDate.value,
        urgent.value
      )
    }
    for (const item of productItems.value) {
      await createProductOrder(
        item.productId!,
        item.quantity,
        undefined,
        selectedAddressId.value,
        deliveryType.value,
        selectedStoreId.value || undefined
      )
    }
    for (const id of cartIds.value) {
      try { await removeCartItem(id) } catch {}
    }
    uni.showToast({ title: '下单成功', icon: 'success' })
    setTimeout(() => uni.redirectTo({ url: '/pages/order/list' }), 500)
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '下单失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  try {
    const [cart, addr, stores] = await Promise.all([getCartList(), getAddressList(), getStoreList()])
    selectedList.value = cart.filter((i) => cartIds.value.includes(i.id))
    addressList.value = addr
    storeList.value = stores
    if (!selectedAddressId.value) {
      const d = addr.find((a) => a.isDefault) || addr[0]
      if (d) selectedAddressId.value = d.id
    }
    if (!selectedStoreId.value && stores[0]) selectedStoreId.value = stores[0].id
  } catch {}
  loading.value = false
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; padding-bottom: 40rpx; }
.radio-item { display: flex; align-items: flex-start; gap: 12rpx; margin-bottom: 16rpx; font-size: 28rpx; }
.sub { display: block; font-size: 24rpx; color: #909399; margin-top: 4rpx; }
.picker { padding: 16rpx; background: #f5f7fa; border-radius: 8rpx; margin: 12rpx 0; }
.label-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 20rpx;
}
.label-row .section-title { margin-bottom: 12rpx; }
.nearby-link {
  color: #409eff;
  font-size: 26rpx;
}
.selected-store-card {
  min-height: 112rpx;
  padding: 20rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
  border: 1rpx solid #e8edf5;
  border-radius: 14rpx;
  background: linear-gradient(90deg, #edf5ff, #f8fbff);
  box-sizing: border-box;
}
.store-radio {
  width: 46rpx;
  height: 46rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2rpx solid #c4ccd8;
  color: #fff;
  font-size: 26rpx;
  box-sizing: border-box;
  flex-shrink: 0;
}
.store-radio.active {
  border-color: #2474ff;
  background: #2474ff;
}
.store-main {
  flex: 1;
  min-width: 0;
}
.store-title-line {
  display: flex;
  align-items: center;
  gap: 10rpx;
}
.store-name {
  max-width: 310rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #303133;
  font-size: 30rpx;
  font-weight: 700;
}
.selected-tag {
  padding: 2rpx 10rpx;
  border-radius: 8rpx;
  color: #2474ff;
  background: #dcecff;
  font-size: 22rpx;
  flex-shrink: 0;
}
.store-addr {
  display: block;
  margin-top: 6rpx;
  max-width: 410rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #909399;
  font-size: 24rpx;
}
.store-change {
  color: #409eff;
  font-size: 26rpx;
  flex-shrink: 0;
}
.line { display: flex; justify-content: space-between; padding: 12rpx 0; border-bottom: 1rpx solid #ebeef5; }
.price { color: #ff4d4f; }
.total-card { display: flex; justify-content: space-between; align-items: center; font-size: 32rpx; }
.big { font-size: 40rpx; font-weight: 700; }
.submit { width: 100%; height: 88rpx; line-height: 88rpx; margin-top: 24rpx; }
</style>
