<template>
  <view class="page">
    <swiper class="banner" circular autoplay indicator-dots>
      <swiper-item v-for="(b, i) in banners" :key="i">
        <view class="banner-item" @click="onBannerClick(b)">
          <image v-if="imageOf(b.image)" :src="imageOf(b.image)" mode="aspectFill" class="banner-img" />
          <view v-else class="banner-text">
            <text class="banner-title">{{ b.title }}</text>
            <text class="banner-sub">{{ b.subtitle }}</text>
          </view>
        </view>
      </swiper-item>
    </swiper>

    <view class="panel entrances">
      <view class="section-title"><text></text>服务入口</view>
      <view class="entrance-grid">
        <view v-for="e in entrances" :key="e.path" class="entrance-item" @click="goTo(e.path)">
          <view v-if="e.name === '智能客服'" class="entrance-icon ai-entry-icon">
            <text>AI</text>
          </view>
          <view v-else class="entrance-icon" :class="e.color">{{ e.icon }}</view>
          <text class="entrance-name">{{ e.name }}</text>
          <text class="entrance-sub">{{ e.sub }}</text>
        </view>
      </view>
    </view>

    <view class="panel">
      <view class="section-header">
        <view class="section-title"><text></text>热门干洗服务</view>
        <view class="more" @click="goTo('/pages/service/list')">查看更多 ›</view>
      </view>
      <view v-if="hotServices.length" class="service-grid">
        <view v-for="item in hotServices" :key="item.id" class="service-card" @click="goOrder(item.id)">
          <image v-if="imageOf(item.image)" :src="imageOf(item.image)" mode="aspectFill" class="service-img" />
          <view v-else class="service-img service-img-ph">洗</view>
          <view class="service-body">
            <text class="name">{{ item.name }}</text>
            <text class="service-cycle">{{ item.cycle || '专业洗护' }}</text>
            <view class="service-foot">
              <text class="price">¥{{ item.price }}/件</text>
              <button class="mini-btn" size="mini" type="primary">预约</button>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="empty-wrap">暂无热门服务</view>
    </view>

    <view class="panel">
      <view class="section-header">
        <view class="section-title"><text></text>推荐商品</view>
        <view class="more" @click="goTo('/pages/product/list')">查看更多 ›</view>
      </view>
      <scroll-view class="h-scroll" scroll-x>
        <view class="scroll-row">
        <view v-for="p in products" :key="p.id" class="product-card" @click="goProduct(p.id)">
          <image v-if="imageOf(p.image)" :src="imageOf(p.image)" mode="aspectFill" class="product-img" />
          <view v-else class="product-img ph">{{ productInitial(p.name) }}</view>
          <text class="name">{{ p.name }}</text>
          <text class="price">¥{{ p.price }}</text>
          <view class="cart-mini">🛒</view>
        </view>
        </view>
      </scroll-view>
    </view>

    <view class="footer">
      <text>🎧 客服电话：{{ contact.phone || '400-888-8888' }}</text>
      <text v-if="contact.hours">服务时间：{{ contact.hours }}</text>
      <text v-else>服务时间：08:00-22:00</text>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getServiceList } from '@/api/service'
import { getProductList, type ProductItem } from '@/api/product'
import { getBanners, getContactConfig, getHomeModules, type BannerItem, type ContactConfig } from '@/api/settings'
import { resolveImageUrl } from '@/utils'

const defaultBanners: BannerItem[] = [
  { title: '专业干洗 · 上门取件', subtitle: '48小时送回' },
  { title: '干洗商城 · 护理用品', subtitle: '洗护用品放心选' },
]

const defaultHotServices = [
  { id: 1, name: '西装精洗', price: 39, image: '', cycle: '48小时' },
  { id: 2, name: '羽绒服干洗', price: 59, image: '', cycle: '72小时' },
  { id: 3, name: '大衣护理', price: 69, image: '', cycle: '72小时' },
  { id: 4, name: '皮衣保养', price: 129, image: '', cycle: '5-7天' },
]

const defaultProducts: ProductItem[] = [
  { id: 1, name: '衣物除菌喷雾', category: '洗护用品', price: 29.9, stock: 99, sales: 35, status: 1 },
  { id: 2, name: '羊毛衫护理液', category: '洗护用品', price: 39.9, stock: 88, sales: 28, status: 1 },
  { id: 3, name: '皮具保养膏', category: '护理工具', price: 49.9, stock: 60, sales: 22, status: 1 },
  { id: 4, name: '防尘收纳袋', category: '收纳用品', price: 19.9, stock: 120, sales: 46, status: 1 },
]

const banners = ref<BannerItem[]>(defaultBanners)
const hotServices = ref<any[]>(defaultHotServices)
const products = ref<ProductItem[]>(defaultProducts)
const contact = ref<ContactConfig>({})

