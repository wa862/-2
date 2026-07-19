<template>
  <view class="page">
    <view v-if="!store.token" class="empty-wrap">
      <text>请先登录后查看购物车</text>
      <button class="login-btn" @click="goLogin">去登录</button>
    </view>

    <view v-else-if="!list.length && !loading" class="empty-wrap">购物车是空的</view>

    <view v-else class="content">
      <view class="top-card">
        <view class="top-row" @click="showAddressPicker = true">
          <text class="top-icon address-icon">⌖</text>
          <text class="top-label">送至：</text>
          <text class="top-value">{{ selectedAddressText }}</text>
          <text class="arrow">›</text>
        </view>
        <view class="divider"></view>
        <view class="top-row" @click="goNearbyStore">
          <text class="top-icon store-icon">▣</text>
          <text class="top-label">门店：</text>
          <text class="top-value">{{ selectedStoreText }}</text>
          <text class="arrow">›</text>
        </view>
      </view>

      <view v-if="serviceList.length" class="group-card">
        <view class="group-title">
          <text class="group-icon">▣</text>
          <text>干洗服务</text>
        </view>
        <view v-for="item in serviceList" :key="item.id" class="cart-row">
          <view class="select-dot" :class="{ active: selectedMap[item.id] }" @click="toggle(item.id)">
            <text v-if="selectedMap[item.id]">✓</text>
          </view>
          <image v-if="imageOf(item.image)" class="item-img" :src="imageOf(item.image)" mode="aspectFill" />
          <view v-else class="item-img placeholder">洗</view>
          <view class="item-main">
            <view class="name-line">
              <text class="item-name">{{ item.name }}</text>
              <text v-if="item.serviceSpecName" class="spec-tag">{{ item.serviceSpecName }}</text>
            </view>
            <view class="price-line">
              <text class="price">¥{{ money(item.price) }}</text>
            </view>
            <view class="qty-control">
              <text class="qty-btn" @click="changeQty(item, -1)">−</text>
              <text class="qty-num">{{ item.quantity }}</text>
              <text class="qty-btn" @click="changeQty(item, 1)">＋</text>
            </view>
          </view>
          <view class="row-side">
            <text class="delete" @click="remove(item.id)">删除</text>
            <text class="times">× {{ item.quantity }}</text>
          </view>
        </view>
      </view>

      <view v-if="productList.length" class="group-card">
        <view class="group-title">
          <text class="group-icon">▣</text>
          <text>商品</text>
        </view>
        <view
          v-for="(item, index) in productList"
          :key="item.id"
          class="cart-row"
          :class="{ separated: index > 0 }"
        >
          <view class="select-dot" :class="{ active: selectedMap[item.id] }" @click="toggle(item.id)">
            <text v-if="selectedMap[item.id]">✓</text>
          </view>
          <image v-if="imageOf(item.image)" class="item-img" :src="imageOf(item.image)" mode="aspectFill" />
          <view v-else class="item-img placeholder">品</view>
          <view class="item-main">
            <text class="item-name single">{{ item.name }}</text>
            <view class="price-line">
              <text class="price">¥{{ money(item.price) }}</text>
            </view>
            <view class="qty-control">
              <text class="qty-btn" @click="changeQty(item, -1)">−</text>
              <text class="qty-num">{{ item.quantity }}</text>
              <text class="qty-btn" @click="changeQty(item, 1)">＋</text>
            </view>
          </view>
          <view class="row-side">
            <text class="delete" @click="remove(item.id)">删除</text>
            <text class="times">× {{ item.quantity }}</text>
          </view>
        </view>
      </view>

      <view class="remark-card">
        <view class="remark-main">
          <text class="remark-icon">▤</text>
          <view>
            <text class="remark-title">备注</text>
            <input v-model="remark" class="remark-input" placeholder="选填：请输入您的备注信息（如衣物特殊要求等）" />
          </view>
        </view>
        <text class="arrow small">›</text>
      </view>
    </view>

    <view v-if="store.token && list.length" class="footer">
      <view class="all-check" @click="toggleAll">
        <view class="select-dot active" :class="{ muted: !allChecked }">
          <text v-if="allChecked">✓</text>
        </view>
        <text>全选</text>
      </view>
      <view class="total-box">
        <view>
          <text>合计：</text>
          <text class="total">¥{{ selectedTotal.toFixed(2) }}</text>
        </view>
        <text class="discount">已优惠： ¥0.00</text>
      </view>
      <button class="checkout-btn" :disabled="selectedCount === 0" @click="goCheckout">
        去结算（{{ selectedCount }}）
      </button>
    </view>

    <view v-if="showAddressPicker" class="mask" @click="showAddressPicker=false">
      <view class="dialog" @click.stop>
        <text class="dialog-title">选择地址</text>
        <view v-for="a in addressList" :key="a.id" class="pick-item" @click="selectAddress(a.id)">
          <text class="pick-title">{{ a.contactName }} {{ a.phone }}</text>
          <text class="pick-desc">{{ fullAddress(a) }}</text>
        </view>
      </view>
    </view>

    <view v-if="showStorePicker" class="mask" @click="showStorePicker=false">
      <view class="dialog" @click.stop>
        <text class="dialog-title">选择门店</text>
        <view v-for="s in storeList" :key="s.id" class="pick-item" @click="selectStore(s.id, s.name)">
          <text class="pick-title">{{ s.name }}</text>
          <text class="pick-desc">{{ s.address }}</text>
        </view>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { getCartList, updateCartQuantity, removeCartItem, type CartItem } from '@/api/cart'
