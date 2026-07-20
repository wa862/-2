<template>
  <div class="ai-page">
    <section class="assistant-shell">
      <aside class="knowledge-panel">
        <h2>AI 智能客服</h2>
        <p>干洗预约、价格规格、洗护周期、取送服务和售后问题都可以问我。</p>
        <div class="quick-list">
          <button v-for="item in quickQuestions" :key="item.text" @click="sendQuick(item.text)">
            <span class="quick-icon" :class="item.color">{{ item.icon }}</span>
            <span class="quick-text">{{ item.text }}</span>
          </button>
        </div>
      </aside>

      <section class="chat-panel">
        <div class="messages" ref="messagesRef">
          <div v-for="msg in messages" :key="msg.id" class="message-row" :class="msg.role">
            <div v-if="msg.role === 'assistant'" class="avatar">
              <div class="mini-robot-face">
                <span></span>
                <span></span>
              </div>
            </div>
            <div class="bubble">
              <div class="text">{{ msg.content }}</div>
              <div v-if="msg.role === 'assistant' && msg.services && msg.services.length" class="service-recommend">
                <div class="recommend-title">为您找到相关服务</div>
                <div
                  v-for="service in msg.services"
                  :key="service.id"
                  class="service-card"
                  @click="goOrder(service.id)"
                >
                  <div class="service-main">
                    <img v-if="service.image" class="service-image" :src="service.image" alt="" />
                    <div v-else class="service-image service-ph">洗</div>
                    <div class="service-info">
                      <div class="service-name">{{ service.name }}</div>
                      <div class="service-desc">{{ service.cycle || service.category || '专业洗护服务' }}</div>
                      <div class="service-price">¥{{ service.price }}/件起</div>
                    </div>
                  </div>
                  <div class="order-btn">去下单</div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="input-bar">
          <div class="voice-btn">🎙</div>
          <el-input
            v-model="question"
            type="textarea"
            :rows="2"
            resize="none"
            placeholder="输入你想咨询的问题"
            @keydown.enter.exact.prevent="send"
          />
          <el-button type="primary" :loading="loading" @click="send">发送</el-button>
        </div>
        <div class="action-grid">
          <div
            v-for="item in actionItems"
            :key="item.title"
            class="action-item"
            @click="goAction(item.path)"
          >
            <div class="action-icon" :class="item.color">{{ item.icon }}</div>
            <span>{{ item.title }}</span>
          </div>
        </div>
      </section>
    </section>
  </div>
</template>

<script setup lang="ts">
import { nextTick, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { askAi, type AiChatResponse } from '@/api/ai'
import { getServiceList, type ServiceItem } from '@/api/service'
import { useUserStore } from '@/stores/user'

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
  { title: '预约下单', icon: '约', color: 'blue', path: '/home/user/service' },
  { title: '价格查询', icon: '价', color: 'orange', path: '/home/user/service' },
  { title: '取送服务', icon: '送', color: 'green', path: '/home/user/order/create' },
  { title: '订单查询', icon: '单', color: 'red', path: '/home/user/order' },
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
const messagesRef = ref<HTMLElement>()
const serviceList = ref<ServiceItem[]>([])
const router = useRouter()
const userStore = useUserStore()
const genericServiceWords = ['清洗', '干洗', '洗护', '护理', '服务', '保养', '去污', '除臭', '专业', '日常']

onMounted(() => {
  loadServices()
})

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
  return serviceList.value
    .map((service) => ({ service, score: serviceScore(service, text) }))
    .filter((item) => item.score >= 18)
    .sort((a, b) => b.score - a.score)
    .slice(0, 2)
    .map((item) => item.service)
}

async function loadServices() {
  try {
    const list = await getServiceList()
    serviceList.value = Array.isArray(list) ? list.filter((item) => item.status !== 0) : []
  } catch (e) {
    console.error('[ai] services', e)
  }
}

function sendQuick(text: string) {
  question.value = text
  send()
}

function goAction(path: string) {
  router.push(path)
}

function goOrder(serviceId: number) {
  router.push(`/home/user/order/create?serviceId=${serviceId}`)
}

async function send() {
  const text = question.value.trim()
  if (!text || loading.value) return
  if (!serviceList.value.length) await loadServices()
  messages.value.push({ id: Date.now(), role: 'user', content: text })
  question.value = ''
  loading.value = true
  await scrollBottom()
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
    const msg = e?.response?.data?.message || e?.message || 'AI客服暂时不可用'
    ElMessage.error(msg)
    messages.value.push({
      id: Date.now() + 2,
      role: 'assistant',
      content: '服务暂时不可用，请稍后再试，或联系门店客服处理紧急问题。',
      source: 'FALLBACK',
      services: findRelatedServices(text),
    })
  } finally {
    loading.value = false
    await scrollBottom()
  }
}

function scrollBottom() {
  return nextTick(() => {
    if (messagesRef.value) messagesRef.value.scrollTop = messagesRef.value.scrollHeight
  })
}
</script>