const entrances = [
  { name: '上门取件', sub: '足不出户', icon: '取', color: 'blue-icon', path: '/pages/service/list' },
  { name: '自送到店', sub: '最快2小时', icon: '店', color: 'cyan-icon', path: '/pages/service/list' },
  { name: '商城', sub: '洗护用品', icon: '商', color: 'pink-icon', path: '/pages/product/list' },
  { name: '购物车', sub: '查看商品', icon: '车', color: 'yellow-icon', path: '/pages/cart/cart' },
  { name: '附近门店', sub: '快速查找', icon: '店', color: 'green-icon', path: '/pages/store/nearby' },
  { name: '我的订单', sub: '查看进度', icon: '单', color: 'purple-icon', path: '/pages/order/list' },
  { name: '智能客服', sub: '贴心解答', icon: 'AI', color: 'blue-icon', path: '/pages/ai/assistant' },
  { name: '用户评价', sub: '真实反馈', icon: '评', color: 'orange-icon', path: '/pages/comment/list' },
]

function goTo(path: string) {
  if (path.includes('cart')) {
    uni.switchTab({ url: path })
  } else if (path.includes('service') || path.includes('product')) {
    uni.switchTab({ url: path })
  } else {
    uni.navigateTo({ url: path })
  }
}

function goOrder(serviceId: number) {
  uni.navigateTo({ url: `/pages/service/order-create?serviceId=${serviceId}` })
}

function goProduct(id: number) {
  uni.navigateTo({ url: `/pages/product/detail?id=${id}` })
}

function productInitial(name?: string) {
  return name ? name.charAt(0) : ''
}

function imageOf(url?: string) {
  if (!url || url.includes('th.bing.com')) return ''
  return resolveImageUrl(url)
}

function onBannerClick(b: BannerItem) {
  const link = b && b.link ? b.link.trim() : ''
  if (!link) return
  if (link.startsWith('http')) return
  if (link.includes('service')) uni.switchTab({ url: '/pages/service/list' })
  else if (link.includes('product')) uni.switchTab({ url: '/pages/product/list' })
}

async function loadHome() {
  try {
    const data = await getHomeModules()
    if (data && data.hotServices && data.hotServices.length) hotServices.value = data.hotServices
    if (data && data.recommendProducts && data.recommendProducts.length) products.value = data.recommendProducts as ProductItem[]
  } catch (e) {
    console.error('[home] home-modules', e)
  }
  try {
    const list = await getServiceList()
    const serviceList = (Array.isArray(list) ? list : []).slice(0, 4)
    if (serviceList.length) hotServices.value = serviceList
  } catch (e) {
    console.error('[home] services', e)
  }
  try {
    const list = await getProductList()
    const productList = (Array.isArray(list) ? list : []).slice(0, 4)
    if (productList.length) products.value = productList
  } catch (e) {
    console.error('[home] products', e)
  }
  try {
    const bs = await getBanners()
    if (Array.isArray(bs) && bs.length) banners.value = bs
  } catch {
    banners.value = defaultBanners
  }
  try {
    contact.value = await getContactConfig()
  } catch (e) {
    console.error('[home] contact', e)
  }
}

