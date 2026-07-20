<template>
  <view class="page">
    <scroll-view class="content-scroll" scroll-y scroll-with-animation :scroll-into-view="lastMessageId">
      <view class="hero-card">
        <view class="hero-copy">
          <text class="hero-title">Hi，我是洗衣优选<text class="blue">AI客服</text></text>
          <text class="hero-subtitle">我可以帮您解答洗护、价格、取送、订单等问题</text>
          <text class="hero-subtitle">24小时在线，随时为您服务</text>
        </view>
        <view class="robot-hero">
          <view class="robot-head">
            <view class="robot-screen">
              <view class="robot-eye"></view>
              <view class="robot-eye"></view>
            </view>
            <view class="robot-ear left"></view>
            <view class="robot-ear right"></view>
          </view>
          <view class="robot-body">AI</view>
        </view>
      </view>

      <view class="guess-card">
        <view class="section-head">
          <view class="star-icon">AI</view>
          <text>猜你喜欢</text>
        </view>
        <view class="question-grid">
          <view
            v-for="item in quickQuestions"
            :key="item.text"
            class="question-item"
            @click="sendQuick(item.text)"
          >
            <view class="question-icon" :class="item.color">{{ item.icon }}</view>
            <text class="question-text">{{ item.text }}</text>
            <text class="arrow">›</text>
          </view>
        </view>
      </view>

      <view class="chat-area">
        <view
          v-for="msg in messages"
          :id="`msg-${msg.id}`"
          :key="msg.id"
          class="message-row"
          :class="msg.role"
        >
          <view v-if="msg.role === 'assistant'" class="avatar">
            <view class="mini-robot-face">
              <view></view>
              <view></view>
            </view>
          </view>
          <view class="bubble">
            <text class="message-text">{{ msg.content }}</text>
            <view v-if="msg.role === 'assistant' && msg.services && msg.services.length" class="service-recommend">
              <view class="recommend-title">为您找到相关服务</view>
              <view
                v-for="service in msg.services"
                :key="service.id"
                class="service-card"
                @click="goOrder(service.id)"
              >
                <view class="service-main">
                  <image v-if="service.image" class="service-image" :src="resolveImageUrl(service.image)" mode="aspectFill" />
                  <view v-else class="service-image service-ph">洗</view>
                  <view class="service-info">
                    <text class="service-name">{{ service.name }}</text>
                    <text class="service-desc">{{ service.cycle || service.category || '专业洗护服务' }}</text>
                    <text class="service-price">¥{{ service.price }}/件起</text>
                  </view>
                </view>
                <view class="order-btn">去下单</view>
              </view>
            </view>
          </view>
        </view>
        <view class="chat-time">{{ currentTime }}</view>
      </view>
    </scroll-view>

    <view class="bottom-panel">
      <view class="input-bar">
      <view class="voice-btn">🎙</view>
      <view class="input-wrap">
        <input
          v-model="question"
          class="question-input"
          maxlength="300"
          placeholder="输入您想咨询的问题..."
          :disabled="loading"
          confirm-type="send"
          @confirm="send"
        />
        <text class="smile">☺</text>
      </view>
      <button class="send-btn" type="primary" :loading="loading" @click="send">发送</button>
      </view>

      <view class="action-grid">
        <view
          v-for="item in actionItems"
          :key="item.title"
          class="action-item"
          @click="goAction(item.path)"
        >
          <view class="action-icon" :class="item.color">{{ item.icon }}</view>
          <text>{{ item.title }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { askAi, type AiChatResponse } from '@/api/ai'
import { getServiceList, type ServiceItem } from '@/api/service'
import { useUserStore } from '@/stores/user'
import { resolveImageUrl } from '@/utils'

type ChatMessage = {
  id: number
  role: 'assistant' | 'user'
  content: string
  source?: AiChatResponse['sourceType']
  services?: ServiceItem[]
}

const quickQuestions = [
  { text: '羽绒服干洗需要多久？', icon: '衣', color: 'blue' },
  { text: '西装怎么收费？', icon: '¥', color: 'orange' },
  { text: '可以上门取衣吗？', icon: '取', color: 'green' },
  { text: '哪些衣物不适合水洗？', icon: '水', color: 'cyan' },
  { text: '衣服洗坏了怎么办？', icon: '保', color: 'purple' },
  { text: '洗护用品商城是什么？', icon: '商', color: 'red' },
]

const actionItems = [
  { title: '预约下单', icon: '约', color: 'blue', path: '/pages/service/list' },
  { title: '价格查询', icon: '价', color: 'orange', path: '/pages/service/list' },
  { title: '取送服务', icon: '送', color: 'green', path: '/pages/service/order-create' },
  { title: '订单查询', icon: '单', color: 'red', path: '/pages/order/list' },
]

const messages = ref<ChatMessage[]>([
  {
    id: Date.now(),
    role: 'assistant',
    content: '你好，我是洗衣优选AI客服。你可以咨询干洗服务、预约下单、价格规格、取送和售后问题。',
    source: 'KNOWLEDGE',
  },
])
const question = ref('')
const loading = ref(false)
const services = ref<ServiceItem[]>([])
const userStore = useUserStore()
const genericServiceWords = ['清洗', '干洗', '洗护', '护理', '服务', '保养', '去污', '除臭', '专业', '日常']
const lastMessageId = computed(() => {
  const last = messages.value[messages.value.length - 1]
  return last ? `msg-${last.id}` : ''
})
const currentTime = computed(() => {
  const now = new Date()
  const h = String(now.getHours()).padStart(2, '0')
  const m = String(now.getMinutes()).padStart(2, '0')
  return `${h}:${m}`
})

function sendQuick(text: string) {
  question.value = text
  send()
}

function goAction(path: string) {
  if (path.includes('/service/list')) {
    uni.switchTab({ url: path })
    return
  }
  uni.navigateTo({ url: path })
}

function goOrder(serviceId: number) {
  uni.navigateTo({ url: `/pages/service/order-create?serviceId=${serviceId}` })
}

function compactText(value?: string) {
  return (value || '').replace(/\s+/g, '').toLowerCase()
}

function serviceCoreName(name: string) {
  return compactText(name)
    .replace(/干洗|清洗|精洗|洗护|护理|保养|翻新|修复|服务/g, '')
}

function containsSpecificTerm(service: ServiceItem, text: string) {
  const haystack = compactText(text)
  const parts = [service.name, service.category, service.specs, service.description]
    .map(compactText)
    .join(' ')
    .split(/[|;；,，、\s]+/)
    .map((part) => part.replace(/\d+(\.\d+)?/g, ''))
    .filter((part) => part.length >= 2 && !genericServiceWords.includes(part))
  return parts.some((part) => haystack.includes(part) || haystack.includes(serviceCoreName(part)))
}

function serviceScore(service: ServiceItem, text: string) {
  const haystack = compactText(text)
  const name = compactText(service.name)
  const core = serviceCoreName(service.name)
  const category = compactText(service.category)
  let score = 0
  if (name && haystack.includes(name)) score += 100
  if (core.length >= 2 && haystack.includes(core)) score += 80
  if (category && haystack.includes(category)) score += 18
  if (containsSpecificTerm(service, text)) score += 24

  const chars = Array.from(new Set(core.split('').filter((ch) => /[\u4e00-\u9fa5a-z0-9]/.test(ch))))
  const hits = chars.filter((ch) => haystack.includes(ch)).length
  if (core.length >= 2 && hits >= Math.min(2, chars.length)) score += hits * 6

  return score
}

function findRelatedServices(text: string) {
  return services.value
    .map((service) => ({ service, score: serviceScore(service, text) }))
    .filter((item) => item.score >= 18)
    .sort((a, b) => b.score - a.score)
    .slice(0, 2)
    .map((item) => item.service)
}

async function loadServices() {
  try {
    const list = await getServiceList()
    services.value = Array.isArray(list) ? list.filter((item) => item.status !== 0) : []
  } catch (e) {
    console.error('[ai] services', e)
  }
}

async function send() {
  const text = question.value.trim()
  if (!text || loading.value) return
  if (!services.value.length) await loadServices()
  messages.value.push({ id: Date.now(), role: 'user', content: text })
  question.value = ''
  loading.value = true
  await nextTick()
  try {
    const res = await askAi(text, userStore.user ? userStore.user.id : undefined)
    const answer = res.answer || '我暂时没有获得答案，请换一种问法试试。'
    messages.value.push({
      id: Date.now() + 1,
      role: 'assistant',
      content: answer,
      source: res.sourceType,
      services: findRelatedServices(text),
    })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || 'AI客服暂时不可用', icon: 'none' })
    messages.value.push({
      id: Date.now() + 2,
      role: 'assistant',
      content: '服务暂时不可用，请稍后再试，或联系门店客服处理紧急问题。',
      source: 'FALLBACK',
      services: findRelatedServices(text),
    })
  } finally {
    loading.value = false
  }
}

