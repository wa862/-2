<template>
  <div class="order-create-page">
    <template v-if="service">
      <!-- 顶部：返回 + 标题 + 分享/收藏 -->
      <header class="page-header">
        <span class="back" @click="$router.back()">
          <el-icon><ArrowLeft /></el-icon>
        </span>
        <span class="title">服务详情</span>
        <div class="header-actions">
          <span class="icon-btn" @click="onShare" title="分享">
            <el-icon><Share /></el-icon>
          </span>
          <span class="icon-btn" :class="{ liked: liked }" @click="liked = !liked" title="收藏">
            <el-icon><Star /></el-icon>
          </span>
        </div>
      </header>

      <!-- 主视觉区：完整展示图片 -->
      <section class="visual-section">
        <div class="visual-wrap">
          <div class="visual-placeholder">
            <img v-if="service.image" :src="service.image" :alt="service.name" class="visual-img" />
            <span v-else class="visual-icon">🧥</span>
          </div>
        </div>
        <div class="service-tags">
          <span>专业洗护</span>
          <span>上门取送</span>
          <span>72h快洗</span>
        </div>
      </section>

      <!-- 核心信息区 -->
      <section class="info-card">
        <h1 class="service-name">{{ service.name }}</h1>
        <div class="rating-row">
          <el-rate v-model="ratingDisplay" disabled allow-half show-score text-color="#C17C5A" />
          <span class="rating-text">4.9 <span class="review-count">(1287评价)</span></span>
        </div>
        <div class="price-row">
          <span class="price-original">原价 ¥{{ originalPrice }}</span>
          <span class="price-member">会员价 ¥{{ unitPrice }}/件</span>
        </div>
        <div v-if="serviceSpecs.length" class="form-section spec-section">
          <div class="label">规格（不同款不同价）</div>
          <el-radio-group v-model="selectedSpecName" class="spec-radio-group">
            <el-radio v-for="opt in serviceSpecs" :key="opt.name" :label="opt.name" class="spec-radio">
              {{ opt.name }} ¥{{ opt.price }}/件
            </el-radio>
          </el-radio-group>
        </div>
        <div v-if="service.cycle" class="cycle-hint">预计洗护周期：{{ service.cycle }}</div>
      </section>

      <!-- 服务特色 -->
      <section class="features-section">
        <div class="feature-item">
          <span class="feature-icon">🧼</span>
          <span>深度去渍</span>
        </div>
        <div class="feature-item">
          <span class="feature-icon">🦠</span>
          <span>除菌除螨</span>
        </div>
        <div class="feature-item">
          <span class="feature-icon">🌿</span>
          <span>环保洗剂</span>
        </div>
        <div class="feature-item">
          <span class="feature-icon">☁️</span>
          <span>蓬松还原</span>
        </div>
      </section>

      <!-- 收货地址 -->
      <section class="form-section address-section">
        <div class="label">📍 收货地址</div>
        <el-radio-group v-model="selectedAddressId" class="address-list">
          <div
            v-for="a in addressList"
            :key="a.id"
            class="address-item"
            :class="{ active: selectedAddressId === a.id }"
            @click="selectedAddressId = a.id"
            @dblclick="openAddressForm(a)"
          >
            <el-radio :label="a.id" />
            <div class="address-content">
              <div class="address-header">
                <span class="addr-text">{{ a.contactName }} {{ maskPhone(a.phone) }}</span>
                <span v-if="a.isDefault" class="default-tag">默认</span>
              </div>
              <span class="addr-detail">{{ fullAddress(a) }}</span>
            </div>
            <div class="addr-actions" @click.stop>
              <el-button link type="primary" size="small" @click="openAddressForm(a)">编辑</el-button>
              <el-button link type="danger" size="small" @click="onDeleteAddress(a.id)">删除</el-button>
            </div>
          </div>
        </el-radio-group>
        <el-button type="primary" plain size="small" class="add-addr-btn" @click="openAddressForm()">+ 新增地址</el-button>
      </section>

      <!-- 取送方式 -->
      <section class="form-section">
        <div class="label">取送方式</div>
        <el-radio-group v-model="deliveryType" class="delivery-group">
          <el-radio label="DOOR_TO_DOOR">🚚 上门取送</el-radio>
          <el-radio label="IN_STORE">🏪 到店自取</el-radio>
        </el-radio-group>
      </section>

      <!-- 取衣日期 / 加急 -->
      <section class="form-section">
        <div class="label">取衣日期</div>
        <div class="pickup-row">
          <el-date-picker
            v-model="pickupDate"
            type="date"
            placeholder="请选择日期"
            value-format="YYYY-MM-DD"
            :disabled-date="disablePickupDate"
            style="width: 220px"
          />
          <el-checkbox v-model="urgent" style="margin-left: 12px">加急（更快）</el-checkbox>
        </div>
        <div class="hint">
          最快可选：{{ minPickupDate }} <span v-if="urgent">（已加急）</span>
        </div>
      </section>

      <!-- 选择门店（上门取送/到店自取都可选择门店） -->
      <section class="form-section">
        <div class="label-row">
          <span class="label">🏪 选择门店</span>
          <a href="javascript:void(0)" class="link-nearby" @click.prevent="goNearbyStore">查看附近门店</a>
        </div>
        <div class="selected-store-card" @click="goNearbyStore">
          <div class="selected-store-main">
            <span class="addr-text">{{ selectedStoreText }}</span>
            <span v-if="selectedStoreAddressText" class="addr-detail">{{ selectedStoreAddressText }}</span>
          </div>
          <span class="store-change">更换</span>
        </div>
      </section>

      <!-- 数量 -->
      <section class="form-section">
        <div class="label">数量</div>
        <div class="quantity-wrap">
          <button type="button" class="qty-btn" :disabled="form.quantity <= 1" @click="form.quantity = Math.max(1, form.quantity - 1)">−</button>
          <span class="qty-num">{{ form.quantity }}</span>
          <button type="button" class="qty-btn" :disabled="form.quantity >= 10" @click="form.quantity = Math.min(10, form.quantity + 1)">+</button>
        </div>
        <div class="hint">最多可预约10件</div>
      </section>

      <!-- 备注 -->
      <section class="form-section">
        <div class="label">备注 <span class="optional">（选填）</span></div>
        <el-input
          v-model="form.remark"
          type="textarea"
          placeholder="例如：取件时间、特殊污渍位置..."
          :maxlength="50"
          show-word-limit
          rows="3"
          class="remark-input"
        />
      </section>

      <!-- 合计 -->
      <section class="total-section">
        <span class="total-label">合计：</span>
        <span class="total-amount">¥{{ totalPrice }}</span>
        <span class="total-note">（已包含服务费）</span>
      </section>

      <!-- 底部悬浮栏 -->
      <footer class="bottom-bar">
        <div class="bar-left">
          <el-icon class="cart-icon"><ShoppingCart /></el-icon>
          <span>已选{{ form.quantity }}件</span>
        </div>
        <div class="bar-right">
          <el-button class="btn-secondary" @click="addToCartClick">加入购物车</el-button>
          <el-button class="btn-primary" :loading="loading" @click="submit">立即预约</el-button>
        </div>
      </footer>
    </template>
    <el-empty v-else description="未选择服务" />

    <!-- 新增/编辑地址弹窗 -->
    <el-dialog v-model="addressFormVisible" :title="editingAddressId ? '编辑地址' : '新增地址'" width="520px">
      <el-form :model="addressForm" label-width="80px">
        <el-form-item label="收货人" required>
          <el-input v-model="addressForm.contactName" placeholder="请输入姓名" maxlength="32" show-word-limit />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="addressForm.phone" placeholder="请输入手机号" maxlength="11" inputmode="numeric" />
        </el-form-item>
        <el-form-item label="省市区" required>
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
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, Share, Star, ShoppingCart } from '@element-plus/icons-vue'
import {
  getAddressList,
  createAddress,
  updateAddress,
  removeAddress,
  type UserAddressItem,
  type AddressCreateParams,
} from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import { getServiceList, type ServiceItem } from '@/api/service'
import { createOrder } from '@/api/order'
import { addToCart } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import { getCurrentLocationAddress, searchAddressByKeyword, type AddressCandidate } from '@/utils/location'
import { regionOptions } from '@/data/region'

