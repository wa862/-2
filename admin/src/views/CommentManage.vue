<template>
  <el-card shadow="hover">
    <template #header>用户评价（订单评论）</template>
    <el-form :inline="true" :model="query" class="filter-form">
      <el-form-item label="用户名">
        <el-input v-model="query.username" placeholder="输入用户名" clearable />
      </el-form-item>
      <el-form-item label="订单编号">
        <el-input v-model="query.orderNo" placeholder="输入订单编号" clearable />
      </el-form-item>
    </el-form>
    <el-table v-loading="loading" :data="filteredList" stripe>
      <el-table-column prop="username" label="用户" width="100" />
      <el-table-column prop="orderNo" label="订单编号" width="180">
        <template #default="{ row }">
          {{ row.orderNo }}
        </template>
      </el-table-column>
      <el-table-column prop="content" label="评价内容" min-width="200" show-overflow-tooltip />
      <el-table-column prop="score" label="评分" width="80" align="center">
        <template #default="{ row }">{{ row.score }} 分</template>
      </el-table-column>
      <el-table-column prop="createdAt" label="时间" width="165" show-overflow-tooltip />
      <el-table-column label="操作" width="80">
        <template #default="{ row }">
          <el-button type="primary" link @click="openReply(row)">回复</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-empty v-if="!loading && !list.length" description="暂无评论" />

    <el-dialog v-model="replyVisible" title="回复评论" width="400px">
      <el-form :model="replyForm" label-width="80px">
        <el-form-item label="评论内容">
          <el-input v-model="replyForm.content" type="textarea" rows="3" readonly />
        </el-form-item>
        <el-form-item label="回复内容" required>
          <el-input v-model="replyForm.reply" type="textarea" rows="3" placeholder="请输入回复内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="replyVisible = false">取消</el-button>
        <el-button type="primary" :loading="replyLoading" @click="submitReply">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getCommentList, replyComment, type CommentItem } from '@/api/comment'

const list = ref<CommentItem[]>([])
const loading = ref(false)
const query = reactive<{ username: string; orderNo: string }>({ username: '', orderNo: '' })

const replyVisible = ref(false)
const replyLoading = ref(false)
const replyForm = reactive({
  id: 0,
  content: '',
  reply: '',
})
const currentComment = ref<CommentItem | null>(null)
const filteredList = computed(() =>
  list.value.filter((c) => {
    if (query.username && !c.username?.includes(query.username.trim())) return false
    if (query.orderNo) {
      const kw = query.orderNo.trim()
      const byNo = c.orderNo && c.orderNo.includes(kw)
      const byId = String(c.orderId) === kw
      if (!byNo && !byId) return false
    }
    return true
  })
)

onMounted(() => {
  loadList()
})
function loadList() {
  loading.value = true
  getCommentList()
    .then((data) => { list.value = data ?? [] })
    .catch(() => {
      list.value = []
      ElMessage.error('评论列表加载失败，请检查接口或网络')
    })
    .finally(() => { loading.value = false })
}

function openReply(row: CommentItem) {
  currentComment.value = row
  replyForm.id = row.id
  replyForm.content = row.content ?? ''
  replyForm.reply = row.reply ?? ''
  replyVisible.value = true
}

function submitReply() {
  if (!replyForm.reply?.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  replyLoading.value = true
  replyComment(replyForm.id, replyForm.reply.trim())
    .then(() => {
      ElMessage.success('回复成功')
      replyVisible.value = false
      loadList()
    })
    .catch((e: any) => {
      ElMessage.error(e?.response?.data?.message || '回复失败')
    })
    .finally(() => { replyLoading.value = false })
}
</script>

<style scoped>
.filter-form {
  margin-bottom: 12px;
}
</style>
