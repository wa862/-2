<template>
  <div class="cart-page">
    <!-- 页面标题 -->
    <header class="cart-header">
      <h1 class="cart-title">🛒 购物车</h1>
      <span class="cart-manage">管理</span>
    </header>

    <template v-if="!store.token">
      <el-empty description="请先登录后查看购物车" class="cart-empty">
        <el-button type="primary" @click="$router.push('/home/login')">去登录</el-button>
      </el-empty>
    </template>

    <template v-else>
      <el-empty v-if="!list.length && !loading" description="购物车是空的" class="cart-empty" />

      <div v-else class="cart-main">
        <!-- 店铺信息卡 -->
        <section class="block store-card">
          <div class="store-row">
            <span class="store-name">🏪 洗衣优选·专业干洗</span>
            <el-icon><ArrowRight /></el-icon>
          </div>
          <div class="store-tags">
            <span>满2件包邮</span>
            <span>次日达</span>
            <span>放心洗</span>
          </div>
        </section>

        <!-- 收货信息卡：可修改、可添加 -->
        <section class="block address-card" @click="showAddressDialog = true">
          <div class="address-row">
            <span class="address-label">📍 送至：</span>
            <span class="address-detail">{{ selectedAddressText }}</span>
            <span class="address-edit">修改</span>
          </div>
        </section>

        <!-- 选择门店：仅展示当前所选门店，点击可打开弹窗更换 -->
        <section class="block store-card" @click="showStoreDialog = true">
          <div class="address-row">
            <span class="address-label">🏪 选择门店：</span>
            <span class="address-detail">{{ selectedStoreText }}</span>
            <el-icon><ArrowRight /></el-icon>
          </div>
        </section>

        <!-- 干洗服务列表 -->
        <section v-if="serviceList.length" class="block section-card">
          <div class="section-title">干洗服务</div>
          <div v-for="item in serviceList" :key="item.id" class="item-card">
            <div class="item-left">
              <el-checkbox v-model="selectedMap[item.id]" class="item-check" />
              <div class="item-icon-wrap">
                <img v-if="item.image" :src="item.image" :alt="item.name" class="item-icon" />
                <span v-else class="item-emoji">🧥</span>
              </div>
              <div class="item-body">
                <div class="item-name">{{ item.name }}</div>
                <div class="item-meta">
                  <span class="item-rating">⭐ {{ getServiceRating(item) }} ({{ getServiceReview(item) }})</span>
                  <span class="item-tag">{{ getServiceTag(item) }}</span>
                </div>
                <div class="item-price-row">
                  <span class="item-price">单价：￥{{ item.price }}/{{ item.unit || '件' }}</span>
                  <div class="item-qty">
                    <button type="button" class="qty-btn" :disabled="item.quantity <= 1" @click="changeQty(item, -1)">−</button>
                    <span class="qty-num">{{ item.quantity }}</span>
                    <button type="button" class="qty-btn" :disabled="item.quantity >= 99" @click="changeQty(item, 1)">+</button>
                  </div>
                </div>
                <div class="item-features">{{ getServiceFeatures(item) }}</div>
                <div class="item-subtotal">小计：￥{{ (Number(item.price) * item.quantity).toFixed(2) }}</div>
              </div>
            </div>
            <el-button type="danger" link class="item-delete" @click="remove(item.id)">删除</el-button>
          </div>
        </section>

        <!-- 推荐搭配（可加购） -->
        <section v-if="recommendService" class="block section-card recommend-card">
          <div class="section-title">推荐搭配</div>
          <div class="item-card add-card">
            <div class="item-left">
              <el-checkbox disabled class="item-check" />
              <span class="item-emoji">🧥</span>
              <div class="item-body">
                <div class="item-name">{{ recommendService.name }}</div>
                <div class="item-meta">
                  <span class="item-rating">⭐ 4.8 (1.2万+评价)</span>
                  <span class="item-tag winter">❄️ 冬季推荐</span>
                </div>
                <div class="item-price-row">
                  <span class="item-price">单价：￥{{ recommendService.price }}/件</span>
                  <span class="item-qty-note">数量：0</span>
                </div>
                <div class="item-features">🚚 可搭配羽绒服一起下单</div>
                <div class="item-subtotal">小计：￥0.00</div>
              </div>
            </div>
            <el-button type="primary" plain size="small" @click="addRecommend">加入购物车</el-button>
          </div>
        </section>

        <!-- 商品列表 -->
        <section v-if="productList.length" class="block section-card">
          <div class="section-title">商品</div>
          <div v-for="item in productList" :key="item.id" class="item-card">
            <div class="item-left">
              <el-checkbox v-model="selectedMap[item.id]" class="item-check" />
              <div class="item-icon-wrap">
                <img v-if="item.image" :src="item.image" :alt="item.name" class="item-icon" />
                <span v-else class="item-emoji">👟</span>
              </div>
              <div class="item-body">
                <div class="item-name">{{ item.name }}</div>
                <div class="item-meta">
                  <span class="item-rating">⭐ {{ getProductRating(item) }} ({{ getProductReview(item) }})</span>
                  <span class="item-tag hot">🔥 热销</span>
                </div>
                <div class="item-price-row">
                  <span class="item-price">单价：￥{{ item.price }}/{{ item.unit || '件' }}</span>
                  <div class="item-qty">
                    <button type="button" class="qty-btn" :disabled="item.quantity <= 1" @click="changeQty(item, -1)">−</button>
                    <span class="qty-num">{{ item.quantity }}</span>
                    <button type="button" class="qty-btn" :disabled="item.quantity >= 99" @click="changeQty(item, 1)">+</button>
                  </div>
                </div>
                <div class="item-features">🔄 鞋面养护 · 除菌除味</div>
                <div class="item-subtotal">小计：￥{{ (Number(item.price) * item.quantity).toFixed(2) }}</div>
              </div>
            </div>
            <el-button type="danger" link class="item-delete" @click="remove(item.id)">删除</el-button>
          </div>
        </section>

        <!-- 热销推荐（可加购） -->
        <section v-if="hotService" class="block section-card hot-card">
          <div class="section-title">热销推荐</div>
          <div class="item-card add-card">
            <div class="item-left">
              <el-checkbox disabled class="item-check" />
              <span class="item-emoji">👟</span>
              <div class="item-body">
                <div class="item-name">{{ hotService.name }}</div>
                <div class="item-meta">
                  <span class="item-rating">⭐ 4.7 (3.4万+评价)</span>
                  <span class="item-tag hot">🔥 热销</span>
                </div>
                <div class="item-price-row">
                  <span class="item-price">单价：￥{{ hotService.price }}/双</span>
                  <span class="item-qty-note">数量：0</span>
                </div>
                <div class="item-features">🔄 鞋面养护 · 除菌除味</div>
                <div class="item-subtotal">小计：￥0.00</div>
              </div>
            </div>
            <el-button type="primary" plain size="small" @click="addHot">加入购物车</el-button>
          </div>
        </section>

        <!-- 订单总结 -->
        <section class="block summary-card">
          <div class="summary-row">
            <span>商品金额：</span>
            <span>￥{{ selectedTotal.toFixed(2) }}</span>
          </div>
          <div class="summary-row">
            <span>运费：</span>
            <span>￥0.00 <small>(满2件包邮)</small></span>
          </div>
          <div class="summary-divider" />
          <div class="summary-row total-row">
            <span>实付合计：</span>
            <span class="total-pay">￥{{ payTotal.toFixed(2) }}</span>
          </div>
        </section>
      </div>

      <!-- 底部结算栏 -->
      <footer v-if="list.length" class="cart-footer">
        <div class="footer-left">
          <el-checkbox v-model="allChecked" class="all-check" @change="toggleAll">全选</el-checkbox>
          <span class="footer-count">({{ selectedCount }}/{{ list.length }})</span>
        </div>
        <div class="footer-center">
          <span class="footer-total-label">合计：</span>
          <span class="footer-total-value">￥{{ selectedTotal.toFixed(2) }}</span>
        </div>
        <el-button type="primary" class="footer-btn" :disabled="selectedCount === 0" @click="goCheckout">
          去结算({{ selectedCount }}件)
        </el-button>
      </footer>
    </template>

    <!-- 地址选择/新增弹窗 -->
    <el-dialog v-model="showAddressDialog" title="取送地址" width="420px">
      <div class="dialog-address-list">
        <template v-if="addressList.length">
          <div
            v-for="a in addressList"
            :key="a.id"
            class="dialog-address-item"
            :class="{ active: selectedAddressId === a.id }"
            @click="selectAddress(a.id)"
          >
            <div class="addr-line">{{ a.contactName }} {{ maskPhone(a.phone) }}</div>
            <div class="addr-line2">{{ fullAddress(a) }}</div>
          </div>
        </template>
        <el-empty v-else description="暂无取送地址，请点击下方「新增地址」添加" :image-size="64" />
      </div>
      <template #footer>
        <el-button @click="showAddressDialog = false">关闭</el-button>
        <el-button type="primary" @click="goAddAddress">新增地址</el-button>
      </template>
    </el-dialog>

    <!-- 选择门店弹窗 -->
    <el-dialog v-model="showStoreDialog" title="选择门店" width="420px">
      <div class="dialog-store-list">
        <div
          v-for="s in storeList"
          :key="s.id"
          class="dialog-store-item"
          :class="{ active: selectedStoreId === s.id }"
          @click="selectStore(s.id)"
        >
          <div class="store-name">{{ s.name }}</div>
          <div class="store-addr">{{ s.address }}</div>
          <div v-if="s.phone" class="store-phone">{{ s.phone }}</div>
        </div>
      </div>
      <el-empty v-if="!storeList.length && !storeLoading" description="暂无门店" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowRight } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getCartList, updateCartQuantity, removeCartItem, addToCart } from '@/api/cart'
