<template>
  <div class="home-page">
    <section class="banner">
      <el-carousel height="420px" indicator-position="outside">
        <el-carousel-item v-for="(b, i) in banners" :key="i">
          <div class="banner-item" @click="onBannerClick(b)">
            <img v-if="b.image" :src="b.image" alt="" class="banner-img" />
          </div>
        </el-carousel-item>
      </el-carousel>
    </section>
    <section class="entrances">
      <h3 class="section-title">服务入口</h3>
      <el-row :gutter="20">
        <el-col v-for="(e, i) in entrances" :key="i" :span="6">
          <el-card shadow="hover" class="entrance-card" @click="goTo(e.path)">
            <div class="entrance-icon">{{ e.icon }}</div>
            <div class="entrance-name">{{ e.name }}</div>
          </el-card>
        </el-col>
      </el-row>
    </section>
    <section class="section">
      <h3 class="section-title">热门干洗服务</h3>
      <el-row v-if="hotServices.length" :gutter="20">
        <el-col v-for="item in hotServices" :key="item.id" :span="6">
          <el-card shadow="hover" class="service-card" @click="$router.push({ path: '/home/user/order/create', query: { serviceId: item.id } })">
            <div class="service-name">{{ item.name }}</div>
            <div class="service-price">¥{{ item.price }} / 件</div>
            <el-button type="primary" size="small">立即预约</el-button>
          </el-card>
        </el-col>
      </el-row>
      <el-empty v-else description="暂无热门服务" />
    </section>
    <section class="section">
      <h3 class="section-title">推荐商品</h3>
      <el-row :gutter="20">
        <el-col v-for="p in products" :key="p.id" :span="6">
          <el-card shadow="hover" class="product-card" @click="openProductDetail(p)">
            <div class="product-img-wrap">
              <img v-if="p.image" :src="p.image" :alt="p.name" class="product-img" />
              <div v-else class="product-img product-img-placeholder">{{ p.name?.charAt(0) || '?' }}</div>
            </div>
            <div class="product-name">{{ p.name }}</div>
            <div class="product-price">¥{{ p.price }}</div>
          </el-card>
        </el-col>
      </el-row>
      <el-dialog
        v-model="productDetailVisible"
        title="商品详情"
        width="480px"
        class="detail-dialog"
      >
        <template v-if="currentProduct">
          <div class="detail-img">
            <img
              v-if="currentProduct.image"
              :src="currentProduct.image"
              :alt="currentProduct.name"
            />
            <div v-else class="detail-img-ph">暂无图片</div>
          </div>
          <div class="detail-name">{{ currentProduct.name }}</div>
          <div class="detail-price">¥{{ currentProduct.price }}</div>
          <div class="detail-desc">
            {{ currentProduct.description || '专业洗护商品，品质保证。' }}
          </div>
          <div class="detail-actions">
            <el-button
              type="primary"
              @click="addCart(currentProduct!); productDetailVisible = false"
            >
              加入购物车
            </el-button>
            <el-button @click="goProductDetail(currentProduct.id); productDetailVisible = false">
              查看详情页
            </el-button>
          </div>
        </template>
      </el-dialog>
    </section>
    <footer class="footer">
      <div class="footer-left">
        <div>关于我们 | 联系我们 | 帮助中心 | 隐私政策</div>
        <div>客服电话：{{ contact.phone || '400-888-8888' }}</div>
        <div v-if="contact.hours">服务时间：{{ contact.hours }}</div>
        <div>© 2026 商城</div>
      </div>
      <div class="footer-right">
        <div class="footer-kefu-title">添加客服微信，获取专属服务</div>
        <div class="footer-kefu-box">
          <div class="footer-kefu-qr">
            <template v-if="contact.qr">
              <img :src="contact.qr" alt="客服微信二维码" class="footer-kefu-qr-img" />
            </template>
            <template v-else>
              客服微信二维码
            </template>
          </div>
          <div class="footer-kefu-text">
            <div>扫码添加客服微信</div>
            <div class="footer-kefu-sub">咨询下单、售后问题都可以找我们</div>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getServiceList } from '@/api/service'
