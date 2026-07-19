<template>
  <view class="page">
    <view v-if="!service" class="empty-wrap">加载中...</view>
    <view v-else class="content">
      <view class="card service-card">
        <text class="section-title">选择服务</text>
        <view class="service-options">
          <view
            v-for="item in serviceOptions"
            :key="item.name"
            class="service-option"
            :class="{ active: selectedSpecName === item.name }"
            @click="selectSpec(item.name)"
          >
            <view class="service-icon">{{ item.icon }}</view>
            <view class="service-meta">
              <text class="service-name">{{ item.name }}</text>
              <text class="service-price">¥{{ item.price }}</text>
            </view>
          </view>
        </view>
        <view class="quantity-row">
          <text class="field-title">数量</text>
          <view class="qty-control">
            <text class="qty-btn minus" @click="changeQty(-1)">−</text>
            <text class="qty-num">{{ form.quantity }}</text>
            <text class="qty-btn plus" @click="changeQty(1)">+</text>
          </view>
        </view>
      </view>

      <view class="card delivery-card">
        <text class="section-title">取送方式</text>
        <view class="delivery-options">
          <view
            class="delivery-option"
            :class="{ active: deliveryType === 'DOOR_TO_DOOR' }"
            @click="deliveryType = 'DOOR_TO_DOOR'"
          >
            <view class="check-dot"><text v-if="deliveryType === 'DOOR_TO_DOOR'">✓</text></view>
            <view class="delivery-icon">🚚</view>
            <view>
              <text class="delivery-title">上门取送</text>
              <text class="delivery-desc">专人上门取衣，清洗后送回</text>
            </view>
          </view>
          <view
            class="delivery-option"
            :class="{ active: deliveryType === 'IN_STORE' }"
            @click="deliveryType = 'IN_STORE'"
          >
            <view class="check-dot"><text v-if="deliveryType === 'IN_STORE'">✓</text></view>
            <view class="delivery-icon">🏬</view>
            <view>
              <text class="delivery-title">到店自取</text>
              <text class="delivery-desc">到店下单，到店取衣</text>
            </view>
          </view>
        </view>

        <picker mode="date" :value="pickupDate" :start="minPickupDate" @change="onDateChange">
          <view class="info-row border-top">
            <text class="field-title">取衣日期</text>
            <view class="info-value">
              <text class="muted-icon">▣</text>
              <text>{{ pickupDateText }}</text>
            </view>
            <text class="arrow">›</text>
          </view>
        </picker>

        <view class="urgent-row">
          <view class="checkbox" :class="{ checked: urgent }" @click="urgent = !urgent">
            <text v-if="urgent">✓</text>
          </view>
          <text>加急（更快取回）</text>
          <text class="recommend">推荐</text>
        </view>

        <view class="info-row border-top" @click="showAddressPicker = true">
          <text class="field-title">取送地址</text>
          <view class="info-value address">
            <text class="muted-icon">⌖</text>
            <text>{{ selectedAddressText }}</text>
          </view>
          <text class="arrow">›</text>
        </view>
      </view>

      <view class="card store-card">
        <view class="section-head">
          <text class="section-title">选择门店</text>
          <text class="link" @click="goNearby">查看附近门店</text>
        </view>
        <view class="selected-store-card" @click="goNearby">
          <view class="store-radio active"><text>✓</text></view>
          <view class="store-info">
            <view class="store-title-line">
              <text class="store-name">{{ selectedStoreText }}</text>
              <text v-if="selectedStoreId" class="nearest">已选择</text>
            </view>
            <text class="store-addr">{{ selectedStoreAddressText || '点击选择附近门店' }}</text>
          </view>
          <text class="store-change">更换</text>
        </view>
      </view>

      <view class="card remark-card">
        <text class="section-title">备注</text>
        <textarea
          v-model="form.remark"
          maxlength="100"
          placeholder="请输入备注信息（可选）"
          class="textarea"
        />
        <text class="count">{{ form.remark.length }}/100</text>
      </view>
    </view>

    <view class="footer" v-if="service">
      <button class="cart-btn" @click="addCart">
        <text class="cart-icon">🛒</text>
        <text>加入购物车</text>
      </button>
      <button class="reserve-btn" :loading="submitting" @click="submit">立即预约</button>
      <text class="agreement">提交订单即表示同意《用户服务协议》</text>
    </view>

    <view v-if="showAddressPicker" class="mask" @click="showAddressPicker=false">
      <view class="dialog" @click.stop>
        <text class="dialog-title">选择地址</text>
        <view v-for="a in addressList" :key="a.id" class="addr-item" @click="selectAddress(a.id)">
          <text class="addr-user">{{ a.contactName }} {{ a.phone }}</text>
          <text class="addr-detail">{{ fullAddress(a) }}</text>
        </view>
        <button class="manage-btn" @click="goProfile">管理地址</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getServiceList, type ServiceItem } from '@/api/service'
