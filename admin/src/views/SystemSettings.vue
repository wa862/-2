<template>
  <div class="settings-page">
    <el-card shadow="hover" class="block-card">
      <template #header>首页轮播图设计修改</template>
      <p class="section-desc">
        用于设计和调整顾客端首页顶部的轮播图（Banner），可设置标题、副标题、跳转链接等内容，方便做活动和运营位展示。
        当前示例仅为前端展示，保存后端落库可按论文或实际需求自行扩展。
      </p>
      <el-table :data="banners" border style="width: 100%; margin-top: 12px">
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="image" label="图片" width="220">
          <template #default="{ row }">
            <div class="banner-image-cell">
              <el-upload
                class="upload"
                action="/api/upload/product-image"
                :show-file-list="false"
                :before-upload="beforeBannerUpload"
                :on-success="(res: any) => handleBannerUploadSuccess(row, res)"
              >
                <el-button type="primary" plain size="small">上传图片</el-button>
              </el-upload>
              <div v-if="row.image" class="img-preview">
                <img :src="row.image" alt="轮播图" />
              </div>
            </div>
            <el-input
              v-model="row.image"
              size="small"
              placeholder="也可以直接粘贴图片 URL"
              style="margin-top: 4px"
            />
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="160">
          <template #default="{ row }">
            <el-input v-model="row.title" placeholder="如：专业干洗 · 上门取件" />
          </template>
        </el-table-column>
        <el-table-column prop="subtitle" label="副标题" min-width="200">
          <template #default="{ row }">
            <el-input v-model="row.subtitle" placeholder="如：新用户立减 20 元" />
          </template>
        </el-table-column>
        <el-table-column prop="link" label="跳转链接" min-width="200">
          <template #default="{ row }">
            <el-input v-model="row.link" placeholder="如：/home/user/service 或商品详情链接" />
          </template>
        </el-table-column>
      </el-table>
      <div class="banner-actions">
        <el-button type="primary" @click="save">保存轮播配置（示例）</el-button>
        <span class="tips-text small">顾客端首页可根据实际接入的接口，动态读取这里配置的轮播图信息。</span>
      </div>
    </el-card>

    <!-- 客服联系方式配置 -->
    <el-card shadow="hover" class="block-card">
      <template #header>客服联系方式设置</template>
      <p class="section-desc">
        设置顾客端展示的客服电话与微信二维码，方便用户通过电话咨询或扫码添加客服微信。
      </p>
      <el-form :model="contact" label-width="90px" class="contact-form">
        <el-form-item label="客服电话">
          <el-input v-model="contact.phone" placeholder="如：400-xxx-xxxx 或 13100000000" />
        </el-form-item>
        <el-form-item label="服务时间">
          <el-input v-model="contact.hours" placeholder="如：09:00-21:00（工作日）" />
        </el-form-item>
        <el-form-item label="微信客服二维码">
          <div class="qr-wrap">
            <el-upload
              class="upload"
              action="/api/upload/product-image"
              :show-file-list="false"
              :before-upload="beforeBannerUpload"
              :on-success="handleQrUploadSuccess"
            >
              <el-button type="primary" plain>上传二维码图片</el-button>
            </el-upload>
            <div v-if="contact.qr" class="qr-preview">
              <img :src="contact.qr" alt="客服微信二维码" />
            </div>
            <el-input
              v-model="contact.qr"
              placeholder="也可以直接粘贴二维码图片 URL"
              style="margin-top: 8px"
            />
          </div>
        </el-form-item>
      </el-form>
      <div class="banner-actions">
        <el-button type="primary" @click="saveContact">保存客服配置（示例）</el-button>
        <span class="tips-text small">顾客端首页或“联系我们”区域可展示上述电话与微信二维码。</span>
      </div>
    </el-card>

    <!-- 首页热门服务与推荐商品 -->
    <el-card shadow="hover" class="block-card">
      <template #header>首页「热门干洗服务」与「推荐商品」</template>
      <p class="section-desc">
        选择在顾客端首页展示的热门干洗服务和推荐商品，顺序与多选结果一致。未配置时首页将展示全部上架服务/商品的前 4 条。
      </p>
      <el-form label-width="140px" class="home-modules-form">
        <el-form-item label="热门干洗服务">
          <el-select
            v-model="homeHotServiceIds"
            multiple
            filterable
            placeholder="请选择要展示的服务（可多选，顺序即展示顺序）"
            style="width: 100%"
            value-key="id"
          >
            <el-option
              v-for="s in homeAllServices"
              :key="s.id"
              :label="`${s.name} ¥${s.price}`"
              :value="s.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="推荐商品">
          <el-select
            v-model="homeRecommendProductIds"
            multiple
            filterable
            placeholder="请选择要展示的商品（可多选，顺序即展示顺序）"
            style="width: 100%"
            value-key="id"
          >
            <el-option
              v-for="p in homeAllProducts"
              :key="p.id"
              :label="`${p.name} ¥${p.price}`"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <div class="banner-actions">
        <el-button type="primary" @click="saveHomeModules">保存首页模块配置</el-button>
        <span class="tips-text small">顾客端首页将按此处配置动态展示热门服务和推荐商品。</span>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getBanners,
  saveBanners,
  getContactConfig,
  saveContactConfig,
  getHomeModuleConfig,
  saveHomeModuleConfig,
  type BannerItem,
  type ContactConfig,
} from '@/api/settings'