import { getProductList, type ProductItem } from '@/api/product'
import { addToCart } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import { getBanners, getContactConfig, getHomeModules, type BannerItem, type ContactConfig } from '@/api/settings'

const router = useRouter()
const userStore = useUserStore()
const banners = ref<BannerItem[]>([])
const entrances = ref([
  { name: '上门取件', icon: '🚚', path: '/home/user/service' },
  { name: '自送到店', icon: '🏪', path: '/home/user/service' },
  { name: '商城', icon: '🧴', path: '/home/user/product' },
  { name: '购物车', icon: '🛒', path: '/home/user/cart' },
  { name: '附近门店', icon: '📍', path: '/home/user/store' },
])
const hotServices = ref<any[]>([])
const defaultProducts: ProductItem[] = [
  {
    id: 1,
    name: '浓缩洗衣液',
    price: 39,
    image: 'https://picsum.photos/seed/detergent/400/300',
    description: '高效去污，温和不伤衣，日常衣物清洗必备。',
  },
  {
    id: 2,
    name: '衣物护理剂',
    price: 29,
    image: 'https://picsum.photos/seed/conditioner/400/300',
    description: '柔顺护衣，减少静电，让衣物柔软舒适。',
  },
  {
    id: 3,
    name: '去渍剂',
    price: 19,
    image: 'https://picsum.photos/seed/stain/400/300',
    description: '针对顽固污渍设计，局部预处理效果更佳。',
  },
  {
    id: 4,
    name: '洗衣袋',
    price: 15,
    image: 'https://picsum.photos/seed/bag/400/300',
    description: '保护衣物不变形，机洗更安心。',
  },
]
const products = ref<ProductItem[]>(defaultProducts)
const contact = ref<ContactConfig>({
  phone: '',
  hours: '',
  qr: '',
})
const defaultBanners: BannerItem[] = [
  {
    image: '/banners/dry-clean-blue.svg',
    title: '专业干洗 洁净如新',
    subtitle: '专业设备 · 精细护理 · 上门取送',
    link: '/home/user/service',
    sortOrder: 0,
    enabled: true,
  },
  {
    image: '/banners/laundry-green.svg',
    title: '绿色洗护 呵护健康',
    subtitle: '天然配方 · 温和洁净 · 呵护全家',
    link: '/home/user/product',
    sortOrder: 1,
    enabled: true,
  },
  {
    image: '/banners/pickup-orange.svg',
    title: '一键下单 上门取送',
    subtitle: '足不出户 · 轻松享受 · 省时省力',
    link: '/home/user/service',
    sortOrder: 2,
    enabled: true,
  },
]

const productDetailVisible = ref(false)
const currentProduct = ref<ProductItem | null>(null)

function goTo(path: string) {
  router.push(path)
}

function openProductDetail(p: ProductItem) {
  currentProduct.value = p
  productDetailVisible.value = true
}

function goProductDetail(id: number) {
  router.push(`/home/user/product/${id}`)
}

function addCart(item: ProductItem) {
  if (!userStore.token) {
    ElMessage.warning('请先登录')
    router.push('/home/login')
    return
  }
  addToCart('PRODUCT', item.id, undefined, 1)
    .then(() => {
      ElMessage.success('已加入购物车')
    })
    .catch((e: any) => {
      const status = e?.response?.status
      const msg =
        e?.response?.data?.message ||
        (status === 404
          ? '购物车接口未就绪，请重启后端'
          : status === 401
          ? '请先登录'
          : status === 500
          ? '服务器错误，请确认已执行 database 脚本并重启后端'
          : '加入失败')
      ElMessage.error(msg)
    })
}

function onBannerClick(b: BannerItem) {
  const link = b?.link?.trim()
  if (!link) return
  if (link.startsWith('http://') || link.startsWith('https://')) {
    window.open(link, '_blank')
  } else {
    router.push(link)
  }
}