import { getAddressList, type UserAddressItem } from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import { createOrder } from '@/api/order'
import { addToCart } from '@/api/cart'
import { parseServiceSpecs, fullAddress, addDaysISO, cycleMinDays, requireLogin, goPage } from '@/utils'

const serviceId = ref(0)
const specFromQuery = ref('')
const service = ref<ServiceItem | null>(null)
const form = reactive({ quantity: 1, remark: '' })
const selectedSpecName = ref('')
const deliveryType = ref<'DOOR_TO_DOOR' | 'IN_STORE'>('DOOR_TO_DOOR')
const urgent = ref(false)
const pickupDate = ref('')
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(null)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(null)
const selectedStoreName = ref('')
const selectedStoreAddress = ref('')
const showAddressPicker = ref(false)
const submitting = ref(false)

const specs = computed(() => (service.value ? parseServiceSpecs(service.value.specs) : []))
const serviceOptions = computed(() => {
  const icons = ['👕', '👖', '👔', '🧥', '👟', '🧺']
  if (specs.value.length) {
    return specs.value.map((s, index) => ({ ...s, icon: icons[index % icons.length] }))
  }
  return service.value ? [{ name: service.value.name, price: Number(service.value.price) || 0, icon: icons[0] }] : []
})
const unitPrice = computed(() => {
  if (!service.value) return 0
  if (!specs.value.length) return Number(service.value.price) || 0
  const hit = specs.value.find((s) => s.name === selectedSpecName.value)
  return hit ? hit.price : specs.value[0].price
})
const minPickupDate = computed(() => {
  const base = cycleMinDays(service.value ? service.value.cycle : undefined)
  const normal = addDaysISO(base)
  if (!urgent.value) return normal
  const urgentMin = addDaysISO(Math.max(1, base - 2))
  const tomorrow = addDaysISO(1)
  return urgentMin < tomorrow ? tomorrow : urgentMin
})
const selectedAddressText = computed(() => {
  const a = addressList.value.find((x) => x.id === selectedAddressId.value)
  return a ? `${a.contactName} ${fullAddress(a)}` : '请选择取送地址'
})
const selectedStore = computed(() => storeList.value.find((s) => s.id === selectedStoreId.value) || null)
const selectedStoreText = computed(() => selectedStoreName.value || selectedStore.value?.name || '请选择门店')
const selectedStoreAddressText = computed(() => selectedStoreAddress.value || selectedStore.value?.address || '')
const pickupDateText = computed(() => {
  if (!pickupDate.value) return '请选择日期'
  const weekdays = ['日', '一', '二', '三', '四', '五', '六']
  const date = new Date(`${pickupDate.value}T00:00:00`)
  return `${pickupDate.value}（周${weekdays[date.getDay()]}）`
})

onLoad((q) => {
  if (!requireLogin('/pages/service/order-create')) return
  serviceId.value = Number((q && q.serviceId) || 0)
  specFromQuery.value = q && q.specName ? decodeURIComponent(String(q.specName)) : ''
  if (q && q.quantity) form.quantity = Math.max(1, Math.min(99, Number(q.quantity) || 1))
  if (q && q.remark) form.remark = decodeURIComponent(String(q.remark))
  if (q && q.storeId) selectedStoreId.value = Number(q.storeId)
  if (q && q.storeName) selectedStoreName.value = decodeURIComponent(String(q.storeName))
  if (q && q.storeAddress) selectedStoreAddress.value = decodeURIComponent(String(q.storeAddress))
})

onShow(() => { loadAddresses(); loadStores() })

function selectSpec(name: string) { selectedSpecName.value = name }
function onDateChange(e: any) { pickupDate.value = e.detail.value }
function changeQty(d: number) { form.quantity = Math.max(1, Math.min(99, form.quantity + d)) }
function selectAddress(id: number) { selectedAddressId.value = id; showAddressPicker.value = false }

async function loadAddresses() {
  try {
    addressList.value = await getAddressList()
    if (!selectedAddressId.value) {
      const d = addressList.value.find((a) => a.isDefault) || addressList.value[0]
      if (d) selectedAddressId.value = d.id
    }
  } catch {}
}

async function loadStores() {
  try {
    storeList.value = await getStoreList()
    if (!selectedStoreId.value && storeList.value[0]) selectedStoreId.value = storeList.value[0].id
  } catch {}
}

