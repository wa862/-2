<template>
  <el-card shadow="hover">
    <template #header>
      <span>服务列表</span>
      <el-button type="primary" size="small" style="float: right" @click="openCreate">新增服务</el-button>
    </template>
    <el-form :inline="true" :model="query" class="filter-form">
      <el-form-item label="服务名称">
        <el-input v-model="query.name" placeholder="输入名称" clearable />
      </el-form-item>
      <el-form-item label="分类">
        <el-select v-model="query.category" placeholder="全部分类" clearable style="width: 160px">
          <el-option v-for="c in categoryOptions" :key="c" :label="c" :value="c" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" placeholder="全部" clearable style="width: 120px">
          <el-option label="上架" :value="1" />
          <el-option label="下架" :value="0" />
        </el-select>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="filteredList" stripe>
      <el-table-column prop="name" label="服务名称" />
      <el-table-column prop="price" label="起步价" width="100">
        <template #default="{ row }">¥{{ Number(row.price || 0).toFixed(0) }}</template>
      </el-table-column>
      <el-table-column prop="category" label="分类" width="100" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">{{ row.status === 1 ? '上架' : '下架' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无服务数据" />

    <el-dialog v-model="editVisible" title="编辑服务" width="500px" @close="resetForm">
      <el-form :model="form" label-width="80px">
        <el-form-item label="名称" required>
          <el-input v-model="form.name" placeholder="服务名称" />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" placeholder="如：衣物" />
        </el-form-item>
        <el-form-item label="规格价格" required>
          <el-table :data="form.specOptions" size="small" border>
            <el-table-column label="规格名">
              <template #default="{ row }">
                <el-input v-model="row.name" placeholder="如：短款/长款" />
              </template>
            </el-table-column>
            <el-table-column label="价格(元)" width="140">
              <template #default="{ row }">
                <el-input-number v-model="row.price" :min="0" :precision="2" style="width: 120px" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="90">
              <template #default="{ $index }">
                <el-button type="danger" link @click="removeSpecRow($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div style="margin-top: 8px; display: flex; gap: 8px; align-items: center">
            <el-button size="small" type="primary" plain @click="addSpecRow">+ 添加规格</el-button>
            <span style="font-size: 18px; color: #909399">会自动以最低价作为列表“起步价”展示</span>
          </div>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">上架</el-radio>
            <el-radio :label="0">下架</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" rows="2" placeholder="服务描述" />
        </el-form-item>
        <el-form-item label="洗衣周期">
          <el-input v-model="form.cycle" placeholder="如：5-7天" />
        </el-form-item>
        <el-form-item label="图片">
          <el-upload
            class="upload"
            action="/api/upload/service-image"
            :show-file-list="false"
            :before-upload="beforeImageUpload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
          >
            <el-button type="primary" plain>上传图片</el-button>
          </el-upload>
          <div v-if="form.image" class="img-preview">
            <img :src="form.image" alt="服务图片" />
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getServiceList, createService, updateService, type ServiceItem } from '@/api/service'

const list = ref<ServiceItem[]>([])
const loading = ref(false)
const query = reactive<{ name: string; category: string; status: number | '' }>({
  name: '',
  category: '',
  status: '',
})
const categoryOptions = computed(() =>
  Array.from(new Set(list.value.map((s) => s.category).filter((x): x is string => !!x)))
)
const filteredList = computed(() =>
  list.value.filter((s) => {
    if (query.name && !s.name?.includes(query.name.trim())) return false
    if (query.category && s.category !== query.category) return false
    // 只有在状态是数字 0/1 时才按状态过滤；清空为 undefined/null/'' 都视为“全部”
    if (typeof query.status === 'number' && s.status !== query.status) return false
    return true
  })
)

onMounted(() => {
  loadList()
})
function loadList() {
  loading.value = true
  getServiceList(true)
    .then((data) => { list.value = data ?? [] })
    .catch(() => { list.value = [] })
    .finally(() => { loading.value = false })
}

const editVisible = ref(false)
const submitLoading = ref(false)
const form = reactive({
  id: 0,
  name: '',
  category: '',
  status: 1,
  description: '',
  specOptions: [] as Array<{ name: string; price: number }>,
  cycle: '',
  image: '',
})

