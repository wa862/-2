<template>
  <view
    v-if="!isAiPage"
    class="ai-float"
    :style="{ left: `${position.x}px`, top: `${position.y}px` }"
    @touchstart.stop="onTouchStart"
    @touchmove.stop.prevent="onTouchMove"
    @touchend.stop="onTouchEnd"
  >
    <view class="ai-icon">
      <text class="ai-face">AI</text>
      <view class="ai-dot"></view>
    </view>
    <text class="ai-label">客服</text>
  </view>
</template>

<script setup lang="ts">
import { computed, reactive } from 'vue'

const FLOAT_SIZE = 56
const EDGE_GAP = 12
const CLICK_MOVE_LIMIT = 6

const systemInfo = uni.getSystemInfoSync()
const position = reactive({
  x: Math.max(EDGE_GAP, systemInfo.windowWidth - FLOAT_SIZE - 14),
  y: Math.max(EDGE_GAP, systemInfo.windowHeight - FLOAT_SIZE - 90),
})
const touchState = reactive({
  startX: 0,
  startY: 0,
  offsetX: 0,
  offsetY: 0,
  moved: false,
})

const isAiPage = computed(() => {
  const pages = getCurrentPages()
  const current = pages[pages.length - 1]
  return !!current && current.route === 'pages/ai/assistant'
})

function goAi() {
  uni.navigateTo({ url: '/pages/ai/assistant' })
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max)
}

function onTouchStart(e: TouchEvent) {
  const touch = e.touches[0]
  if (!touch) return
  touchState.startX = touch.clientX
  touchState.startY = touch.clientY
  touchState.offsetX = touch.clientX - position.x
  touchState.offsetY = touch.clientY - position.y
  touchState.moved = false
}

function onTouchMove(e: TouchEvent) {
  const touch = e.touches[0]
  if (!touch) return
  const moveX = Math.abs(touch.clientX - touchState.startX)
  const moveY = Math.abs(touch.clientY - touchState.startY)
  if (moveX > CLICK_MOVE_LIMIT || moveY > CLICK_MOVE_LIMIT) touchState.moved = true
  position.x = clamp(touch.clientX - touchState.offsetX, EDGE_GAP, systemInfo.windowWidth - FLOAT_SIZE - EDGE_GAP)
  position.y = clamp(touch.clientY - touchState.offsetY, EDGE_GAP, systemInfo.windowHeight - FLOAT_SIZE - EDGE_GAP)
}

function onTouchEnd() {
  if (!touchState.moved) goAi()
}
</script>

<style scoped lang="scss">
.ai-float {
  position: fixed;
  z-index: 999;
  width: 112rpx;
  height: 112rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #55b8ff 0%, #2f78ff 100%);
  box-shadow: 0 14rpx 34rpx rgba(47, 120, 255, 0.32);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #fff;
  touch-action: none;
}
.ai-float::before {
  content: '';
  position: absolute;
  inset: 8rpx;
  border-radius: 50%;
  border: 2rpx solid rgba(255,255,255,0.34);
}
.ai-icon {
  position: relative;
  z-index: 1;
  width: 48rpx;
  height: 42rpx;
  border-radius: 18rpx 18rpx 18rpx 8rpx;
  background: rgba(255,255,255,0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 4rpx;
}
.ai-face {
  color: #2f78ff;
  font-size: 20rpx;
  font-weight: 800;
  line-height: 1;
}
.ai-dot {
  position: absolute;
  right: -5rpx;
  top: -5rpx;
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: #39d86f;
  border: 3rpx solid #fff;
}
.ai-label {
  position: relative;
  z-index: 1;
  font-size: 22rpx;
  font-weight: 700;
  line-height: 1;
}
</style>