import { getAddressList, type UserAddressItem } from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import { fullAddress, resolveImageUrl } from '@/utils'

const store = useUserStore()
const list = ref<CartItem[]>([])
const loading = ref(false)
const selectedMap = reactive<Record<number, boolean>>({})
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(null)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(null)
const selectedStoreName = ref('')
const selectedStoreAddress = ref('')
const showAddressPicker = ref(false)
const showStorePicker = ref(false)
const remark = ref('')

const serviceList = computed(() => list.value.filter((i) => i.itemType === 'SERVICE'))
const productList = computed(() => list.value.filter((i) => i.itemType === 'PRODUCT'))
const selectedCount = computed(() => list.value.filter((i) => selectedMap[i.id]).length)
const allChecked = computed(() => list.value.length > 0 && list.value.every((i) => selectedMap[i.id]))
const selectedTotal = computed(() =>
  list.value.filter((i) => selectedMap[i.id]).reduce((s, i) => s + Number(i.price) * i.quantity, 0)
)
const selectedAddressText = computed(() => {
  const a = addressList.value.find((x) => x.id === selectedAddressId.value)
  return a ? fullAddress(a) : '请选择地址'
})
const selectedStoreText = computed(() => selectedStoreName.value || '请选择门店')

onLoad((q) => {
  if (q && q.storeId) selectedStoreId.value = Number(q.storeId)
  if (q && q.storeName) selectedStoreName.value = decodeURIComponent(String(q.storeName))
  if (q && q.storeAddress) selectedStoreAddress.value = decodeURIComponent(String(q.storeAddress))
})

function imageOf(url?: string) {
  if (!url || url.includes('th.bing.com')) return ''
  return resolveImageUrl(url)
}

function money(val: number) {
  return Number(val || 0).toFixed(2)
}

function toggle(id: number) { selectedMap[id] = !selectedMap[id] }
function toggleAll() {
  const v = !allChecked.value
  list.value.forEach((i) => { selectedMap[i.id] = v })
}
function selectAddress(id: number) { selectedAddressId.value = id; showAddressPicker.value = false }
function selectStore(id: number, name: string) {
  selectedStoreId.value = id
  selectedStoreName.value = name
  selectedStoreAddress.value = storeList.value.find((s) => s.id === id)?.address || ''
  showStorePicker.value = false
  uni.setStorageSync('selected_store', JSON.stringify({
    id,
    name,
    address: selectedStoreAddress.value,
  }))
}

async function load() {
  if (!store.token) return
  loading.value = true
  try {
    list.value = await getCartList()
    list.value.forEach((i) => { if (selectedMap[i.id] === undefined) selectedMap[i.id] = true })
  } catch {}
  loading.value = false
}

