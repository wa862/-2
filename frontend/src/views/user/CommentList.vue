<template>
  <div class="comment-list-page">
    <el-button link type="primary" @click="router.back()" class="back">← 返回</el-button>
    <CommentSection
      :target-type="targetType"
      :target-id="targetId"
      :collapsed="false"
      :max-items="50"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CommentSection from '@/components/CommentSection.vue'

const route = useRoute()
const router = useRouter()

const targetType = computed(() => {
  const raw = route.params.targetType
  return raw === 'PRODUCT' ? 'PRODUCT' : 'SERVICE'
})

const targetId = computed(() => Number(route.params.targetId))
</script>

<style scoped>
.comment-list-page { background: #fff; padding: 24px; border-radius: 8px; }
.back { margin-bottom: 10px; }
</style>