import { getServiceList } from '@/api/service'
import { getAddressList, type UserAddressItem } from '@/api/address'
import { getStoreList, type StoreItem } from '@/api/store'
import type { ServiceItem } from '@/api/service'
import type { CartItem } from '@/api/cart'

const store = useUserStore()
const router = useRouter()
const route = useRoute()
const list = ref<CartItem[]>([])
const loading = ref(false)
const selectedMap = reactive<Record<number, boolean>>({})
const addressList = ref<UserAddressItem[]>([])
const selectedAddressId = ref<number | null>(null)
const showAddressDialog = ref(false)
const storeList = ref<StoreItem[]>([])
const selectedStoreId = ref<number | null>(null)
const showStoreDialog = ref(false)
const storeLoading = ref(false)

const serviceList = computed(() => list.value.filter((i) => i.itemType === 'SERVICE'))
const productList = computed(() => list.value.filter((i) => i.itemType === 'PRODUCT'))

const cartServiceIds = computed(() => new Set(serviceList.value.map((i) => i.serviceId).filter(Boolean)))
// 推荐搭配：大衣/羊绒类，且未在购物车
const recommendService = computed(() => {
  return allServices.value.find(
    (s) => ((s.name || '').includes('大衣') || (s.name || '').includes('羊绒')) && !cartServiceIds.value.has(s.id)
  )
})
// 热销：鞋类，且未在购物车
const hotService = computed(() => {
  return allServices.value.find(
    (s) => ((s.name || '').includes('运动鞋') || (s.name || '').includes('鞋')) && !cartServiceIds.value.has(s.id)
  )
})
const allServices = ref<ServiceItem[]>([])

