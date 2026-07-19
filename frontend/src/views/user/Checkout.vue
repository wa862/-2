<template>
  <div class="checkout-page">
    <header class="checkout-header">
      <span class="back" @click="$router.back()">
        <el-icon><ArrowLeft /></el-icon>
      </span>
      <span class="title">确认订单</span>
    </header>

    <template v-if="!store.token">
      <el-empty description="请先登录">
        <el-button type="primary" @click="$router.push('/home/login')">去登录</el-button>
      </el-empty>
    </template>

    <template v-else>
      <div v-if="loading" class="loading-wrap"><el-icon class="is-loading"><Loading /></el-icon> 加载中...</div>
      <template v-else-if="selectedList.length === 0 && route.query.addAddr !== '1'">
        <el-empty description="未选择商品或已失效" />
      </template>
      <div v-else class="checkout-main">
        <!-- 仅添加地址时的提示 -->
        <div v-if="selectedList.length === 0 && route.query.addAddr === '1'" class="add-addr-only-tip">
          添加地址后可返回购物车勾选商品再结算
        </div>
        <!-- 收货地址 -->
        <section class="block address-block">
          <div class="section-title">📍 收货地址</div>
          <el-radio-group v-model="selectedAddressId" class="address-list">
            <div
              v-for="a in addressList"
              :key="a.id"
              class="address-item"
              :class="{ active: selectedAddressId === a.id }"
              @click="selectedAddressId = a.id"
            >
              <el-radio :label="a.id">
                <span class="addr-text">{{ a.contactName }} {{ maskPhone(a.phone) }}</span>
                <span class="addr-detail">{{ fullAddress(a) }}</span>
              </el-radio>
              <span v-if="a.isDefault" class="default-tag">默认</span>
            </div>
          </el-radio-group>
          <el-button type="primary" plain class="add-addr-btn" @click="openAddressForm()">+ 新增地址</el-button>
        </section>

        <!-- 取送方式（仅当有干洗服务时显示） -->
        <section v-if="serviceItems.length" class="block delivery-block">
          <div class="section-title">取送方式</div>
          <el-radio-group v-model="deliveryType" class="delivery-group">
            <el-radio label="DOOR_TO_DOOR" class="delivery-radio">
              <span class="delivery-label">🚚 上门取送</span>
            </el-radio>
            <el-radio label="IN_STORE" class="delivery-radio">
              <span class="delivery-label">🏪 到店自取</span>
            </el-radio>
          </el-radio-group>
        </section>

        <!-- 取衣日期 / 加急（仅当有干洗服务时显示） -->
        <section v-if="serviceItems.length" class="block delivery-block">
          <div class="section-title">取衣日期</div>
          <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap">
            <el-date-picker
              v-model="pickupDate"
              type="date"
              placeholder="请选择日期"
              value-format="YYYY-MM-DD"
              :disabled-date="disablePickupDate"
              style="width: 220px"
            />
            <el-checkbox v-model="urgent">加急（更快）</el-checkbox>
          </div>
          <div class="tip" style="margin-top: 6px">最快可选：{{ minPickupDate }} <span v-if="urgent">（已加急）</span></div>
        </section>

        <!-- 选择门店（上门取送/到店自取都可选择门店） -->
        <section v-if="serviceItems.length" class="block store-block">
          <div class="section-title-row">
            <span class="section-title">🏪 选择门店</span>
            <router-link to="/home/user/store" class="link-nearby">
              {{ storeList.length > 5 ? '更多店铺（可搜索）' : '查看附近门店' }}
            </router-link>
          </div>
          <el-radio-group v-model="selectedStoreId" class="address-list">
            <div
              v-for="s in visibleStoreList"
              :key="s.id"
              class="address-item"
              :class="{ active: selectedStoreId === s.id }"
              @click="selectedStoreId = s.id"
            >
              <el-radio :label="s.id">
                <span class="addr-text">{{ s.name }}</span>
                <span class="addr-detail">{{ s.address }}</span>
              </el-radio>
            </div>
          </el-radio-group>
        </section>

        <!-- 干洗服务 -->
        <section v-if="serviceItems.length" class="block section-block">
          <div class="section-title">干洗服务</div>
          <div v-for="item in serviceItems" :key="item.id" class="checkout-item">
            <div class="item-name">{{ item.name }}</div>
            <div class="item-meta">￥{{ item.price }}/{{ item.unit || '件' }} × {{ item.quantity }}</div>
            <div class="item-subtotal">小计：￥{{ (Number(item.price) * item.quantity).toFixed(2) }}</div>
          </div>
        </section>

        <!-- 商品 -->
        <section v-if="productItems.length" class="block section-block">
          <div class="section-title">商品</div>
          <div v-for="item in productItems" :key="item.id" class="checkout-item">
            <div class="item-name">{{ item.name }}</div>
            <div class="item-meta">￥{{ item.price }}/{{ item.unit || '件' }} × {{ item.quantity }}</div>
            <div class="item-subtotal">小计：￥{{ (Number(item.price) * item.quantity).toFixed(2) }}</div>
          </div>
        </section>

        <!-- 合计 -->
        <section class="block summary-block">
          <div class="summary-row">
            <span>实付合计：</span>
            <span class="total-pay">￥{{ payTotal.toFixed(2) }}</span>
          </div>
        </section>

        <div v-if="selectedList.length > 0" class="submit-wrap">
          <el-button type="primary" class="submit-btn" :loading="submitting" @click="submit">
            {{ submitBtnText }}
          </el-button>
        </div>
      </div>
    </template>

    <!-- 新增/编辑地址弹窗 -->
    <el-dialog v-model="addressFormVisible" :title="editingAddressId ? '编辑地址' : '新增地址'" width="400px">
      <el-form :model="addressForm" label-width="80px">
        <el-form-item label="收货人" required>
          <el-input v-model="addressForm.contactName" placeholder="请输入姓名" maxlength="32" show-word-limit />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="addressForm.phone" placeholder="请输入手机号" maxlength="20" />
        </el-form-item>
        <el-form-item label="省市区">
          <div class="addr-inline-row">
            <el-select v-model="addressForm.province" placeholder="省" class="addr-inline" clearable @change="onProvinceChange">
              <el-option v-for="p in provinceOptions" :key="p" :label="p" :value="p" />
            </el-select>
            <el-select v-model="addressForm.city" placeholder="市" class="addr-inline" clearable @change="onCityChange">
              <el-option v-for="c in cityOptions" :key="c" :label="c" :value="c" />
            </el-select>
            <el-select v-model="addressForm.district" placeholder="区" class="addr-inline" clearable>
              <el-option v-for="d in districtOptions" :key="d" :label="d" :value="d" />
            </el-select>
          </div>
          <div style="margin-top: 8px; display: flex; gap: 8px">
            <el-button size="small" :loading="locatingAddress" @click="locateAddress">一键定位当前地址</el-button>
            <el-input v-model="addressKeyword" size="small" placeholder="输入小区/街道搜索地址" style="flex: 1" />
            <el-button size="small" :loading="searchingAddress" @click="searchAddress">搜索</el-button>
          </div>
          <el-select
            v-if="addressCandidates.length"
            v-model="selectedCandidateValue"
            placeholder="请选择搜索结果"
            style="width: 100%; margin-top: 8px"
            @change="applyCandidate"
          >
            <el-option
              v-for="item in addressCandidates"
              :key="item.fullAddress"
              :label="item.fullAddress"
              :value="item.fullAddress"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="详细地址" required>
          <el-input v-model="addressForm.detailAddress" type="textarea" placeholder="街道、楼栋、门牌号等" :rows="2" />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="addressForm.isDefault">设为默认地址</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addressFormVisible = false">取消</el-button>
        <el-button type="primary" :loading="addressSaving" @click="saveAddress">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getCartList, removeCartItem } from '@/api/cart'
