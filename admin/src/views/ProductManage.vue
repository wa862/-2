<template>
  <el-card shadow="hover">
    <template #header>
      <span>商品列表</span>
      <el-button type="primary" size="small" style="float: right" @click="openCreate">新增商品</el-button>
    </template>
    <el-form :inline="true" :model="query" class="filter-form">
      <el-form-item label="商品名称">
        <el-input v-model="query.name" placeholder="输入名称" clearable />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" placeholder="全部" clearable style="width: 120px">
          <el-option label="上架" :value="1" />
          <el-option label="下架" :value="0" />
        </el-select>
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="filteredList" stripe>
      <el-table-column prop="name" label="商品名称" />
      <el-table-column prop="price" label="价格" width="100" />
      <el-table-column prop="stock" label="库存" width="80" />
      <el-table-column prop="sales" label="销量" width="80" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">{{ row.status === 1 ? '上架' : '下架' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="{ row }">
          <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无商品" />

    <el-dialog v-model="editVisible" title="编辑商品" width="500px" @close="resetForm">
      <el-form :model="form" label-width="80px">
        <el-form-item label="名称" required>
          <el-input v-model="form.name" placeholder="商品名称" />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" placeholder="如：洗衣液" />
        </el-form-item>
        <el-form-item label="品牌">
          <el-input v-model="form.brand" placeholder="商品品牌" />
        </el-form-item>
        <el-form-item label="厂家">
          <el-input v-model="form.manufacturer" placeholder="生产厂家" />
        </el-form-item>
        <el-form-item label="生产日期">
          <el-date-picker v-model="form.productionDate" type="date" placeholder="选择日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="规格">
          <el-input v-model="form.specification" placeholder="如：500ml/瓶" />
        </el-form-item>
        <el-form-item label="价格" required>
          <el-input-number v-model="form.price" :min="0" :precision="2" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="form.stock" :min="0" />
        </el-form-item>
        <el-form-item label="销量">
          <el-input-number v-model="form.sales" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">上架</el-radio>
            <el-radio :label="0">下架</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" rows="2" placeholder="商品描述" />
        </el-form-item>
        <el-form-item label="图片">
          <el-upload
            class="upload"
            action="/api/upload/product-image"
            :show-file-list="false"
            :before-upload="beforeImageUpload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
          >
            <el-button type="primary" plain>上传图片</el-button>
          </el-upload>
          <div v-if="form.image" class="img-preview">
            <img :src="form.image" alt="商品图片" />
          </div>
        </el-form-item>
        <el-form-item label="图片地址">
          <el-input v-model="form.image" placeholder="也可以直接粘贴图片 URL" />
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
import { getProductList, createProduct, updateProduct, type ProductItem } from '@/api/product'

const list = ref<ProductItem[]>([])
const loading = ref(false)
const query = reactive<{ name: string; status: number | '' }>({ name: '', status: '' })
const filteredList = computed(() =>
  list.value.filter((p) => {
    if (query.name && !p.name?.includes(query.name.trim())) return false
    // 同样仅当 status 为数字时才按状态过滤
    if (typeof query.status === 'number' && p.status !== query.status) return false
    return true
  })
)

onMounted(() => {
  loadList()
})
function loadList() {
  loading.value = true
  getProductList(true)
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
  brand: '',
  manufacturer: '',
  productionDate: null,
  specification: '',
  price: 0,
  stock: 0,
  sales: 0,
  status: 1,
  description: '',
  image: '',
})
function resetForm() {
  form.id = 0
  form.name = ''
  form.category = ''
  form.brand = ''
  form.manufacturer = ''
  form.productionDate = null
  form.specification = ''
  form.price = 0
  form.stock = 0
  form.sales = 0
  form.status = 1
  form.description = ''
  form.image = ''
}
function openCreate() {
  resetForm()
  editVisible.value = true
}
function openEdit(row: ProductItem) {
  form.id = row.id
  form.name = row.name ?? ''
  form.category = row.category ?? ''
  form.brand = (row as any).brand ?? ''
  form.manufacturer = (row as any).manufacturer ?? ''
  form.productionDate = (row as any).productionDate ?? null
  form.specification = (row as any).specification ?? ''
  form.price = Number(row.price) ?? 0
  form.stock = row.stock ?? 0
  form.sales = row.sales ?? 0
  form.status = row.status ?? 1
  form.description = row.description ?? ''
  form.image = row.image ?? ''
  editVisible.value = true
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
function submitEdit() {
  if (!form.name?.trim()) {
    ElMessage.warning('请填写商品名称')
    return
  }
  submitLoading.value = true
  const payload = {
    name: form.name.trim(),
    category: form.category || undefined,
    brand: form.brand || undefined,
    manufacturer: form.manufacturer || undefined,
    productionDate: form.productionDate || undefined,
    specification: form.specification || undefined,
    price: form.price,
    stock: form.stock,
    sales: form.sales,
    status: form.status,
    description: form.description || undefined,
    image: form.image || undefined,
  }
  const req = form.id ? updateProduct(form.id, payload) : createProduct(payload)
  req
    .then(() => {
      ElMessage.success('保存成功')
      editVisible.value = false
      loadList()
    })
    .catch(() => ElMessage.error('保存失败'))
    .finally(() => { submitLoading.value = false })
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