function getServiceRating(item: CartItem) {
  return '4.9'
}
function getServiceReview(item: CartItem) {
  return '2.3万+评价'
}
function getServiceTag(item: CartItem) {
  return '专业洗护'
}
function getServiceFeatures(item: CartItem) {
  return '🧺 常规洗涤 · 蓬松还原'
}
function getProductRating(item: CartItem) {
  return '4.7'
}
function getProductReview(item: CartItem) {
  return '3.4万+评价'
}

const selectedCount = computed(() => list.value.filter((i) => selectedMap[i.id]).length)
const selectedTotal = computed(() =>
  list.value.filter((i) => selectedMap[i.id]).reduce((sum, i) => sum + Number(i.price) * i.quantity, 0)
)
const allChecked = computed({
  get: () => list.value.length > 0 && list.value.every((i) => selectedMap[i.id]),
  set: (v: boolean) => {
    list.value.forEach((i) => { selectedMap[i.id] = v })
  },
})
const payTotal = computed(() => selectedTotal.value)

const selectedAddressText = computed(() => {
  const a = addressList.value.find((x) => x.id === selectedAddressId.value)
  if (!a) return '请添加取送地址'
  const parts = [a.province, a.city, a.district, a.detailAddress].filter(Boolean)
  return `${parts.join(' ') || a.detailAddress} · ${a.contactName} ${maskPhone(a.phone)}`
})
const selectedStoreText = computed(() => {
  const fromQuery = route.query.storeName
  if (fromQuery && String(fromQuery).trim()) {
    try {
      return decodeURIComponent(String(fromQuery).trim())
    } catch {
      return String(fromQuery).trim()
    }
  }
  const s = storeList.value.find((x) => x.id === selectedStoreId.value)
  return s ? s.name : '请选择门店'
})

