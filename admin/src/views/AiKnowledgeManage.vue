<template>
  <el-card shadow="hover">
    <template #header>
      <span>AI知识库</span>
      <el-button type="primary" size="small" style="float: right" @click="openCreate">新增知识</el-button>
    </template>

    <el-form :inline="true" class="filter-form">
      <el-form-item label="关键词">
        <el-input v-model="keyword" placeholder="搜索问题、答案、标签" clearable @keyup.enter="loadList" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="loadList">查询</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="list" stripe>
      <el-table-column prop="question" label="问题" min-width="180" show-overflow-tooltip />
      <el-table-column prop="category" label="分类" width="120" />
      <el-table-column prop="keywords" label="关键词" min-width="180" show-overflow-tooltip />
      <el-table-column prop="hitCount" label="命中" width="80" />
      <el-table-column prop="status" label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
          <el-button type="danger" link @click="remove(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无知识库数据" />

    <el-dialog v-model="visible" :title="form.id ? '编辑知识' : '新增知识'" width="640px" @close="resetForm">
      <el-form :model="form" label-width="86px">
        <el-form-item label="问题" required>
          <el-input v-model="form.question" placeholder="例如：羽绒服干洗需要多久？" />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" placeholder="如：价格规格、洗护周期、售后服务" />
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="form.keywords" placeholder="多个关键词用逗号分隔" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="答案" required>
          <el-input v-model="form.answer" type="textarea" :rows="6" placeholder="输入客服标准回复" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="submit">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { createKnowledge, deleteKnowledge, getKnowledgeList, updateKnowledge, type AiKnowledgeItem } from '@/api/ai'

const list = ref<AiKnowledgeItem[]>([])
const loading = ref(false)
const submitLoading = ref(false)
const visible = ref(false)
const keyword = ref('')
const form = reactive({
  id: 0,
  question: '',
  answer: '',
  category: '干洗咨询',
  keywords: '',
  status: 1,
  sortOrder: 0,
})

onMounted(loadList)

function loadList() {
  loading.value = true
  getKnowledgeList(keyword.value, true)
    .then((data) => { list.value = data ?? [] })
    .catch(() => { list.value = [] })
    .finally(() => { loading.value = false })
}

function resetForm() {
  form.id = 0
  form.question = ''
  form.answer = ''
  form.category = '干洗咨询'
  form.keywords = ''
  form.status = 1
  form.sortOrder = 0
}

function openCreate() {
  resetForm()
  visible.value = true
}

function openEdit(row: AiKnowledgeItem) {
  form.id = row.id
  form.question = row.question || ''
  form.answer = row.answer || ''
  form.category = row.category || '干洗咨询'
  form.keywords = row.keywords || ''
  form.status = row.status ?? 1
  form.sortOrder = row.sortOrder ?? 0
  visible.value = true
}

function submit() {
  if (!form.question.trim() || !form.answer.trim()) {
    ElMessage.warning('请填写问题和答案')
    return
  }
  submitLoading.value = true
  const payload = { ...form, question: form.question.trim(), answer: form.answer.trim() }
  const req = form.id ? updateKnowledge(form.id, payload) : createKnowledge(payload)
  req
    .then(() => {
      ElMessage.success('保存成功')
      visible.value = false
      loadList()
    })
    .catch(() => ElMessage.error('保存失败'))
    .finally(() => { submitLoading.value = false })
}

function remove(row: AiKnowledgeItem) {
  ElMessageBox.confirm(`确认删除知识：${row.question}？`, '提示', { type: 'warning' })
    .then(() => deleteKnowledge(row.id))
    .then(() => {
      ElMessage.success('删除成功')
      loadList()
    })
    .catch(() => {})
}
</script>

<style scoped>
.filter-form { margin-bottom: 12px; }
</style>