<style scoped>
.ai-page { min-height: calc(100vh - 72px); font-size: 14px; padding: 20px 0; }
.assistant-shell {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 24px;
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 20px;
}
.knowledge-panel,
.chat-panel {
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
}
.knowledge-panel { padding: 20px; align-self: start; }
.knowledge-panel h2 { margin: 0 0 10px; font-size: 18px; color: #303133; }
.knowledge-panel p { margin: 0 0 20px; color: #606266; line-height: 1.6; font-size: 14px; }
.quick-list { display: flex; flex-direction: column; gap: 10px; }
.quick-list button {
  display: flex;
  align-items: center;
  gap: 12px;
  border: 1px solid #e7edf7;
  background: #fff;
  color: #303133;
  border-radius: 10px;
  padding: 12px 16px;
  text-align: left;
  cursor: pointer;
  font-size: 14px;
  line-height: 1.5;
  transition: all 0.2s;
}
.quick-list button:hover { border-color: #409eff; background: #f8faff; }
.quick-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}
.quick-icon.blue { color: #437cff; background: #edf4ff; }
.quick-icon.orange { color: #ff9a18; background: #fff4e6; }
.quick-icon.green { color: #1fc976; background: #e9fbf1; }
.quick-icon.cyan { color: #3689ff; background: #edf8ff; }
.quick-icon.purple { color: #7567ff; background: #f0eeff; }
.quick-icon.red { color: #ef5d7a; background: #fff0f4; }
.quick-text { flex: 1; min-width: 0; }
.chat-panel { min-height: 600px; display: flex; flex-direction: column; overflow: hidden; }
.messages { flex: 1; padding: 24px; overflow-y: auto; background: #f7f9fc; }
.message-row { display: flex; align-items: flex-start; margin-bottom: 24px; }
.message-row.user { justify-content: flex-end; }
.avatar {
  width: 44px;
  height: 44px;
  margin-right: 12px;
  border-radius: 50%;
  background: #eaf4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.mini-robot-face {
  width: 28px;
  height: 18px;
  border-radius: 12px;
  background: #1f5bd8;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.mini-robot-face span {
  width: 5px;
  height: 10px;
  border-radius: 8px;
  background: #67e8ff;
}
.bubble {
  max-width: min(600px, 75%);
  padding: 14px 18px;
  border-radius: 10px;
  line-height: 1.7;
  white-space: pre-wrap;
  color: #303133;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  font-size: 14px;
}
.message-row.user .bubble { background: linear-gradient(135deg, #2f78ff, #63a6ff); color: #fff; }
.service-recommend {
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid #edf2f7;
}
.recommend-title {
  color: #536175;
  font-size: 13px;
  margin-bottom: 12px;
}
.service-card {
  position: relative;
  display: block;
  padding: 14px;
  margin-top: 12px;
  border-radius: 10px;
  background: #fff;
  border: 1px solid #e6eef8;
  cursor: pointer;
  transition: all 0.2s;
}
.service-card:hover { border-color: #409eff; background: #fafdff; }
.service-main {
  display: flex;
  align-items: center;
  gap: 14px;
  padding-right: 90px;
}
.service-image {
  width: 56px;
  height: 56px;
  border-radius: 10px;
  background: #eaf4ff;
  flex-shrink: 0;
  overflow: hidden;
}
.service-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.service-ph {
  color: #2474ff;
  font-size: 22px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}
.service-info { flex: 1; min-width: 0; }
.service-name {
  display: block;
  color: #14213d;
  font-size: 15px;
  font-weight: 600;
  line-height: 1.4;
}
.service-desc {
  display: block;
  color: #7b8798;
  font-size: 13px;
  margin-top: 4px;
}
.service-price {
  display: block;
  color: #ff3b30;
  font-size: 14px;
  font-weight: 700;
  margin-top: 4px;
}
.order-btn {
  position: absolute;
  right: 14px;
  bottom: 14px;
  width: 72px;
  height: 36px;
  line-height: 36px;
  border-radius: 18px;
  text-align: center;
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  background: linear-gradient(135deg, #18bd55, #09a83d);
}
.input-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: #fff;
  border-top: 1px solid #ebeef5;
}
.voice-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  color: #2678ff;
  background: #eef5ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}
.input-bar :deep(.el-textarea__inner) { font-size: 14px; line-height: 1.6; min-height: 44px !important; }
.input-bar .el-button { height: 44px; font-size: 14px; padding: 0 24px; }
.action-grid {
  display: flex;
  gap: 16px;
  padding: 16px 20px;
  background: #fff;
  border-top: 1px solid #ebeef5;
}
.action-item {
  flex: 1;
  min-width: 0;
  height: 72px;
  padding: 10px 6px;
  box-sizing: border-box;
  border-radius: 10px;
  background: #fafafa;
  text-align: center;
  color: #303133;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}
.action-item:hover { background: #ecf5ff; }
.action-icon {
  width: 36px;
  height: 36px;
  margin: 0 auto 8px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
}
.action-icon.blue { color: #437cff; background: #edf4ff; }
.action-icon.orange { color: #ff9a18; background: #fff4e6; }
.action-icon.green { color: #1fc976; background: #e9fbf1; }
.action-icon.red { color: #ef5d7a; background: #fff0f4; }
@media (max-width: 860px) {
  .assistant-shell { grid-template-columns: 1fr; }
  .chat-panel { min-height: 400px; }
  .bubble { max-width: 88%; }
}
</style>