import { createOrder, createProductOrder } from '@/api/order'
import {
  getAddressList,
  createAddress,
  updateAddress,
  type UserAddressItem,
  type AddressCreateParams,
} from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import type { CartItem } from '@/api/cart'
import { getCurrentLocationAddress, searchAddressByKeyword, type AddressCandidate } from '@/utils/location'
import { regionOptions } from '@/data/region'

const store = useUserStore()
const route = useRoute()
const router = useRouter()
const list = ref<CartItem[]>([])
const loading = ref(true)
const submitting = ref(false)
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(route.query.addressId ? Number(route.query.addressId) : null)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(route.query.storeId ? Number(route.query.storeId) : null)
const deliveryType = ref<'DOOR_TO_DOOR' | 'IN_STORE'>('DOOR_TO_DOOR')
const urgent = ref(false)
const pickupDate = ref<string>('')
const addressFormVisible = ref(false)
const addressSaving = ref(false)
const locatingAddress = ref(false)
const searchingAddress = ref(false)
const addressKeyword = ref('')
const addressCandidates = ref<AddressCandidate[]>([])
const selectedCandidateValue = ref('')
const editingAddressId = ref<number | null>(null)
const addressForm = ref<AddressCreateParams & { id?: number }>({
  contactName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false,
})
 

