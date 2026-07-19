<template>
  <el-card shadow="hover" class="user-card">
    <template #header>
      <div class="card-header">
        <div class="title-wrap">
          <span class="title">用户列表</span>
          <span class="subtitle">支持按用户名 / 姓名 / 手机号 / 角色 / 状态快速筛选</span>
        </div>
        <span class="total-text">共 {{ list.length }} 人</span>
      </div>
    </template>

    <!-- 筛选区域 -->
    <el-form :inline="true" :model="query" class="filter-form">
      <el-form-item label="关键字">
        <el-input v-model="query.keyword" placeholder="输入用户名/姓名/手机号" clearable />
      </el-form-item>
      <el-form-item label="角色">
        <el-select v-model="query.role" placeholder="全部角色" clearable style="width: 140px">
          <el-option label="普通用户" value="USER" />
          <el-option label="普通管理员" value="ADMIN" />
          <el-option label="超级管理员" value="SUPPERADMIN" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" placeholder="全部状态" clearable style="width: 120px">
          <el-option label="正常" :value="1" />
          <el-option label="禁用" :value="0" />
        </el-select>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="filteredList" stripe border>
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="realName" label="姓名" width="100" />
      <el-table-column prop="phone" label="手机号" width="120" />
      <el-table-column prop="role" label="角色" width="120">
        <template #default="{ row }">
          <el-tag :type="roleTagType(row.role)" size="small">{{ roleText(row.role) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">{{ row.status === 1 ? '正常' : '禁用' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link @click="openDetail(row)">详情</el-button>
          <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无用户" />

    <!-- 用户详情弹窗 -->
    <el-dialog v-model="detailVisible" title="用户详情" width="480px">
      <template v-if="currentUser">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="用户ID">{{ currentUser.id }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{ currentUser.username }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ currentUser.realName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ currentUser.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="角色">{{ roleText(currentUser.role) }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ currentUser.status === 1 ? '正常' : '禁用' }}</el-descriptions-item>
          <el-descriptions-item label="注册时间">{{ formatTime(currentUser.createdAt) }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ formatTime(currentUser.updatedAt) }}</el-descriptions-item>
        </el-descriptions>
      </template>
    </el-dialog>

    <!-- 编辑用户弹窗 -->
    <el-dialog v-model="editVisible" title="编辑用户" width="440px" @close="resetForm">
      <el-form :model="form" label-width="80px">
        <el-form-item label="用户名">
          <el-input v-model="form.username" disabled />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="form.realName" placeholder="姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.phone" placeholder="手机号" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.role" placeholder="角色" style="width: 100%" :disabled="!isSupperAdmin">
            <el-option label="普通用户" value="USER" />
            <el-option label="普通管理员" value="ADMIN" />
            <el-option v-if="isSupperAdmin" label="超级管理员" value="SUPPERADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
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
import { getUserList, updateUser, type UserItem } from '@/api/user'
import { useUserStore } from '@/stores/user'

const list = ref<UserItem[]>([])
const loading = ref(false)

// 查询条件
const query = reactive<{
  keyword: string
  role: string | ''
  status: number | ''  // 1 正常 0 禁用
}>({
  keyword: '',
  role: '',
  status: '',
})

// 过滤后的展示列表
const filteredList = computed(() =>
  list.value.filter((u) => {
    if (query.keyword) {
      const kw = query.keyword.trim()
      const hitUsername = !!u.username?.includes(kw)
      const hitRealName = !!u.realName?.includes(kw)
      const hitPhone = !!u.phone?.includes(kw)
      if (!hitUsername && !hitRealName && !hitPhone) return false
    }
    if (query.role && u.role !== query.role) return false
    // 仅当 status 是数字（0/1）时才按状态过滤
    if (typeof query.status === 'number' && u.status !== query.status) return false
    return true
  })
)

const userStore = useUserStore()
const isSupperAdmin = computed(() => userStore.user?.role === 'SUPPERADMIN')

onMounted(() => {
  loadList()
})
function loadList() {
  loading.value = true
  getUserList()
    .then((data) => { list.value = data ?? [] })
    .catch(() => { list.value = [] })
    .finally(() => { loading.value = false })
}

const editVisible = ref(false)
const submitLoading = ref(false)
const form = reactive({
  id: 0,
  username: '',
  realName: '',
  phone: '',
  role: 'USER',
  status: 1,
})
function resetForm() {
  form.id = 0
  form.username = ''
  form.realName = ''
  form.phone = ''
  form.role = 'USER'
  form.status = 1
}
function openEdit(row: UserItem) {
  form.id = row.id
  form.username = row.username ?? ''
  form.realName = row.realName ?? ''
  form.phone = row.phone ?? ''
  form.role = row.role ?? 'USER'
  form.status = row.status ?? 1
  editVisible.value = true
}

// 详情弹窗
const detailVisible = ref(false)
const currentUser = ref<UserItem | null>(null)
function formatTime(val: string | undefined): string {
  if (!val) return '-'
  return val.replace('T', ' ').slice(0, 19)
}
function openDetail(row: UserItem) {
  currentUser.value = row
  detailVisible.value = true
}
function submitEdit() {
  submitLoading.value = true
  updateUser(form.id, {
    realName: form.realName || undefined,
    phone: form.phone || undefined,
    role: form.role,
    status: form.status,
  })
    .then(() => {
      ElMessage.success('保存成功')
      editVisible.value = false
      loadList()
    })
    .catch(() => ElMessage.error('保存失败'))
    .finally(() => { submitLoading.value = false })
}

function roleText(role: string) {
  const map: Record<string, string> = {
    USER: '普通用户',
    ADMIN: '普通管理员',
    SUPPERADMIN: '超级管理员',
  }
  return map[role] || role || '普通用户'
}

function roleTagType(role: string) {
  const map: Record<string, string> = {
    USER: 'info',
    ADMIN: 'success',
    SUPPERADMIN: 'warning',
  }
  return map[role] || 'info'
}
</script>

<style scoped>
.user-card {
  border-radius: 10px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.title-wrap {
  display: flex;
  flex-direction: column;
}
.title {
  font-size: 22px;
  font-weight: 600;
}
.subtitle {
  font-size: 18px;
  color: #909399;
}
.total-text {
  font-size: 18px;
  color: #909399;
}
.filter-form {
  margin: 8px 0 12px;
}
</style>