function goNearby() {
  let url = `/pages/store/nearby?from=order-create&serviceId=${serviceId.value}`
  if (selectedSpecName.value) url += `&specName=${encodeURIComponent(selectedSpecName.value)}`
  if (form.quantity) url += `&quantity=${form.quantity}`
  if (form.remark) url += `&remark=${encodeURIComponent(form.remark)}`
  uni.navigateTo({ url })
}

function goProfile() {
  showAddressPicker.value = false
  goPage('/pages/profile/profile')
}

async function addCart() {
  if (!service.value) return
  try {
    await addToCart('SERVICE', undefined, service.value.id, form.quantity, selectedSpecName.value || undefined)
    uni.showToast({ title: '已加入购物车', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  }
}

async function submit() {
  if (!service.value) return
  if (!selectedAddressId.value) return uni.showToast({ title: '请选择地址', icon: 'none' })
  if (!selectedStoreId.value) return uni.showToast({ title: '请选择门店', icon: 'none' })
  submitting.value = true
  try {
    await createOrder(
      service.value.id,
      form.quantity,
      form.remark,
      selectedAddressId.value,
      deliveryType.value,
      selectedStoreId.value || undefined,
      selectedSpecName.value || undefined,
      pickupDate.value,
      urgent.value
    )
    uni.showToast({ title: '预约成功', icon: 'success' })
    setTimeout(() => uni.navigateTo({ url: '/pages/order/list' }), 500)
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '预约失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

onMounted(async () => {
  if (!serviceId.value) return
  try {
    const list = await getServiceList()
    service.value = list.find((s) => s.id === serviceId.value) || null
    const sp = specs.value
    if (sp.length) {
      selectedSpecName.value = specFromQuery.value && sp.some((s) => s.name === specFromQuery.value)
        ? specFromQuery.value : sp[0].name
    } else if (service.value) {
      selectedSpecName.value = service.value.name
    }
    pickupDate.value = minPickupDate.value
  } catch {}
  loadAddresses()
  loadStores()
})
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 24rpx 28rpx 190rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f6faff 0%, #f7f9fc 48%, #ffffff 100%);
  color: #111827;
}

.empty-wrap {
  padding: 80rpx 0;
  text-align: center;
  color: #9aa3b2;
  font-size: 30rpx;
}

.card {
  margin-bottom: 20rpx;
  padding: 28rpx;
  border-radius: 22rpx;
  background: #fff;
  box-shadow: 0 12rpx 34rpx rgba(24, 86, 160, 0.08);
}

.section-title {
  display: block;
  margin-bottom: 20rpx;
  font-size: 34rpx;
  font-weight: 800;
}

.service-options {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18rpx;
}

.service-option {
  min-height: 104rpx;
  padding: 18rpx 16rpx;
  display: flex;
  align-items: center;
  gap: 14rpx;
  border: 2rpx solid transparent;
  border-radius: 14rpx;
  background: linear-gradient(135deg, #f8fbff, #f2f5fa);
  box-sizing: border-box;
}

.service-option.active {
  border-color: #2d7cff;
  background: linear-gradient(135deg, #edf5ff, #ffffff);
  box-shadow: inset 0 0 0 1rpx rgba(45, 124, 255, 0.1);
}

.service-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e8f1ff;
  font-size: 34rpx;
  flex-shrink: 0;
}

.service-name,
.service-price,
.delivery-title,
.delivery-desc,
.store-name,
.store-addr {
  display: block;
}

.service-name {
  max-width: 150rpx;
  font-size: 28rpx;
  font-weight: 700;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.service-price {
  margin-top: 4rpx;
  color: #6b7280;
  font-size: 26rpx;
}

.quantity-row {
  margin-top: 34rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.field-title {
  min-width: 140rpx;
  font-size: 30rpx;
  font-weight: 800;
}

.qty-control {
  display: flex;
  align-items: center;
  gap: 34rpx;
}

.qty-btn {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 34rpx;
  font-weight: 700;
}

.qty-btn.minus {
  color: #6b7280;
  background: #f1f5f9;
}

.qty-btn.plus {
  color: #fff;
  background: linear-gradient(135deg, #2f86ff, #1e63f0);
}

.qty-num {
  min-width: 34rpx;
  text-align: center;
  font-size: 32rpx;
}

.delivery-options {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18rpx;
}

.delivery-option {
  min-height: 106rpx;
  padding: 20rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
  border: 2rpx solid transparent;
  border-radius: 14rpx;
  background: #f8fafc;
  box-sizing: border-box;
}

.delivery-option.active {
  border-color: #6aa4ff;
  background: linear-gradient(135deg, #edf5ff, #ffffff);
}

.check-dot,
.checkbox,
.store-radio {
  width: 44rpx;
  height: 44rpx;
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

.delivery-option.active .check-dot,
.checkbox.checked,
.store-radio.active {
  border-color: #2474ff;
  background: #2474ff;
}

.delivery-icon {
  width: 48rpx;
  font-size: 34rpx;
}

.delivery-title {
  font-size: 30rpx;
  font-weight: 700;
}

.delivery-desc {
  margin-top: 4rpx;
  font-size: 24rpx;
  color: #8b95a5;
}

.info-row {
  min-height: 92rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.border-top {
  margin-top: 24rpx;
  border-top: 1rpx solid #e8edf5;
}

.info-value {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12rpx;
  min-width: 0;
  font-size: 30rpx;
}

.info-value.address text:last-child {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.muted-icon {
  color: #8d99aa;
  font-size: 28rpx;
}

.arrow {
  color: #7a8494;
  font-size: 48rpx;
}

.urgent-row {
  margin-left: 140rpx;
  padding: 0 0 24rpx;
  display: flex;
  align-items: center;
  gap: 12rpx;
  color: #1f2937;
  font-size: 26rpx;
}

.checkbox {
  width: 34rpx;
  height: 34rpx;
  border-radius: 8rpx;
  font-size: 22rpx;
}

.recommend,
.nearest {
  padding: 2rpx 10rpx;
  border-radius: 8rpx;
  font-size: 22rpx;
}

.recommend {
  color: #f08a24;
  background: #fff0dc;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.link {
  margin-bottom: 20rpx;
  color: #2474ff;
  font-size: 26rpx;
}

.selected-store-card {
  min-height: 108rpx;
  padding: 18rpx 20rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
  border-radius: 12rpx;
  border: 1rpx solid #e8edf5;
  background: linear-gradient(90deg, #edf5ff, #f8fbff);
  box-sizing: border-box;
}

.store-info {
  flex: 1;
  min-width: 0;
}

.store-title-line {
  display: flex;
  align-items: center;
  gap: 10rpx;
  min-width: 0;
}

.store-name {
  max-width: 390rpx;
  font-size: 30rpx;
  font-weight: 700;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.nearest {
  color: #fff;
  background: #6aa4ff;
  flex-shrink: 0;
}

.store-addr {
  margin-top: 4rpx;
  max-width: 500rpx;
  color: #6b7280;
  font-size: 26rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.store-change {
  flex-shrink: 0;
  color: #2474ff;
  font-size: 26rpx;
}

.remark-card {
  position: relative;
}

.textarea {
  width: 100%;
  min-height: 132rpx;
  padding: 20rpx;
  border-radius: 14rpx;
  background: #f8fafc;
  box-sizing: border-box;
  color: #1f2937;
  font-size: 28rpx;
}

.count {
  position: absolute;
  right: 44rpx;
  bottom: 30rpx;
  color: #9aa3b2;
  font-size: 24rpx;
}

.footer {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 20rpx 38rpx calc(18rpx + env(safe-area-inset-bottom));
  display: grid;
  grid-template-columns: 1fr 1.45fr;
  gap: 24rpx;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 -12rpx 34rpx rgba(27, 72, 126, 0.08);
  box-sizing: border-box;
  z-index: 20;
}

.footer button {
  height: 78rpx;
  border-radius: 999rpx;
  font-size: 30rpx;
  font-weight: 700;
}

.footer button::after {
  border: 0;
}

.cart-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  color: #1f2937;
  background: #f7faff;
}

.cart-icon {
  font-size: 30rpx;
}

.reserve-btn {
  color: #fff;
  background: linear-gradient(135deg, #20c43a, #0fac27);
}

.agreement {
  grid-column: 1 / -1;
  margin-top: -8rpx;
  color: #9aa3b2;
  text-align: center;
  font-size: 22rpx;
}

.mask {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.42);
  display: flex;
  align-items: flex-end;
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
  margin-bottom: 20rpx;
  font-size: 34rpx;
  font-weight: 800;
}

.addr-item {
  padding: 22rpx 0;
  border-bottom: 1rpx solid #e8edf5;
}

.addr-user {
  display: block;
  font-size: 30rpx;
  font-weight: 700;
}

.addr-detail {
  display: block;
  margin-top: 8rpx;
  color: #6b7280;
  font-size: 26rpx;
}

.manage-btn {
  margin-top: 22rpx;
  color: #2474ff;
  background: #f4f8ff;
}
</style>