const route = useRoute()
const router = useRouter()
const store = useUserStore()
const service = ref<any>(null)
const loading = ref(false)
const liked = ref(false)
const form = reactive({ quantity: 1, remark: '' })
const ratingDisplay = ref(4.9)
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(null)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(null)
const deliveryType = ref<'DOOR_TO_DOOR' | 'IN_STORE'>('DOOR_TO_DOOR')
const selectedStore = computed(() => storeList.value.find((s) => s.id === selectedStoreId.value) || null)
const selectedStoreText = computed(() => {
  const qName = typeof route.query.storeName === 'string' ? decodeURIComponent(route.query.storeName).trim() : ''
  return qName || selectedStore.value?.name || '请选择门店'
})
const selectedStoreAddressText = computed(() => {
  const qAddress = typeof route.query.storeAddress === 'string' ? decodeURIComponent(route.query.storeAddress).trim() : ''
  return qAddress || selectedStore.value?.address || ''
})
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

function syncOrderPrefillFromRoute() {
  const qQuantity = route.query.quantity
  const qRemark = route.query.remark
  if (typeof qQuantity === 'string') {
    form.quantity = Math.max(1, Math.min(10, Number(qQuantity) || 1))
  }
  if (typeof qRemark === 'string') {
    form.remark = decodeURIComponent(qRemark).slice(0, 50)
  }
}