// 首页「热门干洗服务」「推荐商品」：优先使用系统设置中的动态配置；未配置时退回前 4 条
onMounted(async () => {
  let hasHomeModulesProducts = false
  try {
    const data = await getHomeModules()
    if (data?.hotServices?.length) hotServices.value = data.hotServices
    if (data?.recommendProducts?.length) {
      products.value = data.recommendProducts
      hasHomeModulesProducts = true
    }
  } catch (_) {}
  if (hotServices.value.length === 0) {
    try {
      const list = await getServiceList()
      hotServices.value = list.slice(0, 4)
    } catch (_) {}
  }
  if (!hasHomeModulesProducts) {
    try {
      const list = await getProductList()
      if (list?.length) products.value = list.slice(0, 4)
    } catch (_) {}
    if (products.value.length === 0) products.value = [...defaultProducts]
  }
  try {
    const bs = await getBanners()
    if (Array.isArray(bs) && bs.length) {
      banners.value = bs.map((b: any) => ({
        ...b,
        link: b && b.link != null && String(b.link).trim() !== '' ? String(b.link).trim() : '',
      }))
    } else {
      banners.value = defaultBanners
    }
  } catch (_) {
    banners.value = defaultBanners
  }
  try {
    contact.value = await getContactConfig()
  } catch (_) {}
})
</script>

<style scoped>
.home-page { padding-bottom: 24px; }
.banner {
  margin: 0 auto 24px;
  border-radius: 8px;
  overflow: hidden;
  max-width: 1100px; /* 控制轮播整体左右宽度 */
}
.banner-item {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ffffff;
  cursor: pointer;
}
.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover; /* 填满整个区域，视觉上更大 */
  display: block;
}
.banner-text { text-align: center; color: #fff; }
.banner-text h2 { font-size: 32px; margin-bottom: 12px; }
.banner-text p { margin-bottom: 20px; opacity: 0.9; }
.banner-btn { border-radius: 20px; padding: 10px 28px; }
.entrances, .section { background: #fff; border-radius: 8px; padding: 24px; margin-bottom: 16px; }
.section-title { margin-bottom: 16px; font-size: 22px; color: #303133; }
.entrance-card { cursor: pointer; text-align: center; }
.entrance-icon { font-size: 40px; margin-bottom: 8px; }
.entrance-name { font-size: 20px; }
.service-card, .product-card { cursor: pointer; }
.service-name, .product-name { font-weight: 500; margin-bottom: 8px; }
.service-price, .product-price { color: #ff4d4f; font-weight: bold; margin-bottom: 8px; }

.product-img-wrap {
  width: 100%;
  aspect-ratio: 4/3;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f7fa;
  margin-bottom: 12px;
}
.product-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.product-img-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: 600;
  color: #c0c4cc;
}
.detail-dialog .detail-img {
  width: 100%;
  height: 200px;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f7fa;
  margin-bottom: 12px;
}
.detail-dialog .detail-img img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}
.detail-img-ph {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
}
.detail-name {
  font-size: 22px;
  font-weight: 600;
  margin-bottom: 8px;
}
.detail-price {
  font-size: 26px;
  color: #ff4d4f;
  font-weight: bold;
  margin-bottom: 12px;
}
.detail-desc {
  font-size: 18px;
  color: #606266;
  margin-bottom: 16px;
  line-height: 1.5;
}
.detail-actions {
  display: flex;
  gap: 12px;
}
.footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32px;
  color: #909399;
  font-size: 18px;
  background: #fff;
  border-radius: 8px;
}
.footer-left div {
  margin-bottom: 8px;
}
.footer-right {
  text-align: left;
}
.footer-kefu-title {
  font-size: 18px;
  margin-bottom: 8px;
  color: #606266;
}
.footer-kefu-box {
  display: flex;
  align-items: center;
  gap: 10px;
}
.footer-kefu-qr {
  width: 72px;
  height: 72px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  color: #909399;
  text-align: center;
  padding: 4px;
}
.footer-kefu-qr-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 4px;
}
.footer-kefu-text {
  font-size: 18px;
  color: #606266;
}
.footer-kefu-sub {
  color: #909399;
  margin-top: 4px;
}
</style>