const banners = ref<BannerItem[]>([])

const contact = ref<ContactConfig>({
  phone: '',
  hours: '',
  qr: '',
})

const homeHotServiceIds = ref<number[]>([])
const homeRecommendProductIds = ref<number[]>([])
const homeAllServices = ref<{ id: number; name?: string; price?: number }[]>([])
const homeAllProducts = ref<{ id: number; name?: string; price?: number }[]>([])

function beforeBannerUpload(file: File) {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2
  if (!isImage) {
    ElMessage.error('仅支持上传图片文件')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
    return false
  }
  return true
}

function handleBannerUploadSuccess(row: any, res: any) {
  if (res && res.url) {
    row.image = res.url
    ElMessage.success('轮播图上传成功')
  } else {
    ElMessage.error('轮播图上传失败')
  }
}

function handleQrUploadSuccess(res: any) {
  if (res && res.url) {
    contact.value.qr = res.url
    ElMessage.success('二维码上传成功')
  } else {
    ElMessage.error('二维码上传失败')
  }
}

function onQrChange() {
  ElMessage.info('这里只是示例入口，如需真正保存二维码，请对接后端上传与配置接口。')
}

function save() {
  saveBanners(
    banners.value.map((b, idx) => ({
      ...b,
      sortOrder: b.sortOrder ?? idx,
      enabled: b.enabled ?? true,
    }))
  )
    .then(() => {
      ElMessage.success('轮播配置已保存')
    })
    .catch((e: any) => {
      const msg = e?.response?.data?.message || '轮播配置保存失败，请确认已执行 database/add_settings_tables.sql 并重启后端'
      ElMessage.error(msg)
    })
}

function saveContact() {
  saveContactConfig(contact.value)
    .then(() => {
      ElMessage.success('客服配置保存成功')
    })
    .catch((e: any) => {
      const msg = e?.response?.data?.message || '客服配置保存失败，请确认已执行 database/add_settings_tables.sql 并重启后端'
      ElMessage.error(msg)
    })
}

function saveHomeModules() {
  saveHomeModuleConfig({
    hotServiceIds: homeHotServiceIds.value,
    recommendProductIds: homeRecommendProductIds.value,
  })
    .then(() => {
      ElMessage.success('首页模块配置已保存')
    })
    .catch((e: any) => {
      const msg = e?.response?.data?.message || '首页模块配置保存失败，请确认已执行 database/add_home_config.sql 并重启后端'
      ElMessage.error(msg)
    })
}

onMounted(async () => {
  try {
    banners.value = await getBanners()
  } catch (e: any) {
    const msg = e?.response?.data?.message || '轮播图配置加载失败'
    ElMessage.error(msg)
  }
  try {
    contact.value = await getContactConfig()
  } catch (e: any) {
    const msg = e?.response?.data?.message || '客服配置加载失败'
    ElMessage.error(msg)
  }
  try {
    const res = await getHomeModuleConfig()
    homeHotServiceIds.value = res.hotServiceIds || []
    homeRecommendProductIds.value = res.recommendProductIds || []
    homeAllServices.value = res.allServices || []
    homeAllProducts.value = res.allProducts || []
  } catch (e: any) {
    const msg = e?.response?.data?.message || '首页模块配置加载失败'
    ElMessage.error(msg)
  }
})
</script>

<style scoped>
.settings-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.block-card {
  margin-bottom: 4px;
}

.section-desc {
  font-size: 18px;
  color: #606266;
  margin: 0 0 8px;
}

.banner-actions {
  margin-top: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.banner-image-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}
.img-preview img {
  width: 80px;
  height: 40px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}
.qr-wrap {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}
.qr-preview img {
  width: 96px;
  height: 96px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}
.home-modules-form {
  max-width: 560px;
}
</style>
