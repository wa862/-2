<template>
  <div class="nearby-page">
    <div class="header-row">
      <div>
        <h2>附近门店</h2>
        <p class="tip">基于百度地图定位，智能推荐您附近的干洗店。</p>
      </div>
      <div class="search-box">
        <el-input
          v-model="keyword"
          placeholder="搜索附近：干洗店 / 洗衣店 / 商圈"
          clearable
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </template>
        </el-input>
      </div>
    </div>

    <div class="content">
      <div class="map-card">
        <div class="map-toolbar">
          <div>
            <el-button size="small" @click="locateUser" :loading="locating">
              重新定位
            </el-button>
            <span v-if="city" class="city-text">当前城市：{{ city }}</span>
          </div>
          <span v-if="loading" class="status-text">地图加载中...</span>
        </div>
        <div id="baiduMap" class="map-container"></div>
      </div>

      <div class="list-card">
        <h3 class="list-title">附近干洗店</h3>
        <el-empty v-if="!loading && !stores.length" description="暂无附近干洗店，请尝试放大或拖动地图" />
        <div v-else class="store-list">
          <div v-for="item in stores" :key="item.uid" class="store-item">
            <div class="store-main">
              <div class="store-name-row">
                <span class="store-name">{{ item.title }}</span>
                <span class="store-distance">{{ item.distanceText }}</span>
              </div>
              <div class="store-address">{{ item.address }}</div>
              <div v-if="item.phone" class="store-phone">电话：{{ item.phone }}</div>
            </div>
            <el-button type="primary" size="small" @click="onSelectNearbyStore(item)">选择该门店</el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getStoreList, type StoreItem as ApiStoreItem } from '@/api/store'

const router = useRouter()
const route = useRoute()

interface StoreItem {
  uid: string
  title: string
  address: string
  phone?: string
  point: { lng: number; lat: number }
  distanceText: string
}

const BAIDU_AK = 'S32mnPt9bygJ8kW0OtyyPfzjTdZXAc3R'

const keyword = ref('干洗店')
const loading = ref(false)
const locating = ref(false)
const city = ref('')
const stores = ref<StoreItem[]>([])

const map = ref<any>(null)
const currentCenter = ref<{ lng: number; lat: number } | null>(null)

const ourStores = ref<ApiStoreItem[]>([])
const ourStoresLoading = ref(false)
function loadOurStores() {
  ourStoresLoading.value = true
  getStoreList()
    .then((data) => { ourStores.value = data ?? [] })
    .catch(() => { ourStores.value = [] })
    .finally(() => { ourStoresLoading.value = false })
}

/** 选择该门店并返回购物车，购物车页会同步选中该门店；displayName 用于在购物车展示你从地图选的门店名 */
function selectOurStore(s: ApiStoreItem, displayName?: string) {
  const name = displayName || s.name || '该门店'
  router.push({
    path: '/home/user/cart',
    query: { storeId: String(s.id), storeName: name },
  })
  ElMessage.success('已选择「' + name + '」，已返回购物车')
}

/** 附近干洗店列表点击「选择该门店」：
 * - 若从下单页进入（from=order-create），选中后回到预约页面并带上门店
 * - 其他情况：保持原逻辑，返回购物车页
 */
function onSelectNearbyStore(item: StoreItem) {
  const title = (item.title || '').trim()
  const matched = ourStores.value.find(
    (s) => s.name && (s.name.includes(title) || title.includes(s.name))
  )
  const target = matched || (ourStores.value.length > 0 ? ourStores.value[0] : null)
  const displayName = title || target?.name || '该门店'
  // 从下单页进入：返回到预约页，不动购物车
  const from = route.query.from
  const serviceId = route.query.serviceId
  const storeIdStr = target ? String(target.id) : undefined
  if (from === 'order-create' && serviceId && storeIdStr) {
    const q: Record<string, string> = {
      serviceId: String(serviceId),
      storeId: storeIdStr,
      storeName: displayName,
    }
    if (item.address) q.storeAddress = item.address
    const specName = route.query.specName
    if (specName != null && String(specName).trim()) q.specName = String(specName).trim()
    router.push({
      path: '/home/user/order/create',
      query: q,
    })
    ElMessage.success('已选择「' + displayName + '」，已返回预约页面')
    return
  }
  // 默认：保持原来的「返回购物车并选择门店」行为
  if (matched) {
    selectOurStore(matched, title || undefined)
  } else if (ourStores.value.length > 0 && target) {
    router.push({
      path: '/home/user/cart',
      query: { storeId: String(target.id), storeName: title || target.name },
    })
    ElMessage.success('已选择「' + (title || target.name) + '」，可在购物车中更换其他门店')
  } else {
    focusStore(item)
    ElMessage.info('暂无可选门店，请稍后再试')
  }
}