type SpecOption = { name: string; price: number }
function parseServiceSpecs(raw?: string): SpecOption[] {
  if (!raw?.trim()) return []
  return raw
    .split(/[;,，]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => {
      const [name, priceStr] = part.split('|').map((s) => s.trim())
      const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
      if (!name || Number.isNaN(price) || price <= 0) return null
      return { name, price }
    })
    .filter((x): x is SpecOption => !!x)
}

const selectedSpecName = ref('')

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

const serviceSpecs = computed(() =>
  service.value ? parseServiceSpecs((service.value as ServiceItem).specs) : []
)

const unitPrice = computed(() => {
  if (!service.value) return 0
  const specs = serviceSpecs.value
  if (!specs.length) return Number(service.value.price) || 0
  const hit = specs.find((s) => s.name === selectedSpecName.value)
  return hit ? hit.price : specs[0].price
})

function syncSpecFromRoute() {
  const specs = serviceSpecs.value
  const q = route.query.specName
  const fromQ = typeof q === 'string' ? decodeURIComponent(q).trim() : ''
  if (specs.length) {
    if (fromQ && specs.some((s) => s.name === fromQ)) {
      selectedSpecName.value = fromQ
    } else if (!selectedSpecName.value || !specs.some((s) => s.name === selectedSpecName.value)) {
      selectedSpecName.value = specs[0].name
    }
  } else {
    selectedSpecName.value = ''
  }
}

const originalPrice = computed(() => {
  if (!service.value) return 0
  return Math.round(unitPrice.value * 1.76) || 79
})

const totalPrice = computed(() => {
  if (!service.value) return '0'
  return (unitPrice.value * form.quantity).toFixed(0)
})

const urgent = ref(false)
const pickupDate = ref<string>('')

