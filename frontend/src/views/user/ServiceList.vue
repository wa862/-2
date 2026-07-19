<template>
  <div class="service-page">
    <section class="section" v-if="hotServices.length">
      <div class="section-header">
        <h3 class="section-title">热门干洗服务</h3>
      </div>
      <el-row :gutter="20">
        <el-col v-for="item in hotServices" :key="item.id" :span="8">
          <div class="aesthetic-card" @click="openDetail(item)">
            <div class="card-img-wrap">
              <div class="card-img" :class="{ [imageClass(item)]: !item.image }">
                <img v-if="item.image" :src="item.image" :alt="item.name" @error="onImgError" />
              </div>
              <span class="hot-badge">热门</span>
            </div>
            <div class="card-body">
              <div class="card-title-row">
                <span class="card-title">{{ item.name }}</span>
                <span class="card-cert">✓</span>
              </div>
              <div class="card-rating">4.9分 <span class="card-review">(1234评价)</span></div>
              <div class="card-price">¥{{ listMinPrice(item).toFixed(0) }}/件<span v-if="parsedSpecs(item).length">起</span></div>
              <div class="card-member">会员再享9折</div>
              <div class="card-features">
                <span v-for="(f, i) in getFeatures(item)" :key="i" class="feature-tag">{{ f }}</span>
              </div>
              <div class="card-footer">
                <span class="card-remark" @click.stop="openRemark(item)">
                  <el-icon><EditPen /></el-icon> 选填备注
                </span>
                <el-button type="primary" class="card-book-btn" @click.stop="goOrder(item)">立即预约</el-button>
              </div>
            </div>
            <div class="card-cart-float" @click.stop="addCart(item)" title="加入购物车">
              <el-icon :size="20"><ShoppingCart /></el-icon>
            </div>
          </div>
        </el-col>
      </el-row>
    </section>
    <section id="all-services" class="section">
      <div class="main-layout">
        <aside class="main-left">
          <h3 class="section-title small-title">服务分类</h3>
          <div class="category-list category-vertical">
            <div
              v-for="c in categories"
              :key="c"
              class="category-item"
              :class="{ active: activeCategory === c }"
              @click="activeCategory = c"
            >
              {{ c }}
            </div>
          </div>
        </aside>
        <div class="main-right">
          <div class="section-header">
            <h3 class="section-title">探索全部洗护服务</h3>
            <div class="section-search">
              <el-input
                v-model="keyword"
                placeholder="搜索干洗服务名称，如：羽绒服、衬衫、大衣"
                clearable
              >
                <template #append>
                  <el-button type="primary">搜索</el-button>
                </template>
              </el-input>
            </div>
          </div>
          <el-row :gutter="20">
            <el-col v-for="(item, idx) in filteredServices" :key="item.id" :span="8">
              <div class="aesthetic-card" @click="openDetail(item)">
                <div class="card-img-wrap">
                  <div class="card-img" :class="{ [imageClass(item)]: !item.image }">
                    <img v-if="item.image" :src="item.image" :alt="item.name" @error="onImgError" />
                  </div>
                  <span v-if="idx < 3" class="hot-badge">热门</span>
                </div>
                <div class="card-body">
                  <div class="card-title-row">
                    <span class="card-title">{{ item.name }}</span>
                    <span class="card-cert">✓</span>
                  </div>
                  <div class="card-rating">4.9分 <span class="card-review">(1234评价)</span></div>
                  <div class="card-price">¥{{ listMinPrice(item).toFixed(0) }}/件<span v-if="parsedSpecs(item).length">起</span></div>
                  <div class="card-member">会员再享9折</div>
                  <div class="card-features">
                    <span v-for="(f, i) in getFeatures(item)" :key="i" class="feature-tag">{{ f }}</span>
                  </div>
                  <div class="card-footer">
                    <span class="card-remark" @click.stop="openRemark(item)">
                      <el-icon><EditPen /></el-icon> 选填备注
                    </span>
                    <el-button type="primary" class="card-book-btn" @click.stop="goOrder(item)">立即预约</el-button>
                  </div>
                </div>
                <div class="card-cart-float" @click.stop="addCart(item)" title="加入购物车">
                  <el-icon :size="20"><ShoppingCart /></el-icon>
                </div>
              </div>
            </el-col>
          </el-row>
          <el-empty v-if="!filteredServices.length" description="暂无相关服务" />
        </div>
      </div>
    </section>

    <!-- 弹出详情卡片：生活美学风格 -->
    <el-dialog v-model="detailVisible" width="420px" class="aesthetic-dialog" :show-close="true">
      <template v-if="detailItem">
        <div class="aesthetic-popup">
          <div class="popup-img-wrap">
            <div class="popup-img" :class="{ [imageClass(detailItem)]: !detailItem.image }">
              <img v-if="detailItem.image" :src="detailItem.image" :alt="detailItem.name" />
            </div>
            <span class="hot-badge">热门</span>
          </div>
          <div class="popup-body">
            <div class="card-title-row">
              <span class="card-title">{{ detailItem.name }}</span>
              <span class="card-cert">✓</span>
            </div>
            <div class="card-rating">4.9分 <span class="card-review">(1234评价)</span></div>
            <div class="card-price">
              ¥{{ priceForService(detailItem).toFixed(0) }}/件
              <span v-if="parsedSpecs(detailItem).length" class="spec-label">
                （{{ specNameByServiceId[detailItem.id] || parsedSpecs(detailItem)[0]?.name || '规格' }}）
              </span>
            </div>
            <div class="card-member">会员再享9折</div>
            <div class="card-features">
              <span v-for="(f, i) in getFeatures(detailItem)" :key="i" class="feature-tag">{{ f }}</span>
            </div>
            <div v-if="parsedSpecs(detailItem).length" class="spec-options">
              <span class="spec-title">请选择规格：</span>
              <el-radio-group
                :model-value="specNameByServiceId[detailItem.id] ?? parsedSpecs(detailItem)[0]?.name ?? ''"
                @update:model-value="(v: string) => setDetailSpec(v)"
              >
                <el-radio
                  v-for="opt in parsedSpecs(detailItem)"
                  :key="opt.name"
                  :label="opt.name"
                >
                  {{ opt.name }}（¥{{ opt.price }}）
                </el-radio>
              </el-radio-group>
            </div>
            <div v-if="detailItem.cycle" class="cycle-text">预计洗护周期：{{ detailItem.cycle }}</div>
            <div class="card-footer">
              <span class="card-remark" @click="openRemark(detailItem)">
                <el-icon><EditPen /></el-icon> 选填备注
              </span>
              <el-button type="primary" class="card-book-btn" @click="goOrder(detailItem); detailVisible = false">立即预约</el-button>
            </div>
            <el-button class="popup-cart-btn" @click="addCart(detailItem); detailVisible = false">
              <el-icon><ShoppingCart /></el-icon> 加入购物车
            </el-button>
          </div>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { EditPen, ShoppingCart } from '@element-plus/icons-vue'
