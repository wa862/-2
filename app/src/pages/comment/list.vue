<template>
  <view class="page">
    <view v-if="loading" class="empty-wrap">加载中...</view>
    <view v-else-if="!comments.length" class="empty-wrap">暂无评价</view>
    <view v-for="c in comments" :key="c.id" class="card comment">
      <view class="top">
        <text>{{ c.username || '用户' }}</text>
        <text class="stars">{{ '★'.repeat(c.score) }}</text>
      </view>
      <text class="content">{{ c.content || '用户未填写评价内容' }}</text>
      <text class="time">{{ formatTime(c.createdAt) }}</text>
      <text v-if="c.reply" class="reply">商家回复：{{ c.reply }}</text>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCommentList, type CommentItem } from '@/api/comment'
import { formatTime } from '@/utils'

const targetType = ref<'SERVICE' | 'PRODUCT'>('SERVICE')
const targetId = ref(0)
const loading = ref(true)
const comments = ref<CommentItem[]>([])

onLoad((q) => {
  targetType.value = ((q && q.targetType) as 'SERVICE' | 'PRODUCT') || 'SERVICE'
  targetId.value = Number((q && q.targetId) || 0)
})

onMounted(async () => {
  if (!targetId.value) { loading.value = false; return }
  try { comments.value = await getCommentList(targetType.value, targetId.value) } catch {}
  loading.value = false
})
</script>

<style scoped lang="scss">
.page { padding: 20rpx; }
.top { display: flex; justify-content: space-between; margin-bottom: 12rpx; }
.stars { color: #f7ba2a; }
.content { display: block; line-height: 1.6; margin-bottom: 8rpx; }
.time { display: block; font-size: 24rpx; color: #909399; }
.reply { display: block; margin-top: 12rpx; padding: 12rpx; background: #f5f7fa; border-radius: 8rpx; font-size: 26rpx; color: #606266; }
</style>