function cycleMinDays(cycle?: string): number {
  const s = (cycle || '').trim()
  if (!s) return 3
  const m = s.match(/(\d+)\s*-\s*(\d+)/)
  if (m) return Math.max(1, Number(m[1]) || 1)
  const m2 = s.match(/(\d+)/)
  if (m2) return Math.max(1, Number(m2[1]) || 1)
  return 3
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
  const base = cycleMinDays((service.value as ServiceItem | null)?.cycle)
  const normal = addDaysISO(base)
  if (!urgent.value) return normal
  // 加急：比正常快 2 天，但至少明天起
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

onMounted(async () => {
  syncOrderPrefillFromRoute()
  const id = Number(route.query.serviceId)
  if (!id) return
  try {
    const list = await getServiceList()
    service.value = list.find((s) => s.id === id)
    syncSpecFromRoute()
    // 默认取衣日期为最快日期
    pickupDate.value = minPickupDate.value
  } catch (_) {}
  loadAddresses()
  loadStores()
})

watch(
  () => [route.query.specName, service.value?.id, (service.value as ServiceItem)?.specs] as const,
  () => syncSpecFromRoute()
)

watch(
  () => [route.query.quantity, route.query.remark] as const,
  () => syncOrderPrefillFromRoute()
)

function onShare() {
  ElMessage.success('分享功能开发中')
}

function addToCartClick() {
  if (!service.value) return
  if (!store.token) {
    ElMessage.warning('请先登录')
    router.push('/home/login')
    return
  }
  addToCart('SERVICE', undefined, service.value.id, form.quantity, selectedSpecName.value || undefined)
    .then(() => {
      ElMessage.success('已加入购物车')
    })
    .catch((e: any) => {
      ElMessage.error(e?.response?.data?.message || '加入失败')
    })
}

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
  const phone = f.phone.trim()
  if (!/^1\d{10}$/.test(phone)) {
    ElMessage.warning('手机号必须为11位数字')
    return
  }
  if (!f.province?.trim() || !f.city?.trim() || !f.district?.trim()) {
    ElMessage.warning('请填写省/市/区')
    return
  }
  addressSaving.value = true
  try {
    const payload: AddressCreateParams = {
      contactName: f.contactName.trim(),
      phone,
      province: f.province.trim(),
      city: f.city.trim(),
      district: f.district.trim(),
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

async function onDeleteAddress(id: number) {
  try {
    await ElMessageBox.confirm('确定删除该地址吗？', '提示', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await removeAddress(id)
    ElMessage.success('地址已删除')
    if (selectedAddressId.value === id) selectedAddressId.value = null
    loadAddresses()
  } catch (_) {}
}
function loadAddresses() {
  getAddressList().then((data) => {
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
    const fromQuery = route.query.storeId != null ? Number(route.query.storeId) : null
    if (fromQuery != null && storeList.value.some((s) => s.id === fromQuery)) {
      selectedStoreId.value = fromQuery
    } else if (storeList.value.length && selectedStoreId.value === null) {
      selectedStoreId.value = storeList.value[0].id
    }
  }).catch(() => { storeList.value = [] })
}

function goNearbyStore() {
  const serviceId = route.query.serviceId || (service.value?.id != null ? String(service.value.id) : '')
  const q: Record<string, string> = { from: 'order-create' }
  if (serviceId) q.serviceId = String(serviceId)
  if (selectedStoreId.value != null) q.storeId = String(selectedStoreId.value)
  if (selectedSpecName.value) q.specName = selectedSpecName.value
  router.push({ path: '/home/user/store', query: q })
}

async function submit() {
  if (!service.value) return
  if (deliveryType.value === 'DOOR_TO_DOOR' && !selectedAddressId.value) {
    ElMessage.warning('请选择收货地址或新增地址')
    return
  }
  if (!selectedStoreId.value) {
    ElMessage.warning('请选择门店')
    return
  }
  loading.value = true
  try {
    const addressId = deliveryType.value === 'DOOR_TO_DOOR' ? selectedAddressId.value ?? undefined : undefined
    const storeId = selectedStoreId.value ?? undefined
    await createOrder(
      service.value.id,
      form.quantity,
      form.remark,
      addressId,
      deliveryType.value,
      storeId,
      selectedSpecName.value || undefined,
      pickupDate.value || undefined,
      urgent.value
    )
    ElMessage.success('订单创建成功')
    router.push('/home/user/order')
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '创建失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.order-create-page {
  min-height: 100vh;
  background: #F9F5F0;
  padding-bottom: 80px;
  font-family: inherit;
  font-size: 21px;
}

/* 顶部 */
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  padding: 0 16px;
  background: #FFFFFF;
  position: sticky;
  top: 0;
  z-index: 10;
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
  transition: background 0.2s;
}
.back:hover { background: #F0E9E2; }
.title {
  font-size: 24px;
  font-weight: 600;
  color: #2D2A27;
}
.header-actions { display: flex; gap: 8px; }
.icon-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #8F7F70;
  cursor: pointer;
  border-radius: 50%;
  transition: all 0.2s;
}
.icon-btn:hover { color: #4A3F38; background: #F0E9E2; }
.icon-btn.liked { color: #C17C5A; }

/* 主视觉 */
.visual-section {
  padding: 20px 20px 16px;
  background: #FFFFFF;
  margin: 0 16px 12px;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(74, 63, 56, 0.06);
}
.visual-wrap { text-align: center; }
.visual-placeholder {
  width: 100%;
  min-height: 160px;
  border-radius: 16px;
  background: #F0E9E2;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.visual-placeholder .visual-img {
  width: 100%;
  height: auto;
  max-height: 320px;
  object-fit: contain;
  object-position: center;
  display: block;
}
.visual-icon { font-size: 68px; }
.service-tags {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 14px;
  flex-wrap: wrap;
}
.service-tags span {
  padding: 6px 14px;
  font-size: 19px;
  color: #8F7F70;
  background: #F0E9E2;
  border-radius: 999px;
}

/* 核心信息卡片 */
.info-card {
  background: #FFFFFF;
  margin: 0 16px 12px;
  padding: 20px;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(74, 63, 56, 0.06);
}
.service-name {
  font-size: 28px;
  font-weight: 600;
  color: #2D2A27;
  margin: 0 0 10px 0;
}
.rating-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}
.rating-row :deep(.el-rate) { height: auto; }
.rating-row :deep(.el-rate__icon) { font-size: 20px; }
.rating-row :deep(.el-rate__icon) { font-size: 23px; }
.rating-text { font-size: 21px; color: #2D2A27; }
.review-count { color: #8F7F70; font-size: 19px; }
.price-row { display: flex; align-items: baseline; gap: 12px; }
.price-original { font-size: 21px; color: #8F7F70; text-decoration: line-through; }
.price-member { font-size: 30px; font-weight: 700; color: #C17C5A; }

/* 服务特色 */
.features-section {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  padding: 0 16px 16px;
}
.feature-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 8px;
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(74, 63, 56, 0.06);
  font-size: 19px;
  color: #2D2A27;
}
.feature-icon { font-size: 28px; }

/* 表单区 */
.form-section {
  background: #FFFFFF;
  margin: 0 16px 12px;
  padding: 18px 20px;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(74, 63, 56, 0.06);
}
.label {
  font-size: 23px;
  font-weight: 500;
  color: #2D2A27;
  margin-bottom: 12px;
}
.label-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}
.label-row .label { margin-bottom: 0; }
.link-nearby {
  font-size: 20px;
  color: #C17C5A;
  text-decoration: none;
}
.link-nearby:hover { text-decoration: underline; }
.selected-store-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 14px;
  border: 1px solid #F0E9E2;
  border-radius: 12px;
  background: #F9F5F0;
  cursor: pointer;
}
.selected-store-card:hover { border-color: #C17C5A; }
.selected-store-main {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}
.selected-store-card .addr-text {
  font-size: 21px;
  font-weight: 500;
  color: #2D2A27;
}
.selected-store-card .addr-detail {
  font-size: 19px;
  color: #8F7F70;
}
.store-change {
  flex: 0 0 auto;
  font-size: 19px;
  color: #C17C5A;
}
.optional { font-weight: 400; color: #8F7F70; }
.quantity-wrap {
  display: inline-flex;
  align-items: center;
  border: 1px solid #DCD2C9;
  border-radius: 12px;
  overflow: hidden;
  background: #FFF;
}
.qty-btn {
  width: 44px;
  height: 44px;
  border: none;
  background: #F9F5F0;
  color: #4A3F38;
  font-size: 24px;
  cursor: pointer;
  transition: transform 0.15s, background 0.2s;
}
.qty-btn:hover:not(:disabled) { background: #F0E9E2; }
.qty-btn:active:not(:disabled) { transform: scale(0.95); }
.qty-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.qty-num {
  min-width: 48px;
  text-align: center;
  font-size: 24px;
  font-weight: 600;
  color: #2D2A27;
}
.hint { font-size: 19px; color: #8F7F70; margin-top: 8px; }
.address-section .address-list { display: flex; flex-direction: column; gap: 14px; margin-bottom: 14px; }
.address-section .address-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 18px;
  border: 1px solid #F0E9E2;
  border-radius: 16px;
  cursor: pointer;
  position: relative;
  transition: all 0.2s;
  background: #FFFFFF;
}
.address-section .address-item:hover { border-color: #DCD2C9; }
.address-section .address-item.active { border-color: #4A3F38; background: #F9F5F0; }
.address-section .address-item :deep(.el-radio) { margin-top: 2px; flex-shrink: 0; }
.address-section .address-content {
  flex: 1;
  min-width: 0;
  padding-right: 90px;
}
.address-section .address-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.address-section .addr-text {
  font-size: 15px;
  font-weight: 600;
  color: #2D2A27;
}
.address-section .addr-detail {
  font-size: 14px;
  color: #8F7F70;
  line-height: 1.5;
}
.address-section .default-tag {
  font-size: 12px;
  color: #C17C5A;
  padding: 2px 8px;
  background: #FFF5EF;
  border-radius: 4px;
  font-weight: 500;
}
.address-section .addr-actions {
  position: absolute;
  right: 18px;
  top: 18px;
  display: inline-flex;
  gap: 12px;
}
.address-section .add-addr-btn { width: 100%; border-radius: 16px; font-size: 14px; padding: 12px; }
.delivery-group { display: flex; gap: 16px; }
.remark-input { border-radius: 12px; }
.addr-inline-row {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  width: 100%;
}
.addr-inline { width: 100%; }
.remark-input :deep(.el-textarea__inner) {
  border-radius: 12px;
  border-color: #DCD2C9;
  font-size: 21px;
}
.remark-input :deep(.el-textarea__inner:focus) { border-color: #4A3F38; box-shadow: 0 0 0 1px #4A3F38; }

/* 合计 */
.total-section {
  background: #FFFFFF;
  margin: 0 16px 12px;
  padding: 18px 20px;
  border-radius: 20px;
  box-shadow: 0 2px 12px rgba(74, 63, 56, 0.06);
  font-size: 24px;
}
.total-label { color: #2D2A27; }
.total-amount { font-size: 32px; font-weight: 700; color: #C17C5A; margin: 0 4px; }
.total-note { font-size: 19px; color: #8F7F70; }

/* 底部悬浮栏 */
.bottom-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  height: 64px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #FFFFFF;
  box-shadow: 0 -2px 16px rgba(74, 63, 56, 0.08);
  z-index: 20;
}
.bar-left {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 22px;
  color: #8F7F70;
}
.cart-icon { font-size: 26px; color: #4A3F38; }
.bar-right { display: flex; gap: 10px; }
.btn-secondary {
  border-radius: 24px;
  border-color: #DCD2C9;
  color: #4A3F38;
  font-weight: 500;
}
.btn-secondary:hover { border-color: #4A3F38; color: #4A3F38; background: #F9F5F0; }
.btn-primary {
  border-radius: 24px;
  background: #4A3F38;
  border-color: #4A3F38;
  color: #FFF;
  font-weight: 500;
  min-width: 120px;
}
.btn-primary:hover { background: #5c5048; border-color: #5c5048; color: #FFF; }
</style>
