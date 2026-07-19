<template>
  <el-card shadow="hover">
    <template #header>
      <span>门店列表</span>
      <el-button type="primary" size="small" style="float: right" @click="openCreate">新增门店</el-button>
    </template>
    <el-form :inline="true" :model="query" class="filter-form">
      <el-form-item label="门店名称">
        <el-input v-model="query.name" placeholder="输入门店名称" clearable />
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="filteredList" stripe>
      <el-table-column prop="name" label="门店名称" />
      <el-table-column prop="address" label="地址" />
      <el-table-column prop="phone" label="电话" width="120" />
      <el-table-column prop="businessHours" label="营业时间" width="140" />
      <el-table-column label="操作" width="120">
        <template #default="{ row }">
          <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无门店" />

    <el-dialog v-model="editVisible" :title="form.id ? '编辑门店' : '新增门店'" width="460px" @close="resetForm">
      <el-form :model="form" label-width="80px">
        <el-form-item label="门店名称" required>
          <el-input v-model="form.name" placeholder="请输入门店名称" />
        </el-form-item>
        <el-form-item label="地址">
          <el-input v-model="form.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" placeholder="联系电话" />
        </el-form-item>
        <el-form-item label="营业时间">
          <el-input v-model="form.businessHours" placeholder="如：9:00-21:00" />
        </el-form-item>
        <el-form-item label="排序值">
          <el-input v-model.number="form.sortOrder" type="number" placeholder="数字越小越靠前" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getStoreList, deleteStore, createStore, updateStore, type StoreItem } from '@/api/store'

const list = ref<StoreItem[]>([])
const loading = ref(false)
const query = reactive<{ name: string }>({ name: '' })
const filteredList = computed(() =>
  list.value.filter((s) => {
    if (query.name && !s.name?.includes(query.name.trim())) return false
    return true
  })
)

onMounted(() => {
  loadList()
})
function loadList() {
  loading.value = true
  getStoreList(true)
    .then((data) => { list.value = data ?? [] })
    .catch(() => { list.value = [] })
    .finally(() => { loading.value = false })
}

function handleDelete(row: StoreItem) {
  ElMessageBox.confirm(`确定删除门店「${row.name}」吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      return deleteStore(row.id)
    })
    .then(() => {
      ElMessage.success('已删除')
      loadList()
    })
    .catch((e) => {
      if (e !== 'cancel') ElMessage.error(e?.message || '删除失败')
    })
}

const editVisible = ref(false)
const saving = ref(false)
const form = reactive<Partial<StoreItem>>({
  id: undefined,
  name: '',
  address: '',
  phone: '',
  businessHours: '',
  sortOrder: 0,
})

function resetForm() {
  form.id = undefined
  form.name = ''
  form.address = ''
  form.phone = ''
  form.businessHours = ''
  form.sortOrder = 0
}

function openCreate() {
  resetForm()
  editVisible.value = true
}

function openEdit(row: StoreItem) {
  form.id = row.id
  form.name = row.name
  form.address = row.address
  form.phone = row.phone
  form.businessHours = row.businessHours
  form.sortOrder = row.sortOrder ?? 0
  editVisible.value = true
}

function submitEdit() {
  if (!form.name || !form.name.trim()) {
    ElMessage.warning('请填写门店名称')
    return
  }
  saving.value = true
  const payload = {
    name: form.name.trim(),
    address: form.address || undefined,
    phone: form.phone || undefined,
    businessHours: form.businessHours || undefined,
    sortOrder: form.sortOrder ?? 0,
  }
  const req = form.id ? updateStore(form.id, payload) : createStore(payload)
  req
    .then(() => {
      ElMessage.success('保存成功')
      editVisible.value = false
      loadList()
    })
    .catch(() => ElMessage.error('保存失败'))
    .finally(() => {
      saving.value = false
    })
}
</script>

<style scoped>
.filter-form {
  margin-bottom: 12px;
}
</style>