const idsParam = computed(() => (route.query.ids as string) || '')
const provinceOptions = computed(() => {
  const dynamic = Array.from(new Set(addressCandidates.value.map((x) => x.province).filter(Boolean)))
  if (dynamic.length) return dynamic
  return regionOptions.map((p: any) => p.label)
})
const cityOptions = computed(() => {
  const dynamic = Array.from(
    new Set(
      addressCandidates.value
        .filter((x) => x.province === addressForm.value.province)
        .map((x) => x.city)
        .filter(Boolean)
    )
  )
  if (dynamic.length) return dynamic
  const p = (regionOptions as any[]).find((x) => x.label === addressForm.value.province)
  return (p?.children || []).map((c: any) => c.label)
})
const districtOptions = computed(() => {
  const dynamic = Array.from(
    new Set(
      addressCandidates.value
        .filter((x) => x.province === addressForm.value.province && x.city === addressForm.value.city)
        .map((x) => x.district)
        .filter(Boolean)
    )
  )
  if (dynamic.length) return dynamic
  const p = (regionOptions as any[]).find((x) => x.label === addressForm.value.province)
  const c = (p?.children || []).find((x: any) => x.label === addressForm.value.city)
  return (c?.children || []).map((d: any) => d.label)
})
const idSet = computed(() => new Set(idsParam.value.split(',').map((s) => Number(s.trim())).filter(Boolean)))

const selectedList = computed(() => list.value.filter((i) => idSet.value.has(i.id)))
const serviceItems = computed(() => selectedList.value.filter((i) => i.itemType === 'SERVICE'))
const productItems = computed(() => selectedList.value.filter((i) => i.itemType === 'PRODUCT'))
const visibleStoreList = computed(() => {
  if (storeList.value.length <= 5) return storeList.value
  const selected = storeList.value.find((s) => s.id === selectedStoreId.value)
  if (!selected) return storeList.value.slice(0, 5)
  const top = storeList.value.filter((s) => s.id !== selected.id).slice(0, 4)
  return [selected, ...top]
})

const payTotal = computed(() =>
  selectedList.value.reduce((sum, i) => sum + Number(i.price) * i.quantity, 0)
)

function cycleMinDaysForCheckout(): number {
  const cycles = serviceItems.value.map((i) => String((i as any).cycle || '')).filter(Boolean)
  let maxMin = 3
  for (const c of cycles) {
    const m = c.match(/(\d+)\s*-\s*(\d+)/)
    if (m) maxMin = Math.max(maxMin, Number(m[1]) || 1)
    else {
      const m2 = c.match(/(\d+)/)
      if (m2) maxMin = Math.max(maxMin, Number(m2[1]) || 1)
    }
  }
  return Math.max(1, maxMin)
}