import { getServiceList } from '@/api/service'
import { addToCart } from '@/api/cart'
import { useUserStore } from '@/stores/user'
import type { ServiceItem } from '@/api/service'

const route = useRoute()
const router = useRouter()
const store = useUserStore()
const allServices = ref<ServiceItem[]>([])
/** 每个服务单独记住选中的规格，避免多个弹窗共用一个 v-model 导致价格不刷新 */
const specNameByServiceId = reactive<Record<number, string>>({})
const activeCategory = ref('全部')
const keyword = ref('')
const detailVisible = ref(false)
const detailItem = ref<ServiceItem | null>(null)

const categories = ['全部', '西装', '羽绒服', '大衣', '日常衣物', '鞋类', '箱包/奢侈品']

function setDetailSpec(name: string) {
  const item = detailItem.value
  if (item) specNameByServiceId[item.id] = name
}

function openDetail(item: ServiceItem) {
  // 详情页承载“真实评价展示”，此处直接跳转到真正详情路由
  router.push({ path: `/home/user/service/${item.id}` })
}

function goOrder(item: ServiceItem) {
  const specs = parsedSpecs(item)
  const specName =
    specs.length > 0 ? specNameByServiceId[item.id] || specs[0].name : ''
  const q: Record<string, string> = { serviceId: String(item.id) }
  if (specName) q.specName = specName
  router.push({ path: '/home/user/order/create', query: q })
}

function addCart(item: ServiceItem) {
  if (!store.token) {
    ElMessage.warning('请先登录')
    router.push('/home/login')
    return
  }
  const specs = parsedSpecs(item)
  const specName = specs.length > 0 ? (specNameByServiceId[item.id] || specs[0].name) : undefined
  addToCart('SERVICE', undefined, item.id, 1, specName).then(() => {
    ElMessage.success('已加入购物车')
  }).catch((e: any) => {
    const status = e?.response?.status
    const msg = e?.response?.data?.message || (status === 404 ? '购物车接口未就绪，请重启后端' : status === 401 ? '请先登录' : status === 500 ? '服务器错误，请确认已执行 database 脚本并重启后端' : '加入失败')
    ElMessage.error(msg)
  })
}