function loadBaiduMap(): Promise<any> {
  return new Promise((resolve, reject) => {
    const w = window as any
    if (w.BMap) {
      resolve(w.BMap)
      return
    }
    const existing = document.querySelector<HTMLScriptElement>('#baidu-map-script')
    if (existing) {
      existing.addEventListener('load', () => resolve(w.BMap))
      existing.addEventListener('error', reject)
      return
    }
    const script = document.createElement('script')
    script.id = 'baidu-map-script'
    script.type = 'text/javascript'
    script.src = `https://api.map.baidu.com/api?v=3.0&ak=${BAIDU_AK}&callback=onBMapCallback`
    w.onBMapCallback = () => resolve(w.BMap)
    script.onerror = reject
    document.body.appendChild(script)
  })
}

function initMap(BMap: any) {
  loading.value = true
  const mapInstance = new BMap.Map('baiduMap')
  map.value = mapInstance
  mapInstance.enableScrollWheelZoom(true)

  const geolocation = new BMap.Geolocation()
  locating.value = true
  geolocation.getCurrentPosition(
    (r: any) => {
      locating.value = false
      if (geolocation.getStatus() === 0 && r.point) {
        const point = r.point
        currentCenter.value = { lng: point.lng, lat: point.lat }
        mapInstance.centerAndZoom(point, 15)
        city.value = (r.address && r.address.city) || ''
        searchNearby(BMap, keyword.value, point)
      } else {
        const point = new BMap.Point(116.404, 39.915)
        currentCenter.value = { lng: point.lng, lat: point.lat }
        mapInstance.centerAndZoom(point, 12)
        city.value = '北京'
        searchNearby(BMap, keyword.value, point)
      }
    },
    { enableHighAccuracy: true }
  )

  mapInstance.addEventListener('dragend', () => {
    const center = mapInstance.getCenter()
    currentCenter.value = { lng: center.lng, lat: center.lat }
    searchNearby(BMap, keyword.value, center)
  })
}