function addDaysISO(days: number): string {
  const d = new Date()
  d.setHours(0, 0, 0, 0)
  d.setDate(d.getDate() + days)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${dd}`
}

const minPickupDate = computed(() => {
  const base = cycleMinDaysForCheckout()
  const normal = addDaysISO(base)
  if (!urgent.value) return normal
  const urgentMin = addDaysISO(Math.max(1, base - 2))
  const tomorrow = addDaysISO(1)
  return urgentMin < tomorrow ? tomorrow : urgentMin
})

function disablePickupDate(date: Date) {
  const min = new Date(minPickupDate.value + 'T00:00:00')
  return date.getTime() < min.getTime()
}

watch([urgent, minPickupDate], () => {
  if (!pickupDate.value || pickupDate.value < minPickupDate.value) {
    pickupDate.value = minPickupDate.value
  }
})
const submitBtnText = computed(() => {
  const s = serviceItems.value.length
  const p = productItems.value.length
  if (s && p) return `提交订单 (${s} 个服务 + ${p} 件商品)`
  if (s) return `提交订单 (${s} 个服务)`
  if (p) return `提交订单 (${p} 件商品)`
  return '提交订单'
})

function maskPhone(phone: string) {
  if (!phone || phone.length < 7) return phone
  return phone.slice(0, 3) + '****' + phone.slice(-4)
}
function fullAddress(a: UserAddressItem) {
  const parts = [a.province, a.city, a.district, a.detailAddress].filter(Boolean)
  return parts.join(' ') || a.detailAddress
}

function openAddressForm(addr?: UserAddressItem) {
  editingAddressId.value = addr?.id ?? null
  addressForm.value = addr
    ? {
        contactName: addr.contactName,
        phone: addr.phone,
        province: addr.province || '',
        city: addr.city || '',
        district: addr.district || '',
        detailAddress: addr.detailAddress,
        isDefault: addr.isDefault,
      }
    : {
        contactName: '',
        phone: '',
        province: '',
        city: '',
        district: '',
        detailAddress: '',
        isDefault: false,
      }
  addressFormVisible.value = true
}

async function locateAddress() {
  locatingAddress.value = true
  try {
    const geo = await getCurrentLocationAddress()
    if (geo.province) addressForm.value.province = geo.province
    if (geo.city) addressForm.value.city = geo.city
    if (geo.district) addressForm.value.district = geo.district
    if (geo.fullAddress) addressForm.value.detailAddress = geo.fullAddress
    addressKeyword.value = geo.fullAddress || ''
    addressCandidates.value = []
    selectedCandidateValue.value = ''
    ElMessage.success('已自动定位并填充地址')
  } catch (e: any) {
    ElMessage.error(e?.message || '定位失败，请手动填写地址')
  } finally {
    locatingAddress.value = false
  }
}

async function searchAddress() {
  const kw = addressKeyword.value.trim()
  if (!kw) {
    ElMessage.warning('请输入搜索关键词')
    return
  }
  searchingAddress.value = true
  try {
    addressCandidates.value = await searchAddressByKeyword(kw, addressForm.value.city || '')
    if (!addressCandidates.value.length) ElMessage.info('未搜索到地址，请换个关键词')
  } catch (e: any) {
    ElMessage.error(e?.message || '地址搜索失败')
  } finally {
    searchingAddress.value = false
  }
}

function applyCandidate(val: string) {
  const hit = addressCandidates.value.find((x) => x.fullAddress === val)
  if (!hit) return
  if (hit.province) addressForm.value.province = hit.province
  if (hit.city) addressForm.value.city = hit.city
  if (hit.district) addressForm.value.district = hit.district
  addressForm.value.detailAddress = hit.fullAddress
}

function onProvinceChange() {
  addressForm.value.city = ''
  addressForm.value.district = ''
}

function onCityChange() {
  addressForm.value.district = ''
}
async function saveAddress() {
  const f = addressForm.value
  if (!f.contactName?.trim() || !f.phone?.trim() || !f.detailAddress?.trim()) {
    ElMessage.warning('请填写收货人、手机号和详细地址')
    return
  }
  addressSaving.value = true
  try {
    const payload: AddressCreateParams = {
      contactName: f.contactName.trim(),
      phone: f.phone.trim(),
      province: f.province?.trim() || undefined,
      city: f.city?.trim() || undefined,
      district: f.district?.trim() || undefined,
      detailAddress: f.detailAddress.trim(),
      isDefault: f.isDefault,
    }
    if (editingAddressId.value) {
      await updateAddress(editingAddressId.value, payload)
      ElMessage.success('地址已更新')
    } else {
      await createAddress(payload)
      ElMessage.success('地址已添加')
    }
    addressFormVisible.value = false
    loadAddresses()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '保存失败')
  } finally {
    addressSaving.value = false
  }
}

function loadAddresses() {
  return getAddressList().then((data) => {
    addressList.value = data ?? []
    if (addressList.value.length && selectedAddressId.value === null) {
      const defaultAddr = addressList.value.find((a) => a.isDefault) || addressList.value[0]
      selectedAddressId.value = defaultAddr.id
    }
  }).catch(() => { addressList.value = [] })
}
function loadStores() {
  getStoreList().then((data) => {
    storeList.value = data ?? []
    if (storeList.value.length && selectedStoreId.value === null) selectedStoreId.value = storeList.value[0].id
  }).catch(() => { storeList.value = [] })
}

async function submit() {
  const hasServices = serviceItems.value.length > 0
  const hasProducts = productItems.value.length > 0
  if (!hasServices && !hasProducts) return
  if (hasServices) {
    if (deliveryType.value === 'DOOR_TO_DOOR' && !selectedAddressId.value) {
      ElMessage.warning('请选择收货地址或新增地址')
      return
    }
    if (!selectedStoreId.value) {
      ElMessage.warning('请选择门店')
      return
    }
  }
  if (hasProducts) {
    if (!selectedAddressId.value) {
      ElMessage.warning('请选择收货地址或新增地址')
      return
    }
  }
  submitting.value = true
  const cartIdsToRemove = selectedList.value.map((i) => i.id)
  try {
    const addressId = hasServices && deliveryType.value === 'DOOR_TO_DOOR' ? selectedAddressId.value ?? undefined : undefined
    const storeId = hasServices ? selectedStoreId.value ?? undefined : undefined
    for (const item of serviceItems.value) {
      if (item.serviceId) {
        await createOrder(
          item.serviceId,
          item.quantity,
          '',
          addressId,
          deliveryType.value,
          storeId,
          (item as any).serviceSpecName || undefined,
          pickupDate.value || undefined,
          urgent.value
        )
      }
    }
    for (const item of productItems.value) {
      if (item.productId) {
        // 商品订单：默认上门配送，需要收货地址
        if (!selectedAddressId.value) {
          ElMessage.warning('请选择收货地址或新增地址')
          return
        }
        await createProductOrder(item.productId, item.quantity, '', selectedAddressId.value ?? undefined, 'DOOR_TO_DOOR', undefined)
      }
    }
    if (hasProducts) {
      ElMessage.success(hasServices ? '订单提交成功' : '商品订单提交成功，请到「我的订单」查看')
    } else {
      ElMessage.success('订单提交成功')
    }
    for (const id of cartIdsToRemove) {
      try {
        await removeCartItem(id)
      } catch (_) {}
    }
    router.push('/home/user/order')
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

function load() {
  if (!store.token) return
  loading.value = true
  getCartList()
    .then((data) => {
      list.value = data ?? []
    })
    .catch(() => { list.value = [] })
    .finally(() => { loading.value = false })
}

onMounted(() => {
  load()
  loadAddresses().then(() => {
    if (route.query.addAddr === '1') {
      openAddressForm()
    }
  })
  loadStores()
  pickupDate.value = minPickupDate.value
})
</script>

<style scoped>
.checkout-page {
  min-height: 100vh;
  background: #F9F5F0;
  padding: 16px 16px 100px;
}
.checkout-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.back {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #2D2A27;
  cursor: pointer;
  border-radius: 50%;
  background: #fff;
}
.title { font-size: 22px; font-weight: 600; color: #2D2A27; }
.loading-wrap { text-align: center; padding: 48px; color: #8F7F70; }
.add-addr-only-tip {
  text-align: center; padding: 12px 16px; margin-bottom: 12px;
  background: #fff8e6; color: #8F7F70; font-size: 18px; border-radius: 12px;
}
.block {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(74, 63, 56, 0.06);
}
.section-title { font-size: 18px; color: #8F7F70; margin-bottom: 12px; }
.checkout-item {
  padding: 12px 0;
  border-bottom: 1px solid #F0E9E2;
}
.checkout-item:last-child { border-bottom: none; }
.item-name { font-weight: 600; color: #2D2A27; margin-bottom: 4px; }
.item-meta { font-size: 18px; color: #8F7F70; margin-bottom: 4px; }
.item-subtotal { font-size: 18px; font-weight: 500; color: #C17C5A; }
.summary-row { display: flex; justify-content: space-between; font-size: 20px; font-weight: 600; }
.total-pay { font-size: 24px; color: #C17C5A; }
.submit-wrap { margin-top: 24px; text-align: center; }
.submit-btn { width: 100%; max-width: 320px; border-radius: 24px; font-weight: 500; }

.address-block .section-title { margin-bottom: 12px; }
.address-list { display: flex; flex-direction: column; gap: 8px; }
.address-item {
  padding: 12px;
  border: 1px solid #F0E9E2;
  border-radius: 12px;
  cursor: pointer;
  position: relative;
}
.address-item.active { border-color: #4A3F38; background: #F9F5F0; }
.address-item :deep(.el-radio) { width: 100%; height: auto; margin-right: 0; }
.address-item :deep(.el-radio__label) { display: flex; flex-direction: column; gap: 4px; }
.addr-text { font-weight: 500; color: #2D2A27; }
.addr-detail { font-size: 18px; color: #8F7F70; }
.default-tag { position: absolute; top: 8px; right: 8px; font-size: 18px; color: #C17C5A; }
.add-addr-btn { width: 100%; margin-top: 8px; border-radius: 12px; }

.delivery-block .section-title { margin-bottom: 12px; }
.delivery-group { display: flex; flex-direction: column; gap: 12px; width: 100%; }
.delivery-radio { display: flex; align-items: center; gap: 12px; width: 100%; padding: 12px; border: 1px solid #F0E9E2; border-radius: 12px; }
.delivery-radio :deep(.el-radio__label) { display: flex; flex-direction: column; gap: 2px; }
.delivery-label { font-weight: 500; color: #2D2A27; }
.store-block .section-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.store-block .section-title { margin-bottom: 0; }
.store-block .link-nearby {
  font-size: 18px;
  color: #C17C5A;
  text-decoration: none;
}
.store-block .link-nearby:hover { text-decoration: underline; }
.store-block .address-list {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 8px;
}
.store-block .address-item {
  width: 100%;
  box-sizing: border-box;
}
.store-block :deep(.el-radio) { width: 100%; height: auto; margin-right: 0; }
.store-block :deep(.el-radio__label) { width: 100%; display: flex; flex-direction: column; gap: 4px; }
.addr-inline-row {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  width: 100%;
}
.addr-inline { width: 100%; }
</style>