function parseSpecsToOptions(raw: any): Array<{ name: string; price: number }> {
  const s = typeof raw === 'string' ? raw : ''
  const parts = s.split(/[;,，]/).map((x) => x.trim()).filter(Boolean)
  const list = parts.map((p) => {
    const [name, priceStr] = p.split('|').map((x) => (x || '').trim())
    const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
    if (!name || Number.isNaN(price)) return null
    return { name, price }
  }).filter((x): x is { name: string; price: number } => !!x)
  return list.length ? list : [{ name: '默认', price: 0 }]
}

function optionsToSpecs(list: Array<{ name: string; price: number }>): string {
  return (list || [])
    .map((x) => ({ name: (x.name || '').trim(), price: Number(x.price) }))
    .filter((x) => x.name && !Number.isNaN(x.price) && x.price > 0)
    .map((x) => `${x.name}|${x.price}`)
    .join(';')
}

function addSpecRow() {
  form.specOptions.push({ name: '', price: 0 })
}

function removeSpecRow(idx: number) {
  form.specOptions.splice(idx, 1)
  if (form.specOptions.length === 0) form.specOptions.push({ name: '默认', price: 0 })
}

function minSpecPrice(): number {
  const prices = (form.specOptions || [])
    .map((x) => Number(x.price))
    .filter((p) => !Number.isNaN(p) && p > 0)
  if (!prices.length) return 0
  return Math.min(...prices)
}

function resetForm() {
  form.id = 0
  form.name = ''
  form.category = ''
  form.status = 1
  form.description = ''
  form.specOptions = [{ name: '默认', price: 0 }]
  form.cycle = ''
  form.image = ''
}
function openCreate() {
  resetForm()
  editVisible.value = true
}
function openEdit(row: ServiceItem) {
  form.id = row.id
  form.name = row.name ?? ''
  form.category = row.category ?? ''
  form.status = row.status ?? 1
  form.description = row.description ?? ''
  form.specOptions = parseSpecsToOptions((row as any).specs)
  // 若历史数据没有规格价格，则用基础价补到默认规格里
  const base = Number(row.price) || 0
  if (form.specOptions.length === 1 && form.specOptions[0].name === '默认' && (form.specOptions[0].price || 0) <= 0 && base > 0) {
    form.specOptions[0].price = base
  }
  form.cycle = (row as any).cycle ?? ''
  form.image = row.image ?? ''
  editVisible.value = true
}
function submitEdit() {
  if (!form.name?.trim()) {
    ElMessage.warning('请填写服务名称')
    return
  }
  const specsStr = optionsToSpecs(form.specOptions)
  if (!specsStr) {
    ElMessage.warning('请至少配置一个规格，并填写大于 0 的价格')
    return
  }
  submitLoading.value = true
  const payload = {
    name: form.name.trim(),
    category: form.category || undefined,
    // 后端仍需要 price 字段：这里自动取规格最低价作为展示/兜底价
    price: minSpecPrice(),
    status: form.status,
    description: form.description || undefined,
    specs: specsStr,
    cycle: form.cycle || undefined,
    image: form.image || undefined,
  }
  const req = form.id ? updateService(form.id, payload) : createService(payload)
  req
    .then(() => {
      ElMessage.success('保存成功')
      editVisible.value = false
      loadList()
    })
    .catch(() => ElMessage.error('保存失败'))
    .finally(() => { submitLoading.value = false })
}

function beforeImageUpload(file: File) {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isGIF = file.type === 'image/gif'
  const isImage = isJPG || isPNG || isGIF
  const isLt2M = file.size / 1024 / 1024 < 2
  if (!isImage) {
    ElMessage.error('上传图片只能是 JPG/PNG/GIF 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('上传图片大小不能超过 2MB!')
    return false
  }
  return true
}
function handleUploadSuccess(res: any) {
  if (res && res.url) {
    form.image = res.url
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error('图片上传失败')
  }
}
function handleUploadError(err: any) {
  const msg = err?.response?.data?.message || '图片上传失败，请检查后端上传接口'
  ElMessage.error(msg)
}
</script>

<style scoped>
.filter-form {
  margin-bottom: 12px;
}
.upload {
  margin-right: 12px;
}
.img-preview img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}
</style>