function calcDistanceText(center: { lng: number; lat: number }, p: { lng: number; lat: number }) {
  const rad = (d: number) => (d * Math.PI) / 180
  const R = 6378137
  const dLat = rad(p.lat - center.lat)
  const dLng = rad(p.lng - center.lng)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(rad(center.lat)) * Math.cos(rad(p.lat)) * Math.sin(dLng / 2) * Math.sin(dLng / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  const dist = R * c
  if (dist < 1000) return `${Math.round(dist)} m`
  return `${(dist / 1000).toFixed(1)} km`
}

function searchNearby(BMap: any, kw: string, centerPoint: any) {
  if (!map.value) return
  loading.value = true
  map.value.clearOverlays()
  const local = new BMap.LocalSearch(map.value, {
    onSearchComplete: (results: any) => {
      loading.value = false
      const list: StoreItem[] = []
      if (!results) {
        stores.value = []
        return
      }
      const center = currentCenter.value || { lng: centerPoint.lng, lat: centerPoint.lat }
      const max = results.getCurrentNumPois ? results.getCurrentNumPois() : 0
      for (let i = 0; i < max; i++) {
        const poi = results.getPoi(i)
        if (!poi) continue
        const pt = poi.point
        const item: StoreItem = {
          uid: poi.uid || `${pt.lng},${pt.lat}`,
          title: poi.title || '干洗店',
          address: poi.address || '',
          phone: poi.phoneNumber || '',
          point: { lng: pt.lng, lat: pt.lat },
          distanceText: calcDistanceText(center, { lng: pt.lng, lat: pt.lat }),
        }
        list.push(item)

        const marker = new BMap.Marker(pt)
        const label = new BMap.Label(poi.title, { offset: new BMap.Size(20, -10) })
        marker.setLabel(label)
        map.value.addOverlay(marker)
      }
      stores.value = list
    },
  })
  local.searchNearby(kw || '干洗店', centerPoint, 3000)
}

async function handleSearch() {
  const w = window as any
  if (!w.BMap || !map.value || !currentCenter.value) {
    ElMessage.warning('地图尚未加载完成')
    return
  }
  searchNearby(w.BMap, keyword.value.trim() || '干洗店', new (w.BMap as any).Point(currentCenter.value.lng, currentCenter.value.lat))
}

function focusStore(item: StoreItem) {
  const w = window as any
  if (!w.BMap || !map.value || !item.point) return
  const pt = new w.BMap.Point(item.point.lng, item.point.lat)
  map.value.centerAndZoom(pt, 16)
}

async function locateUser() {
  const w = window as any
  if (!w.BMap || !map.value) {
    ElMessage.warning('地图尚未加载完成')
    return
  }
  const BMap = w.BMap
  const geolocation = new BMap.Geolocation()
  locating.value = true
  geolocation.getCurrentPosition(
    (r: any) => {
      locating.value = false
      if (geolocation.getStatus() === 0 && r.point) {
        const point = r.point
        currentCenter.value = { lng: point.lng, lat: point.lat }
        map.value.centerAndZoom(point, 15)
        city.value = (r.address && r.address.city) || ''
        searchNearby(BMap, keyword.value.trim() || '干洗店', point)
      } else {
        ElMessage.error('定位失败，请检查浏览器定位权限')
      }
    },
    { enableHighAccuracy: true }
  )
}

onMounted(async () => {
  loadOurStores()
  try {
    const BMap = await loadBaiduMap()
    initMap(BMap)
  } catch (e) {
    loading.value = false
    ElMessage.error('百度地图加载失败，请稍后重试')
  }
})
</script>

<style scoped>
.nearby-page {
  background: #f5f7fa;
  padding: 16px 0 24px;
  min-height: calc(100vh - 64px);
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 12px;
  padding: 0 4px;
}

.nearby-page h2 {
  margin-bottom: 4px;
}

.tip {
  color: #909399;
  margin-bottom: 4px;
  font-size: 18px;
}

.search-box {
  width: 360px;
}

.content {
  display: flex;
  gap: 16px;
  align-items: stretch;
}

.map-card,
.list-card {
  background: #ffffff;
  border-radius: 16px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.06);
  padding: 14px 16px 16px;
}

.map-card {
  flex: 2;
  display: flex;
  flex-direction: column;
  min-height: 360px;
}

.list-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-height: none;
}

.map-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.map-container {
  flex: 1;
  min-height: 340px;
  border-radius: 12px;
  overflow: hidden;
}

.city-text {
  margin-left: 12px;
  font-size: 18px;
  color: #606266;
}

.status-text {
  font-size: 18px;
  color: #909399;
}

.list-title {
  font-size: 20px;
  margin-bottom: 8px;
}

.store-list {
  flex: 1;
  overflow-y: auto;
  padding-right: 4px;
}

.store-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 8px;
  padding: 10px 8px;
  border-bottom: 1px solid #f0f2f5;
}

.store-item:last-child {
  border-bottom: none;
}

.store-main {
  flex: 1;
}

.store-name-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 4px;
}

.store-name {
  font-weight: 600;
  color: #303133;
}

.store-distance {
  font-size: 18px;
  color: #909399;
}

.store-address {
  font-size: 18px;
  color: #606266;
}

.store-phone {
  font-size: 18px;
  color: #909399;
  margin-top: 2px;
}
</style>