onShow(loadHome)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 20rpx 20rpx 36rpx;
  box-sizing: border-box;
  background: linear-gradient(180deg, #f7fbff 0%, #f4f7fb 100%);
}
.banner { height: 236rpx; border-radius: 16rpx; overflow: hidden; margin-bottom: 18rpx; }
.banner-item, .banner-img { width: 100%; height: 100%; }
.banner-text {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  box-sizing: border-box;
  padding-left: 54rpx;
  background:
    radial-gradient(circle at 82% 48%, rgba(255,255,255,0.68), transparent 34%),
    linear-gradient(135deg, #bfe0ff 0%, #7dbdff 100%);
  color: #10376d;
}
.banner-title { font-size: 40rpx; font-weight: 800; }
.banner-sub { font-size: 26rpx; margin-top: 16rpx; opacity: 0.9; }
.panel {
  background: #fff;
  border-radius: 18rpx;
  padding: 24rpx;
  margin-bottom: 18rpx;
  box-shadow: 0 10rpx 32rpx rgba(29, 82, 143, 0.07);
}
.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.section-title {
  display: flex;
  align-items: center;
  gap: 12rpx;
  color: #111827;
  font-size: 30rpx;
  font-weight: 800;
  margin-bottom: 22rpx;
}
.section-title text {
  width: 6rpx;
  height: 30rpx;
  border-radius: 8rpx;
  background: #2474ff;
}
.more {
  color: #7b8798;
  font-size: 24rpx;
  margin-bottom: 22rpx;
}
.entrance-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border-top: 1rpx solid #edf1f7;
  border-left: 1rpx solid #edf1f7;
}
.entrance-item {
  min-height: 138rpx;
  text-align: center;
  padding: 18rpx 0 14rpx;
  box-sizing: border-box;
  border-right: 1rpx solid #edf1f7;
  border-bottom: 1rpx solid #edf1f7;
}
.entrance-icon {
  width: 58rpx;
  height: 58rpx;
  margin: 0 auto 10rpx;
  border-radius: 16rpx;
  color: #fff;
  font-size: 24rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(31, 111, 235, 0.16);
}
.ai-entry-icon {
  width: 58rpx;
  height: 58rpx;
  margin: 0 auto 10rpx;
  border-radius: 18rpx 18rpx 18rpx 6rpx;
  background: linear-gradient(135deg, #55b8ff, #2f78ff);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 18rpx rgba(47, 120, 255, 0.24);
}
.ai-entry-icon text {
  font-size: 24rpx;
  font-weight: 800;
  line-height: 1;
}
.blue-icon { background: linear-gradient(135deg, #7eb7ff, #2474ff); }
.cyan-icon { background: linear-gradient(135deg, #7dd8ff, #3f8dff); }
.pink-icon { background: linear-gradient(135deg, #ff8eb0, #f45b88); }
.yellow-icon { background: linear-gradient(135deg, #ffd15f, #f4a500); }
.green-icon { background: linear-gradient(135deg, #6ee8ae, #20c978); }
.purple-icon { background: linear-gradient(135deg, #9d8cff, #7162f4); }
.orange-icon { background: linear-gradient(135deg, #ffb27a, #ff6d4a); }
.entrance-name { display: block; color: #111827; font-size: 24rpx; line-height: 1.35; }
.entrance-sub { display: block; color: #9aa3af; font-size: 20rpx; margin-top: 4rpx; }
.h-scroll {
  width: 100%;
  white-space: nowrap;
}
.scroll-row {
  display: inline-flex;
  gap: 18rpx;
  padding-bottom: 2rpx;
}
.product-card {
  position: relative;
  flex: 0 0 176rpx;
  width: 176rpx;
  background: #f7faff;
  border-radius: 12rpx;
  padding: 12rpx 12rpx 14rpx;
  box-sizing: border-box;
  overflow: hidden;
}
.service-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18rpx;
}
.service-card {
  min-width: 0;
  background: #f7faff;
  border-radius: 14rpx;
  padding: 12rpx;
  box-sizing: border-box;
  overflow: hidden;
  box-shadow: inset 0 0 0 1rpx rgba(226, 235, 247, 0.8);
}
.service-img {
  width: 100%;
  height: 150rpx;
  border-radius: 12rpx;
  margin-bottom: 14rpx;
  background: #e4e7ed;
}
.service-img-ph {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #409eff;
  font-size: 44rpx;
  font-weight: 700;
}
.service-body {
  min-width: 0;
}
.product-img { width: 100%; height: 118rpx; border-radius: 8rpx; margin-bottom: 12rpx; background: #f1f5f9; }
.product-img.ph {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e4e7ed;
  font-size: 40rpx;
  color: #909399;
}
.name {
  display: block;
  color: #111827;
  font-size: 26rpx;
  font-weight: 600;
  line-height: 1.35;
  height: 70rpx;
  white-space: normal;
  overflow: hidden;
}
.service-cycle {
  display: block;
  color: #8a94a6;
  font-size: 21rpx;
  line-height: 1.3;
  height: 28rpx;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.service-foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10rpx;
  margin-top: 10rpx;
}
.price { display: block; color: #ff2f2f; font-size: 25rpx; font-weight: 800; margin: 4rpx 0 10rpx; }
.service-foot .price {
  margin: 0;
  min-width: 0;
  white-space: nowrap;
}
.mini-btn {
  width: 88rpx;
  height: 46rpx;
  line-height: 46rpx;
  padding: 0;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #2b7fff, #1267f7);
  font-size: 21rpx;
}
.cart-mini {
  position: absolute;
  right: 12rpx;
  bottom: 12rpx;
  width: 44rpx;
  height: 44rpx;
  line-height: 44rpx;
  text-align: center;
  border-radius: 50%;
  border: 2rpx solid #2474ff;
  color: #2474ff;
  background: #fff;
  font-size: 24rpx;
}
.footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12rpx;
  padding: 18rpx 24rpx;
  border-radius: 16rpx;
  background: #fff;
  box-shadow: 0 8rpx 24rpx rgba(29, 82, 143, 0.06);
}
.footer text { color: #909399; font-size: 23rpx; line-height: 1.5; }
</style>