function maskPhone(phone: string) {
  if (!phone || phone.length < 7) return phone
  return phone.slice(0, 3) + '****' + phone.slice(-4)
}
function fullAddress(a: UserAddressItem) {
  const parts = [a.province, a.city, a.district, a.detailAddress].filter(Boolean)
  return parts.join(' ') || a.detailAddress
}
function selectAddress(id: number) {
  selectedAddressId.value = id
  showAddressDialog.value = false
}
function goAddAddress() {
  showAddressDialog.value = false
  router.push({ path: '/home/user/checkout', query: { addAddr: '1' } })
}
function selectStore(id: number) {
  selectedStoreId.value = id
  showStoreDialog.value = false
  // 从弹窗选择系统门店后，只保留 storeId，去掉 storeName，以便显示系统门店名
  router.replace({ path: route.path, query: { storeId: String(id) } })
}
function loadAddresses() {
  if (!store.token) return
  getAddressList().then((data) => {
    addressList.value = data ?? []
    if (addressList.value.length && selectedAddressId.value === null) {
      const def = addressList.value.find((a) => a.isDefault) || addressList.value[0]
      selectedAddressId.value = def.id
    }
  }).catch(() => { addressList.value = [] })
}
function loadStores() {
  storeLoading.value = true
  getStoreList().then((data) => {
    storeList.value = data ?? []
    const fromQuery = route.query.storeId != null ? Number(route.query.storeId) : null
    if (fromQuery != null && storeList.value.some((s) => s.id === fromQuery)) {
      selectedStoreId.value = fromQuery
    } else if (storeList.value.length && selectedStoreId.value === null) {
      selectedStoreId.value = storeList.value[0].id
    }
  }).catch(() => { storeList.value = [] }).finally(() => { storeLoading.value = false })
}

