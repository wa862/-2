<template>
  <div class="comment-section">
    <div class="header-row">
      <div class="title">用户评价</div>
      <div class="header-actions">
        <el-button v-if="actionText" type="primary" plain size="small" @click="$emit('action')">
          {{ actionText }}
        </el-button>
        <el-button
          v-else-if="collapsed"
          type="primary"
          plain
          size="small"
          @click="goToAll"
        >
          {{ viewAllText }}
        </el-button>
      </div>
    </div>

    <el-empty v-if="!loading && list.length === 0" description="暂无评价" :image-size="72" />
    <div v-else class="list">
      <div v-for="c in visibleList" :key="c.id" class="item">
        <div class="top">
          <div class="user">{{ c.username || '匿名用户' }}</div>
          <el-rate :model-value="c.score" disabled :max="5" />
          <div class="time">{{ fmt(c.createdAt) }}</div>
        </div>
        <div class="content">{{ c.content || '默认好评' }}</div>
        <div v-if="c.reply" class="reply">
          <div class="reply-title">商家回复</div>
          <div class="reply-content">{{ c.reply }}</div>
          <div v-if="c.replyTime" class="reply-time">{{ fmt(c.replyTime) }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, withDefaults } from 'vue'
import { useRouter } from 'vue-router'
import { getCommentList, type CommentItem } from '@/api/comment'

const props = withDefaults(defineProps<{
  actionText?: string
  targetType: 'SERVICE' | 'PRODUCT'
  targetId: number
  /** 折叠模式：只展示少量评价，并提供“查看全部”跳转 */
  collapsed?: boolean
  /** 折叠模式下预览数量 */
  previewCount?: number
  /** 拉取最多条数（在全量页可设大一点） */
  maxItems?: number
  /** 查看全部按钮文案 */
  viewAllText?: string
}>(), {
  collapsed: false,
  previewCount: 1,
  maxItems: 10,
  viewAllText: '查看全部评价',
})

const router = useRouter()
defineEmits<{ (e: 'action'): void }>()

const loading = ref(false)
const list = ref<CommentItem[]>([])

const visibleList = computed(() => {
  if (!props.collapsed) return list.value
  return list.value.slice(0, props.previewCount)
})

function fmt(v: string | undefined) {
  if (!v) return ''
  return v.replace('T', ' ').slice(0, 19)
}

async function load() {
  loading.value = true
  try {
    const data = await getCommentList(props.targetType, props.targetId)
    list.value = (data || []).slice(0, props.maxItems)
  } finally {
    loading.value = false
  }
}

function goToAll() {
  router.push({
    name: 'CommentList',
    params: { targetType: props.targetType, targetId: String(props.targetId) },
  })
}

onMounted(load)
</script>

<style scoped>
.comment-section { margin-top: 14px; }
.header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.title { font-size: 20px; font-weight: 600; color: #303133; }
.header-actions { display: flex; align-items: center; gap: 8px; }
.list { display: flex; flex-direction: column; gap: 12px; }
.item { background: #fff; border: 1px solid #ebeef5; border-radius: 10px; padding: 12px; }
.top { display: flex; align-items: center; gap: 10px; }
.user { font-weight: 600; color: #303133; }
.time { margin-left: auto; color: #909399; font-size: 18px; }
.content { margin-top: 8px; color: #606266; line-height: 1.6; white-space: pre-wrap; }
.reply { margin-top: 10px; padding: 10px; border-radius: 8px; background: #f5f7fa; border: 1px dashed #dcdfe6; }
.reply-title { font-size: 18px; font-weight: 600; color: #303133; margin-bottom: 4px; }
.reply-content { color: #606266; line-height: 1.6; white-space: pre-wrap; }
.reply-time { margin-top: 6px; color: #909399; font-size: 18px; }
</style>