function matchCategory(item: ServiceItem, cat: string) {
  const name = item.name || ''
  if (cat === '全部') return true
  if (cat === '西装') return name.includes('西装')
  if (cat === '羽绒服') return name.includes('羽绒服')
  if (cat === '大衣') return name.includes('大衣') || name.includes('呢子')
  if (cat === '日常衣物') return ['衬衫', 'T恤', '连衣裙', '牛仔裤', '围巾', '运动服'].some((k) => name.includes(k))
  if (cat === '鞋类') return ['鞋', '靴'].some((k) => name.includes(k))
  if (cat === '箱包/奢侈品') return ['羊绒', '羊毛', '皮衣', '毛毯', '背包', '帽子', '手套'].some((k) => name.includes(k))
  return true
}

const filteredServices = computed(() => {
  let list = allServices.value
  if (activeCategory.value && activeCategory.value !== '全部') {
    list = list.filter((item) => matchCategory(item, activeCategory.value))
  }
  const kw = keyword.value.trim()
  if (kw) {
    list = list.filter((s) => (s.name || '').toLowerCase().includes(kw.toLowerCase()))
  }
  return list
})

const hotServices = computed(() => {
  const names = ['羽绒服', '大衣', '衬衫']
  const picked = allServices.value.filter(
    (s) => !s.name.includes('西装') && names.some((n) => s.name.includes(n))
  )
  if (picked.length) return picked.slice(0, 3)
  return allServices.value.filter((s) => !s.name.includes('西装')).slice(0, 3)
})

type SpecOption = { name: string; price: number }
function parsedSpecs(item: ServiceItem): SpecOption[] {
  const raw = (item as any).specs as string | undefined
  if (!raw) return []
  return raw
    .split(/[;,，]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => {
      const [name, priceStr] = part.split('|').map((s) => s.trim())
      const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
      if (!name || !price || isNaN(price)) return null
      return { name, price }
    })
    .filter((x): x is SpecOption => !!x)
}

function priceForService(item: ServiceItem): number {
  const specs = parsedSpecs(item)
  if (!specs.length) return Number(item.price) || 0
  const name = specNameByServiceId[item.id] || specs[0].name
  const current = specs.find((s) => s.name === name) || specs[0]
  return current.price
}

function listMinPrice(item: ServiceItem): number {
  const specs = parsedSpecs(item)
  if (!specs.length) return Number(item.price) || 0
  let min = Number.POSITIVE_INFINITY
  for (const s of specs) {
    if (typeof s.price === 'number' && !Number.isNaN(s.price) && s.price > 0) {
      min = Math.min(min, s.price)
    }
  }
  return min === Number.POSITIVE_INFINITY ? (Number(item.price) || 0) : min
}

function imageClass(item: ServiceItem) {
  const name = (item.name || '').toLowerCase()
  if (name.includes('西装')) return 'img-suit'
  if (name.includes('羽绒')) return 'img-jacket'
  if (name.includes('大衣') || name.includes('呢子')) return 'img-coat'
  if (name.includes('衬衫') || name.includes('t恤')) return 'img-shirt'
  if (name.includes('鞋') || name.includes('靴')) return 'img-shoes'
  return 'img-default'
}

function defaultDesc(item: ServiceItem) {
  const name = item.name || ''
  if (name.includes('西装')) return '商务西装 · 蒸汽熨烫定型'
  if (name.includes('羽绒服')) return '羽绒服蓬松焕新，恢复保暖力'
  if (name.includes('大衣') || name.includes('呢子')) return '呢子/大衣精洗定型，收纳更安心'
  if (['衬衫', 'T恤'].some((k) => name.includes(k))) return '日常衣物清洗熨烫，通勤更体面'
  if (['鞋', '靴'].some((k) => name.includes(k))) return '鞋靴深度清洗护理，除味杀菌'
  return '专业清洗，贴心护理'
}

const FEATURE_TAGS = ['蓬松还原', '除菌除螨', '去渍修复', '防水涂层养护'] as const
function getFeatures(item: ServiceItem): string[] {
  return [...FEATURE_TAGS]
}

function openRemark(item: ServiceItem) {
  ElMessage.info('选填备注功能：可在预约时填写')
}

function onImgError(e: Event) {
  const el = e.target as HTMLImageElement
  if (el) el.style.display = 'none'
}

onMounted(async () => {
  try {
    allServices.value = await getServiceList()
    keyword.value = (route.query.keyword as string) || ''
  } catch (_) {}
})
</script>

