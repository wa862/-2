<template>
  <el-popover placement="bottom" :width="320" trigger="click">
    <template #reference>
      <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="bell-badge">
        <el-button :icon="Bell" circle class="bell-btn" />
      </el-badge>
    </template>
    <div class="notification-list">
      <div v-if="!list.length" class="empty">暂无消息</div>
      <div
        v-for="item in list"
        :key="item.id"
        class="item"
        :class="{ unread: item.isRead === 0 }"
        @click="markRead(item.id)"
      >
        <div class="title">{{ item.title }}</div>
        <div class="content">{{ item.content }}</div>
        <div class="time">{{ item.createdAt }}</div>
      </div>
    </div>
  </el-popover>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Bell } from '@element-plus/icons-vue'
import { getNotificationList, getUnreadCount, markRead as apiMarkRead } from '@/api/notification'

const list = ref<any[]>([])
const unreadCount = ref(0)

async function load() {
  try {
    const [data, countRes] = await Promise.all([
      getNotificationList(0, 10),
      getUnreadCount(),
    ])
    list.value = data ?? []
    unreadCount.value = countRes?.count ?? 0
  } catch (_) {
    list.value = []
    unreadCount.value = 0
  }
}

function markRead(id: number) {
  apiMarkRead(id).then(() => load())
}

onMounted(load)
</script>

<style scoped>
.bell-badge { margin-right: 4px; }
.bell-btn {
  width: 44px;
  height: 44px;
  font-size: 22px;
}
.bell-badge :deep(.el-badge__content) {
  min-width: 20px;
  height: 20px;
  line-height: 20px;
  font-size: 13px;
  padding: 0 6px;
}
.notification-list { max-height: 360px; overflow-y: auto; }
.empty { text-align: center; color: #909399; padding: 24px; }
.item { padding: 12px; border-bottom: 1px solid #f0f0f0; cursor: pointer; }
.item.unread { background: #ecf5ff; }
.item .title { font-weight: 500; }
.item .content { font-size: 18px; color: #606266; margin-top: 4px; }
.item .time { font-size: 18px; color: #909399; margin-top: 4px; }
</style>