function toggleAll(v: boolean) {
  list.value.forEach((i) => { selectedMap[i.id] = v })
}
function changeQty(item: CartItem, delta: number) {
  const next = Math.max(1, Math.min(99, item.quantity + delta))
  updateCartQuantity(item.id, next).then(() => {
    item.quantity = next
  }).catch(() => load())
}
function remove(id: number) {
  removeCartItem(id).then(() => {
    delete selectedMap[id]
    load()
  })
}
function addRecommend() {
  if (!recommendService.value) return
  addToCart('SERVICE', undefined, recommendService.value.id, 1).then(() => {
    ElMessage.success('已加入购物车')
    load()
  }).catch((e: any) => ElMessage.error(e?.response?.data?.message || '加入失败'))
}
function addHot() {
  if (!hotService.value) return
  addToCart('SERVICE', undefined, hotService.value.id, 1).then(() => {
    ElMessage.success('已加入购物车')
    load()
  }).catch((e: any) => ElMessage.error(e?.response?.data?.message || '加入失败'))
}
function goCheckout() {
  const ids = list.value.filter((i) => selectedMap[i.id]).map((i) => i.id)
  if (ids.length === 0) return
  const q: Record<string, string> = { ids: ids.join(',') }
  if (selectedAddressId.value != null) q.addressId = String(selectedAddressId.value)
  if (selectedStoreId.value != null) q.storeId = String(selectedStoreId.value)
  router.push({ path: '/home/user/checkout', query: q })
}

function load() {
  if (!store.token) return
  loading.value = true
  getCartList().then((data) => {
    list.value = data ?? []
    list.value.forEach((i) => {
      if (selectedMap[i.id] === undefined) selectedMap[i.id] = true
    })
  }).catch(() => { list.value = [] }).finally(() => { loading.value = false })
  getServiceList().then((data) => {
    allServices.value = data || []
  }).catch(() => { allServices.value = [] })
  loadAddresses()
  loadStores()
}

watch(list, (val) => {
  val.forEach((i) => {
    if (selectedMap[i.id] === undefined) selectedMap[i.id] = true
  })
}, { immediate: true })

// 从附近门店页「选择该门店」带 storeId 进入时，刷新门店列表并渲染所选门店
watch(() => route.query.storeId, (storeId) => {
  if (storeId != null) loadStores()
}, { immediate: true })

onMounted(load)
</script>

<style scoped>
.cart-page {
  min-height: 100vh;
  background: #F9F5F0;
  padding: 16px 16px 80px;
  font-size: 26px;
}
.cart-empty { padding: 48px 0; }