<style scoped>
.service-page { padding: 8px 0 24px; }
.section {
  background: #ffffff;
  border-radius: 12px;
  padding: 18px 20px 20px;
  margin-bottom: 16px;
}
.section-header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; justify-content: space-between; }
.section-title { font-size: 22px; color: #303133; }
.keyword-tip { font-size: 18px; color: #909399; }
.section-search { width: 320px; }
.main-layout { display: flex; gap: 24px; }
.main-left {
  width: 220px;
  border-right: 1px solid #f0f0f0;
  padding-right: 16px;
  position: sticky;
  /* 顶部预留一段距离，避免被导航栏遮挡 */
  top: 80px;
  align-self: flex-start;
  background: #ffffff;
  z-index: 1;
}
.main-right { flex: 1; padding-left: 8px; }
.small-title { font-size: 22px; margin-bottom: 8px; }
.category-list { display: flex; flex-wrap: wrap; gap: 8px; }
.category-vertical { flex-direction: column; }
.category-item {
  cursor: pointer;
  padding: 8px 16px;
  font-size: 19px;
  color: #606266;
  background: #ffffff;
  border: 1px solid #dcdfe6;
  border-radius: 999px;
  transition: all 0.2s;
}
.category-item.active { background: #409eff; color: #fff; border-color: #409eff; }
.category-item:hover { border-color: #409eff; color: #409eff; }

/* 生活美学卡片 */
.aesthetic-card {
  position: relative;
  margin-top: 12px;
  border-radius: 12px;
  overflow: hidden;
  background: #fff;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: all 0.25s ease;
}
.aesthetic-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.12);
}
.card-img-wrap {
  position: relative;
  width: 100%;
  height: 200px;
  overflow: hidden;
  background: #F0E9E2;
}
.card-img {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.card-img img { width: 100%; height: 100%; object-fit: contain; display: block; }
.card-img-wrap .hot-badge {
  position: absolute;
  right: 10px;
  bottom: 10px;
  padding: 4px 10px;
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  background: #e74c3c;
  border-radius: 4px;
}
.img-suit { background: linear-gradient(135deg, #2c3e50, #4a6fa5); }
.img-jacket { background: linear-gradient(135deg, #8b4513, #d2691e); }
.img-coat { background: linear-gradient(135deg, #4a5568, #718096); }
.img-shirt { background: linear-gradient(135deg, #3182ce, #63b3ed); }
.img-shoes { background: linear-gradient(135deg, #2d3748, #4a5568); }
.img-default { background: linear-gradient(135deg, #409eff, #66b1ff); }

.card-body { padding: 14px 16px 16px; }
.card-title-row { display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }
.card-title { font-size: 20px; font-weight: 600; color: #303133; }
.card-cert { color: #52c41a; font-size: 18px; font-weight: bold; }
.card-rating { font-size: 18px; color: #606266; margin-bottom: 6px; }
.card-review { color: #909399; font-size: 18px; }
.card-price { font-size: 26px; font-weight: 700; color: #e74c3c; margin-bottom: 2px; }
.card-member { font-size: 18px; color: #909399; margin-bottom: 10px; }
.card-features {
  display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;
}
.feature-tag {
  padding: 6px 12px;
  font-size: 18px;
  color: #606266;
  background: #f0f2f5;
  border-radius: 8px;
}
.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}
.card-remark {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 18px;
  color: #909399;
  cursor: pointer;
}
.card-remark:hover { color: #409eff; }
.card-book-btn { flex: 1; border-radius: 20px; font-weight: 500; }
.card-cart-float {
  position: absolute;
  right: 12px;
  bottom: 12px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border-radius: 50%;
  box-shadow: 0 2px 12px rgba(0,0,0,0.15);
  color: #409eff;
  cursor: pointer;
  transition: all 0.2s;
}
.card-cart-float:hover { background: #409eff; color: #fff; transform: scale(1.08); }

/* 弹出详情：生活美学 */
.aesthetic-dialog :deep(.el-dialog__header) { padding: 16px 20px 0; }
.aesthetic-dialog :deep(.el-dialog__body) { padding: 0 20px 20px; }
.aesthetic-popup { border-radius: 12px; overflow: hidden; }
.popup-img-wrap {
  position: relative;
  height: 240px;
  overflow: hidden;
  background: #F0E9E2;
  border-radius: 12px 12px 0 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.popup-img { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }
.popup-img img { width: 100%; height: 100%; object-fit: contain; display: block; }
.popup-img-wrap .hot-badge {
  position: absolute;
  right: 10px;
  bottom: 10px;
  padding: 4px 10px;
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  background: #e74c3c;
  border-radius: 4px;
}
.popup-body { padding: 14px 0 12px; }
.popup-body .card-title-row { margin-bottom: 6px; }
.popup-body .card-rating { margin-bottom: 6px; }
.popup-body .card-price { margin-bottom: 2px; }
.popup-body .card-member { margin-bottom: 10px; }
.popup-body .card-features { margin-bottom: 12px; }
.popup-body .card-footer { margin-bottom: 12px; }
.popup-cart-btn {
  width: 100%;
  border-radius: 20px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}
</style>