onLoad(loadServices)
</script>

<style scoped lang="scss">
.page {
  height: 100vh;
  box-sizing: border-box;
  overflow: hidden;
  background:
    radial-gradient(circle at 50% 46%, rgba(70, 145, 255, 0.16), transparent 48%),
    linear-gradient(180deg, #f8fbff 0%, #edf6ff 58%, #fbfdff 100%);
}
.content-scroll {
  height: 100vh;
  padding: 20rpx 24rpx 330rpx;
  box-sizing: border-box;
}
.hero-card {
  position: relative;
  height: 240rpx;
  padding: 46rpx 250rpx 36rpx 32rpx;
  border-radius: 20rpx;
  overflow: hidden;
  background:
    linear-gradient(120deg, rgba(255,255,255,0.95) 0%, rgba(235,244,255,0.86) 55%, rgba(213,231,255,0.94) 100%);
  box-shadow: 0 20rpx 46rpx rgba(45, 116, 228, 0.08);
}
.hero-card::after {
  content: '';
  position: absolute;
  right: -40rpx;
  top: -80rpx;
  width: 320rpx;
  height: 320rpx;
  border-radius: 50%;
  background: rgba(94, 154, 255, 0.12);
}
.hero-copy {
  position: relative;
  z-index: 1;
}
.hero-title {
  display: block;
  color: #14213d;
  font-size: 36rpx;
  font-weight: 800;
  line-height: 1.35;
  margin-bottom: 20rpx;
}
.blue {
  color: #2474ff;
}
.hero-subtitle {
  display: block;
  color: #62708a;
  font-size: 25rpx;
  line-height: 1.7;
}
.robot-hero {
  position: absolute;
  right: 28rpx;
  bottom: 18rpx;
  z-index: 1;
  width: 190rpx;
  height: 190rpx;
}
.robot-head {
  position: absolute;
  left: 28rpx;
  top: 12rpx;
  width: 134rpx;
  height: 104rpx;
  border-radius: 54rpx;
  background: #fff;
  box-shadow: inset 0 -8rpx 16rpx rgba(80, 139, 230, 0.12), 0 10rpx 28rpx rgba(54, 122, 255, 0.16);
}
.robot-screen {
  position: absolute;
  left: 20rpx;
  top: 28rpx;
  width: 94rpx;
  height: 50rpx;
  border-radius: 26rpx;
  background: linear-gradient(180deg, #0f48ba, #12286f);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 22rpx;
}
.robot-eye {
  width: 12rpx;
  height: 26rpx;
  border-radius: 20rpx;
  background: #67e8ff;
  box-shadow: 0 0 16rpx rgba(103, 232, 255, 0.9);
}
.robot-ear {
  position: absolute;
  top: 38rpx;
  width: 24rpx;
  height: 44rpx;
  border-radius: 18rpx;
  background: #5d99ff;
}
.robot-ear.left {
  left: -12rpx;
}
.robot-ear.right {
  right: -12rpx;
}
.robot-body {
  position: absolute;
  left: 54rpx;
  bottom: 8rpx;
  width: 82rpx;
  height: 86rpx;
  border-radius: 34rpx 34rpx 28rpx 28rpx;
  background: #fff;
  color: #72a9ff;
  font-size: 24rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 26rpx rgba(54, 122, 255, 0.12);
}
.guess-card {
  background: #fff;
  border-radius: 22rpx;
  padding: 30rpx 28rpx;
  margin-top: 18rpx;
  box-shadow: 0 18rpx 42rpx rgba(48, 111, 220, 0.08);
}
.section-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
  color: #111827;
  font-size: 32rpx;
  font-weight: 700;
  margin-bottom: 26rpx;
}
.star-icon {
  width: 34rpx;
  height: 34rpx;
  border-radius: 12rpx;
  background: linear-gradient(135deg, #755cff, #4388ff);
  color: #fff;
  font-size: 16rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
}
.question-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 18rpx 20rpx;
}
.question-item {
  width: calc(50% - 10rpx);
  height: 82rpx;
  padding: 0 18rpx;
  box-sizing: border-box;
  border: 1rpx solid #e7edf7;
  border-radius: 18rpx;
  background: linear-gradient(180deg, #fff, #fbfdff);
  display: flex;
  align-items: center;
  box-shadow: 0 10rpx 24rpx rgba(36, 116, 255, 0.04);
}
.question-icon {
  flex: 0 0 52rpx;
  width: 52rpx;
  height: 52rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  font-weight: 800;
}
.question-icon.blue,
.action-icon.blue {
  color: #437cff;
  background: #edf4ff;
}
.question-icon.orange,
.action-icon.orange {
  color: #ff9a18;
  background: #fff4e6;
}
.question-icon.green,
.action-icon.green {
  color: #1fc976;
  background: #e9fbf1;
}
.question-icon.cyan {
  color: #3689ff;
  background: #edf8ff;
}
.question-icon.purple {
  color: #7567ff;
  background: #f0eeff;
}
.question-icon.red,
.action-icon.red {
  color: #ef5d7a;
  background: #fff0f4;
}
.question-text {
  flex: 1;
  min-width: 0;
  margin-left: 14rpx;
  color: #172033;
  font-size: 25rpx;
  line-height: 1.35;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.arrow {
  color: #c4cad5;
  font-size: 40rpx;
  line-height: 1;
  margin-left: 6rpx;
}
.chat-area {
  padding: 30rpx 20rpx 24rpx;
  box-sizing: border-box;
  margin-top: 18rpx;
}
.message-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 24rpx;
}
.message-row.user {
  justify-content: flex-end;
}
.avatar {
  width: 76rpx;
  height: 76rpx;
  margin-right: 20rpx;
  border-radius: 50%;
  background: #eaf4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(55, 127, 255, 0.16);
}
.mini-robot-face {
  width: 46rpx;
  height: 32rpx;
  border-radius: 18rpx;
  background: #1f5bd8;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
}
.mini-robot-face view {
  width: 7rpx;
  height: 14rpx;
  border-radius: 10rpx;
  background: #67e8ff;
}
.bubble {
  max-width: 500rpx;
  padding: 24rpx 26rpx;
  border-radius: 20rpx;
  background: #fff;
  box-shadow: 0 12rpx 36rpx rgba(42, 96, 180, 0.06);
}
.message-row.user .bubble {
  background: linear-gradient(135deg, #2f78ff, #63a6ff);
}
.message-text {
  display: block;
  font-size: 28rpx;
  line-height: 1.8;
  color: #101828;
  white-space: pre-wrap;
}
.message-row.user .message-text {
  color: #fff;
}
.service-recommend {
  margin-top: 22rpx;
  padding-top: 18rpx;
  border-top: 1rpx solid #edf2f7;
}
.recommend-title {
  color: #536175;
  font-size: 23rpx;
  margin-bottom: 14rpx;
}
.service-card {
  position: relative;
  display: block;
  padding: 14rpx;
  margin-top: 12rpx;
  border-radius: 16rpx;
  background: linear-gradient(180deg, #f8fbff, #ffffff);
  border: 1rpx solid #e6eef8;
}
.service-main {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding-right: 104rpx;
}
.service-card:active {
  transform: scale(0.98);
}
.service-image {
  flex: 0 0 92rpx;
  width: 92rpx;
  height: 92rpx;
  border-radius: 14rpx;
  background: #eaf4ff;
}
.service-ph {
  color: #2474ff;
  font-size: 34rpx;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
}
.service-info {
  flex: 1;
  min-width: 0;
}
.service-name {
  display: block;
  color: #14213d;
  font-size: 26rpx;
  font-weight: 700;
  line-height: 1.35;
}
.service-desc {
  display: block;
  color: #7b8798;
  font-size: 22rpx;
  margin-top: 6rpx;
}
.service-price {
  display: block;
  color: #ff3b30;
  font-size: 24rpx;
  font-weight: 800;
  margin-top: 6rpx;
}
.order-btn {
  position: absolute;
  right: 14rpx;
  bottom: 18rpx;
  width: 90rpx;
  height: 52rpx;
  line-height: 52rpx;
  border-radius: 28rpx;
  text-align: center;
  color: #fff;
  font-size: 23rpx;
  font-weight: 700;
  background: linear-gradient(135deg, #18bd55, #09a83d);
  box-shadow: 0 8rpx 18rpx rgba(9, 168, 61, 0.2);
}
.chat-time {
  color: #a8afbd;
  font-size: 24rpx;
  text-align: center;
  padding-top: 6rpx;
}
.bottom-panel {
  position: fixed;
  left: 24rpx;
  right: 24rpx;
  bottom: calc(22rpx + env(safe-area-inset-bottom));
  z-index: 20;
}
.input-bar {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 16rpx 18rpx;
  border-radius: 24rpx;
  background: rgba(255,255,255,0.96);
  box-shadow: 0 16rpx 42rpx rgba(40, 110, 220, 0.09);
}
.voice-btn {
  flex: 0 0 62rpx;
  width: 62rpx;
  height: 62rpx;
  border-radius: 50%;
  color: #2678ff;
  background: #eef5ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 34rpx;
}
.input-wrap {
  flex: 1;
  min-width: 0;
  height: 70rpx;
  padding: 0 16rpx 0 24rpx;
  border-radius: 36rpx;
  background: #f5f8fc;
  display: flex;
  align-items: center;
}
.question-input {
  flex: 1;
  height: 70rpx;
  color: #182235;
  font-size: 26rpx;
}
.smile {
  color: #8a94a6;
  font-size: 42rpx;
  line-height: 1;
}
.send-btn {
  flex: 0 0 108rpx;
  width: 108rpx;
  height: 70rpx;
  line-height: 70rpx;
  padding: 0;
  font-size: 26rpx;
  border-radius: 36rpx;
  background: linear-gradient(135deg, #2474ff, #0f64f4);
  box-shadow: 0 10rpx 24rpx rgba(36, 116, 255, 0.28);
}
.action-grid {
  display: flex;
  gap: 20rpx;
  margin-top: 22rpx;
  padding: 20rpx 18rpx;
  border-radius: 22rpx;
  background: rgba(255,255,255,0.82);
  box-shadow: 0 18rpx 44rpx rgba(42, 103, 210, 0.08);
}
.action-item {
  flex: 1;
  min-width: 0;
  height: 126rpx;
  padding: 18rpx 6rpx 14rpx;
  box-sizing: border-box;
  border-radius: 18rpx;
  background: rgba(255,255,255,0.9);
  text-align: center;
  color: #111827;
  font-size: 25rpx;
}
.action-icon {
  width: 62rpx;
  height: 62rpx;
  margin: 0 auto 14rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  font-weight: 800;
}
</style>
