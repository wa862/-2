<template>
  <view class="comment-section">
    <view class="header">
      <text class="title">用户评价</text>
      <text v-if="comments.length > previewCount" class="more" @click="goAll">查看全部</text>
    </view>
    <view v-if="loading" class="loading">加载中...</view>
    <view v-else-if="!displayList.length" class="empty">暂无评价</view>
    <view v-else>
      <view v-for="c in displayList" :key="c.id" class="comment-item">
        <view class="top">
          <text class="user">{{ c.username || '用户' }}</text>
          <text class="score">{{ '★'.repeat(c.score) }}</text>
        </view>
        <text class="content">{{ c.content || '用户未填写评价内容' }}</text>
        <text v-if="c.reply" class="reply">商家回复：{{ c.reply }}</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, withDefaults } from 'vue'
import { getCommentList, type CommentItem } from '@/api/comment'

const props = withDefaults(defineProps<{
  targetType: 'SERVICE' | 'PRODUCT'
  targetId: number
  previewCount?: number
}>(), {
  previewCount: 2,
})

const loading = ref(false)
const comments = ref<CommentItem[]>([])
const previewCount = computed(() => props.previewCount === undefined || props.previewCount === null ? 2 : props.previewCount)
const displayList = computed(() => comments.value.slice(0, previewCount.value))

function goAll() {
  uni.navigateTo({
    url: `/pages/comment/list?targetType=${props.targetType}&targetId=${props.targetId}`,
  })
}

onMounted(async () => {
  loading.value = true
  try {
    comments.value = await getCommentList(props.targetType, props.targetId)
  } catch {
    comments.value = []
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
.comment-section {
  margin-top: 24rpx;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}
.title {
  font-size: 30rpx;
  font-weight: 600;
}
.more {
  font-size: 24rpx;
  color: #409eff;
}
.comment-item {
  padding: 20rpx 0;
  border-bottom: 1rpx solid #ebeef5;
}
.top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8rpx;
}
.user {
  font-size: 26rpx;
  color: #606266;
}
.score {
  color: #f7ba2a;
  font-size: 24rpx;
}
.content {
  font-size: 28rpx;
  color: #303133;
  line-height: 1.6;
}
.reply {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  color: #909399;
  background: #f5f7fa;
  padding: 12rpx;
  border-radius: 8rpx;
}
.loading, .empty {
  color: #909399;
  font-size: 26rpx;
}
</style>