async function changeQty(item: CartItem, d: number) {
  const q = Math.max(1, Math.min(99, item.quantity + d))
  try {
    await updateCartQuantity(item.id, q)
    item.quantity = q
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

async function remove(id: number) {
  try {
    await removeCartItem(id)
    list.value = list.value.filter((i) => i.id !== id)
    delete selectedMap[id]
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

function goNearbyStore() {
  uni.navigateTo({ url: '/pages/store/nearby?from=cart' })
}

function goCheckout() {
  const ids = list.value.filter((i) => selectedMap[i.id]).map((i) => i.id).join(',')
  if (!ids) return
  let url = `/pages/checkout/checkout?ids=${ids}`
  if (selectedAddressId.value) url += `&addressId=${selectedAddressId.value}`
  if (selectedStoreId.value) url += `&storeId=${selectedStoreId.value}`
  if (selectedStoreName.value) url += `&storeName=${encodeURIComponent(selectedStoreName.value)}`
  if (selectedStoreAddress.value) url += `&storeAddress=${encodeURIComponent(selectedStoreAddress.value)}`
  if (remark.value) url += `&remark=${encodeURIComponent(remark.value)}`
  uni.navigateTo({ url })
}

function goLogin() { uni.navigateTo({ url: '/pages/login/login?redirect=/pages/cart/cart' }) }

onShow(() => {
  syncSelectedStore()
  load()
  getAddressList().then((data) => {
    addressList.value = data
    const d = data.find((a) => a.isDefault) || data[0]
    if (d && !selectedAddressId.value) selectedAddressId.value = d.id
  }).catch(() => {})
  getStoreList().then((data) => {
    storeList.value = data
    if (selectedStoreId.value) {
      const hit = data.find((s) => s.id === selectedStoreId.value)
      if (hit && !selectedStoreName.value) {
        selectedStoreName.value = hit.name
        selectedStoreAddress.value = hit.address || ''
      }
    }
  }).catch(() => {})
})
onMounted(load)

function syncSelectedStore() {
  try {
    const raw = uni.getStorageSync('selected_store')
    if (!raw) return
    const data = typeof raw === 'string' ? JSON.parse(raw) : raw
    if (!data || !data.id) return
    selectedStoreId.value = Number(data.id)
    selectedStoreName.value = data.name || ''
    selectedStoreAddress.value = data.address || ''
  } catch {}
}
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 22rpx 30rpx 178rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f7fbff 0%, #f8fafc 52%, #ffffff 100%);
  color: #111827;
}

.empty-wrap {
  padding: 120rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24rpx;
  color: #8b95a5;
  font-size: 30rpx;
}

.login-btn {
  width: 220rpx;
  color: #fff;
  border-radius: 999rpx;
  background: #2474ff;
}

.top-card,
.group-card,
.footer {
  border-radius: 20rpx;
  background: #fff;
  box-shadow: 0 14rpx 38rpx rgba(31, 89, 154, 0.08);
}

.top-card {
  margin-bottom: 26rpx;
  padding: 20rpx 30rpx;
}

.top-row {
  min-height: 86rpx;
  display: flex;
  align-items: center;
  gap: 14rpx;
}

.top-icon {
  width: 50rpx;
  height: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 30rpx;
  font-weight: 800;
  flex-shrink: 0;
}

.address-icon {
  color: #ff4d83;
  background: #ffeaf1;
}

.store-icon {
  color: #2474ff;
  background: #e8f1ff;
}

.top-label,
.top-value {
  font-size: 30rpx;
}

.top-label {
  color: #6b7280;
}

.top-value {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-weight: 700;
}

.arrow {
  color: #7b8494;
  font-size: 52rpx;
}

.arrow.small {
  font-size: 42rpx;
}

.divider {
  height: 1rpx;
  margin-left: 52rpx;
  background: #e5eaf2;
}

.group-card {
  margin-bottom: 24rpx;
  padding: 28rpx 28rpx 10rpx;
}

.group-title {
  margin-bottom: 24rpx;
  display: flex;
  align-items: center;
  gap: 14rpx;
  font-size: 34rpx;
  font-weight: 800;
}

.group-icon {
  width: 54rpx;
  height: 54rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  color: #2474ff;
  background: #edf5ff;
  font-size: 30rpx;
}

.cart-row {
  position: relative;
  min-height: 212rpx;
  padding-bottom: 26rpx;
  display: flex;
  align-items: center;
  gap: 24rpx;
}

.cart-row.separated {
  padding-top: 26rpx;
  margin-top: 26rpx;
  border-top: 1rpx solid #e7edf5;
}

.select-dot {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2rpx solid #c5ceda;
  box-sizing: border-box;
  color: #fff;
  font-size: 28rpx;
  flex-shrink: 0;
}

.select-dot.active {
  border-color: #2474ff;
  background: #2474ff;
}

.select-dot.muted {
  background: #fff;
}

.item-img {
  width: 168rpx;
  height: 168rpx;
  border-radius: 14rpx;
  background: #f3f6fb;
  flex-shrink: 0;
}

.placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #2474ff;
  font-size: 44rpx;
  font-weight: 800;
}

.item-main {
  flex: 1;
  min-width: 0;
}

.name-line {
  display: flex;
  align-items: center;
  gap: 12rpx;
  min-width: 0;
}

.item-name {
  max-width: 300rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #111827;
  font-size: 32rpx;
  font-weight: 700;
}

.item-name.single {
  display: block;
  margin-bottom: 22rpx;
  max-width: 360rpx;
}

.spec-tag {
  padding: 4rpx 12rpx;
  border-radius: 8rpx;
  color: #2474ff;
  background: #edf5ff;
  font-size: 22rpx;
  flex-shrink: 0;
}

.price-line {
  margin-top: 22rpx;
}

.price {
  color: #ff2828;
  font-size: 32rpx;
  font-weight: 800;
}

.qty-control {
  margin-top: 20rpx;
  width: 210rpx;
  height: 52rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1rpx solid #dce3ec;
  border-radius: 999rpx;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.7);
}

.qty-btn {
  width: 68rpx;
  height: 52rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #5d6b7d;
  background: linear-gradient(180deg, #ffffff, #f6f8fb);
  font-size: 34rpx;
}

.qty-num {
  min-width: 70rpx;
  height: 52rpx;
  line-height: 52rpx;
  text-align: center;
  border-left: 1rpx solid #edf1f6;
  border-right: 1rpx solid #edf1f6;
  color: #111827;
  font-size: 28rpx;
}

.row-side {
  position: absolute;
  right: 0;
  top: 22rpx;
  bottom: 58rpx;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: space-between;
}

.delete {
  color: #ff1f1f;
  font-size: 28rpx;
}

.times {
  color: #111827;
  font-size: 28rpx;
}

.remark-main {
  display: flex;
  align-items: center;
}

.remark-title {
  display: block;
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}

.remark-card {
  margin-bottom: 24rpx;
  padding: 24rpx 28rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  box-shadow: 0 14rpx 38rpx rgba(31, 89, 154, 0.08);
}

.remark-main {
  flex: 1;
  gap: 18rpx;
  min-width: 0;
}

.remark-icon {
  width: 54rpx;
  height: 54rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 14rpx;
  color: #2474ff;
  background: #e8f1ff;
  font-size: 30rpx;
  font-weight: 800;
  flex-shrink: 0;
}

.remark-input {
  width: 560rpx;
  height: 38rpx;
  color: #111827;
  font-size: 24rpx;
}

.remark-input::placeholder {
  color: #6b7280;
}

.footer {
  position: fixed;
  left: 0;
  right: 0;
  bottom: calc(100rpx + env(safe-area-inset-bottom));
  height: 118rpx;
  padding: 0 30rpx;
  display: flex;
  align-items: center;
  gap: 22rpx;
  box-sizing: border-box;
  border-radius: 0;
  box-shadow: 0 -10rpx 30rpx rgba(31, 89, 154, 0.08);
  z-index: 18;
}

.all-check {
  display: flex;
  align-items: center;
  gap: 12rpx;
  font-size: 30rpx;
}

.total-box {
  flex: 1;
  text-align: center;
  color: #111827;
  font-size: 28rpx;
}

.total {
  margin-left: 8rpx;
  color: #ff2828;
  font-size: 32rpx;
  font-weight: 800;
}

.discount {
  display: block;
  margin-top: 4rpx;
  color: #8b95a5;
  font-size: 24rpx;
}

.checkout-btn {
  width: 278rpx;
  height: 78rpx;
  color: #fff;
  border-radius: 999rpx;
  background: linear-gradient(135deg, #2f86ff, #1768f2);
  font-size: 30rpx;
  font-weight: 800;
}

.checkout-btn::after,
.login-btn::after {
  border: 0;
}

.mask {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: flex-end;
  background: rgba(15, 23, 42, 0.42);
  z-index: 50;
}

.dialog {
  width: 100%;
  max-height: 70vh;
  padding: 32rpx;
  border-radius: 28rpx 28rpx 0 0;
  background: #fff;
  box-sizing: border-box;
  overflow-y: auto;
}

.dialog-title {
  display: block;
  margin-bottom: 18rpx;
  font-size: 34rpx;
  font-weight: 800;
}

.pick-item {
  padding: 22rpx 0;
  border-bottom: 1rpx solid #e8edf5;
}

.pick-title,
.pick-desc {
  display: block;
}

.pick-title {
  color: #111827;
  font-size: 30rpx;
  font-weight: 700;
}

.pick-desc {
  margin-top: 8rpx;
  color: #6b7280;
  font-size: 26rpx;
}
</style>