.cart-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.cart-title { font-size: 42px; font-weight: 600; color: #2D2A27; margin: 0; }
.cart-manage { font-size: 28px; color: #4A3F38; cursor: pointer; }

.block {
  background: #fff;
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(74, 63, 56, 0.06);
}
.store-card .store-row, .address-card .address-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.store-name { font-size: 32px; font-weight: 600; color: #2D2A27; flex: 1; }
.store-tags, .promo-tags { display: flex; gap: 8px; margin-top: 10px; flex-wrap: wrap; }
.store-tags span, .promo-tags span {
  font-size: 22px;
  color: #8F7F70;
  background: #F0E9E2;
  padding: 4px 10px;
  border-radius: 999px;
}
.address-label { font-size: 26px; color: #2D2A27; }
.address-detail { flex: 1; font-size: 26px; color: #606266; }
.address-edit { font-size: 26px; color: #4A3F38; cursor: pointer; }
.store-card { cursor: pointer; position: relative; }
.store-card .link-nearby {
  display: block;
  margin-top: 6px;
  font-size: 18px;
  color: #C17C5A;
  text-decoration: none;
}
.store-card .link-nearby:hover { text-decoration: underline; }
.dialog-address-list { max-height: 320px; overflow-y: auto; }
.dialog-address-item {
  padding: 12px; border: 1px solid #F0E9E2; border-radius: 12px; margin-bottom: 8px; cursor: pointer;
}
.dialog-address-item.active { border-color: #4A3F38; background: #F9F5F0; }
.addr-line { font-weight: 500; color: #2D2A27; }
.addr-line2 {
  font-size: 22px;
  color: #8F7F70;
  margin-top: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.dialog-store-list { max-height: 320px; overflow-y: auto; }
.dialog-store-item {
  padding: 12px; border: 1px solid #F0E9E2; border-radius: 12px; margin-bottom: 8px; cursor: pointer;
}
.dialog-store-item.active { border-color: #4A3F38; background: #F9F5F0; }
.dialog-store-item .store-name { font-weight: 500; color: #2D2A27; }
.dialog-store-item .store-addr { font-size: 22px; color: #8F7F70; margin-top: 4px; }
.dialog-store-item .store-phone { font-size: 20px; color: #606266; margin-top: 2px; }

.section-title { font-size: 28px; color: #8F7F70; margin-bottom: 12px; }
.section-card { padding: 14px; }
.item-card {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px dashed #F0E9E2;
}
.item-card:last-child { border-bottom: none; }
.item-left { display: flex; align-items: flex-start; gap: 10px; flex: 1; min-width: 0; }
.item-check { flex-shrink: 0; }
.item-icon-wrap { width: 56px; height: 56px; border-radius: 12px; overflow: hidden; background: #F0E9E2; flex-shrink: 0; }
.item-icon { width: 100%; height: 100%; object-fit: contain; }
.item-icon-wrap { width: 98px; height: 98px; }
.item-emoji { font-size: 50px; width: 98px; text-align: center; flex-shrink: 0; }
.item-body { flex: 1; min-width: 0; }
.item-name { font-weight: 600; font-size: 30px; color: #2D2A27; margin-bottom: 8px; }
.item-meta { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; flex-wrap: wrap; }
.item-rating { font-size: 22px; color: #8F7F70; }
.item-tag { font-size: 20px; color: #C17C5A; background: #F0E9E2; padding: 4px 10px; border-radius: 6px; }
.item-tag.winter { color: #5B8DEF; }
.item-tag.hot { color: #E74C3C; }
.item-price-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 4px; }
.item-price { font-size: 28px; color: #C17C5A; font-weight: 600; }
.item-qty { display: inline-flex; align-items: center; border: 1px solid #DCD2C9; border-radius: 8px; }
.item-qty .qty-btn {
  width: 46px; height: 46px; border: none; background: #F9F5F0; color: #4A3F38; cursor: pointer; font-size: 32px;
}
.item-qty .qty-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.item-qty .qty-num { min-width: 50px; text-align: center; font-size: 28px; }
.item-qty-note { font-size: 22px; color: #8F7F70; }
.item-features { font-size: 22px; color: #8F7F70; margin-bottom: 4px; }
.item-subtotal { font-size: 28px; font-weight: 600; color: #2D2A27; }
.item-delete { flex-shrink: 0; }
.add-card .item-emoji { display: inline-block; }
.item-delete :deep(.el-button) { font-size: 22px; }

.recommend-card .item-card, .hot-card .item-card { border-bottom: none; }

.promo-card { margin-bottom: 12px; }
.promo-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.promo-label { font-size: 19px; color: #2D2A27; }
.promo-extra { flex: 1; font-size: 18px; color: #8F7F70; }

.summary-card { padding: 16px; }
.summary-row { display: flex; justify-content: space-between; font-size: 26px; color: #606266; margin-bottom: 8px; }
.summary-row span:last-child { color: #2D2A27; }
.summary-row .text-discount { color: #C17C5A; }
.summary-divider { height: 1px; background: #F0E9E2; margin: 12px 0; }
.summary-row.total-row { font-size: 32px; font-weight: 600; margin-bottom: 0; }
.total-pay { font-size: 40px; color: #C17C5A; }

.cart-footer {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  height: 86px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  background: #fff;
  box-shadow: 0 -2px 12px rgba(74, 63, 56, 0.08);
  z-index: 10;
}
.footer-left { display: flex; align-items: center; gap: 4px; }
.all-check { font-size: 26px; }
.footer-count { font-size: 22px; color: #8F7F70; }
.footer-center { flex: 1; text-align: center; padding: 0 12px; }
.footer-total-label { font-size: 26px; color: #606266; margin-right: 4px; }
.footer-total-value { font-size: 38px; font-weight: 700; color: #C17C5A; }
.footer-discount-tip { font-size: 18px; color: #8F7F70; margin-left: 4px; }
.footer-btn { border-radius: 24px; min-width: 200px; font-weight: 500; font-size: 26px; padding: 10px 20px; height: auto; }
</style>
