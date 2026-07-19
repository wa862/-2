<template>
  <div class="ai-page">
    <section class="assistant-shell">
      <aside class="knowledge-panel">
        <h2>AI 智能客服</h2>
        <p>干洗预约、价格规格、洗护周期、取送服务和售后问题都可以问我。</p>
        <div class="quick-list">
          <button v-for="item in quickQuestions" :key="item" @click="sendQuick(item)">
            {{ item }}
          </button>
        </div>
      </aside>

      <section class="chat-panel">
        <div class="messages" ref="messagesRef">
          <div v-for="msg in messages" :key="msg.id" class="message-row" :class="msg.role">
            <div class="bubble">
              <div class="text">{{ msg.content }}</div>
              <div v-if="msg.orderAction" class="order-card">
                <div class="order-card-main">
                  <div class="order-card-label">已为你匹配到服务</div>
                  <div class="order-card-title">{{ msg.orderAction.serviceName }}</div>
                  <div class="order-card-meta">
                    {{ msg.orderAction.specName || '默认规格' }} · {{ msg.orderAction.quantity }}件 · ¥{{ msg.orderAction.price.toFixed(0) }}/件起
                  </div>
                </div>
                <el-button type="primary" @click="goOrder(msg.orderAction)">立即下单</el-button>
              </div>
            </div>
          </div>
        </div>
        <div class="input-bar">
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

type OrderAction = {
  serviceId: number
  serviceName: string
  specName: string
  quantity: number
  price: number
  remark: string
}

type ChatMessage = {
  id: number
  role: 'assistant' | 'user'
  content: string
  source?: AiChatResponse['sourceType']
  orderAction?: OrderAction
}

const quickQuestions = [
  '羽绒服干洗需要多久？',
  '西装可以当天取吗？',
  '皮衣护理怎么收费？',
  '下单后可以上门取衣吗？',
  '衣服洗坏了怎么售后？',
  '哪些衣物不适合水洗？',
]

const messages = ref<ChatMessage[]>([
  {
    id: Date.now(),
    role: 'assistant',
    content: '你好，我是洗衣优选 AI 客服。你可以直接问干洗价格、洗护周期、预约取送、订单售后等问题。',
    source: 'KNOWLEDGE',
  },
])
const question = ref('')
const loading = ref(false)
const messagesRef = ref<HTMLElement>()
const serviceList = ref<ServiceItem[]>([])
let serviceListPromise: Promise<void> | null = null
const router = useRouter()
const userStore = useUserStore()

onMounted(async () => {
  await ensureServiceList()
})

function ensureServiceList() {
  if (serviceList.value.length) return Promise.resolve()
  if (serviceListPromise) return serviceListPromise
  serviceListPromise = getServiceList()
    .then((data) => {
      serviceList.value = Array.isArray(data) ? data : []
    })
    .catch(() => {
      serviceList.value = []
    })
    .finally(() => {
      serviceListPromise = null
    })
  return serviceListPromise
}

function sendQuick(text: string) {
  question.value = text
  send()
}

async function send() {
  const text = question.value.trim()
  if (!text || loading.value) return
  messages.value.push({ id: Date.now(), role: 'user', content: text })
  question.value = ''
  loading.value = true
  await scrollBottom()
  try {
    await ensureServiceList()
    const action = matchOrderAction(text)
    const res = await askAi(text, userStore.user?.id)
    messages.value.push({
      id: Date.now() + 1,
      role: 'assistant',
      content: action
        ? `已根据你的描述匹配到“${action.serviceName}”，可以直接进入下单页面。`
        : res.answer || '我暂时没有获得答案，请换一种问法试试。',
      source: res.sourceType,
      orderAction: action,
    })
  } catch (e: any) {
    const msg = e?.response?.data?.message || e?.message || 'AI 助手暂时不可用'
    ElMessage.error(msg)
    messages.value.push({
      id: Date.now() + 2,
      role: 'assistant',
      content: `服务暂时不可用：${msg}。请确认前端开发服务和后端服务都已启动。`,
      source: 'FALLBACK',
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

function goOrder(action: OrderAction) {
  router.push({
    path: '/home/user/order/create',
    query: {
      serviceId: String(action.serviceId),
      ...(action.specName ? { specName: action.specName } : {}),
      quantity: String(action.quantity),
      remark: action.remark,
    },
  })
}

function matchOrderAction(input: string): OrderAction | undefined {
  if (!isOrderIntent(input) || !serviceList.value.length) return undefined
  const best = serviceList.value
    .map((service) => ({ service, score: getServiceScore(service, input) }))
    .sort((a, b) => b.score - a.score)[0]
  if (!best || best.score < 6) return undefined
  const spec = pickSpec(best.service, input)
  return {
    serviceId: best.service.id,
    serviceName: best.service.name,
    specName: spec?.name || '',
    quantity: parseQuantity(input),
    price: spec?.price || Number(best.service.price) || 0,
    remark: `AI需求：${input}`,
  }
}

function isOrderIntent(input: string) {
  return /(下单|预约|洗|清洗|干洗|护理|保养|帮我|我要|我想|需要)/.test(input)
}

function getServiceScore(service: ServiceItem, input: string) {
  const searchable = [
    service.name,
    service.category,
    service.description,
    service.specs,
  ].filter(Boolean).join(' ')
  return getTextScore(searchable, input) + getTextScore(service.name || '', input)
}

function pickSpec(service: ServiceItem, input: string) {
  const specs = parseServiceSpecs(service.specs)
  if (!specs.length) return undefined
  const best = specs
    .map((spec) => ({ spec, score: getTextScore(spec.name, input) }))
    .sort((a, b) => b.score - a.score)[0]
  return best && best.score > 0 ? best.spec : specs[0]
}

function parseServiceSpecs(raw?: string) {
  if (!raw?.trim()) return []
  return raw
    .split(/[;,，]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => {
      const [name, priceStr] = part.split('|').map((s) => s.trim())
      const price = Number((priceStr || '').replace(/[^0-9.]/g, ''))
      if (!name || Number.isNaN(price) || price <= 0) return null
      return { name, price }
    })
    .filter((item): item is { name: string; price: number } => !!item)
}

function getTextScore(target: string, input: string) {
  const source = normalizeText(target)
  const tokens = extractTokens(input)
  let score = 0
  tokens.forEach((token) => {
    if (source.includes(token)) score += token.length >= 3 ? 8 : 5
  })
  const normalizedInput = normalizeText(input)
  if (source && normalizedInput.includes(source)) score += 10
  return score
}

function extractTokens(input: string) {
  const original = normalizeText(input)
  const normalized = original
    .replace(/(我想|我要|我需要|帮我|给我|选择|挑选|推荐|预约|下单|一下|一个|一件|服务|衣物|衣服|洗|清洗|干洗|护理|保养|的)/g, ' ')
    .replace(/[0-9一二两三四五六七八九十]+件/g, ' ')
    .trim()
  const tokens = normalized.split(/\s+/).filter(Boolean)
  if (normalized && normalized.length <= 8) tokens.push(normalized)
  const keywords = [
    '基础', '深度', '除臭', '普通', '运动鞋', '跑步鞋', '篮球鞋', '皮鞋',
    '羽绒服', '西装', '大衣', '衬衫', '毛衣', '皮衣', '箱包', '奢侈品',
  ]
  keywords.forEach((word) => {
    if (original.includes(word)) tokens.push(word)
  })
  for (let i = 0; i < original.length - 1; i++) {
    tokens.push(original.substring(i, i + 2))
  }
  return Array.from(new Set(tokens.filter((token) => token.length >= 2)))
}

function parseQuantity(input: string) {
  const numberHit = input.match(/(\d+)\s*件/)
  if (numberHit) return Math.max(1, Math.min(10, Number(numberHit[1]) || 1))
  const cnMap: Record<string, number> = { 一: 1, 二: 2, 两: 2, 三: 3, 四: 4, 五: 5, 六: 6, 七: 7, 八: 8, 九: 9, 十: 10 }
  const cnHit = input.match(/([一二两三四五六七八九十])\s*件/)
  return cnHit ? cnMap[cnHit[1]] || 1 : 1
}

function normalizeText(text: string) {
  return String(text || '').toLowerCase().replace(/[，。！？、,.!?;；:\s]/g, '')
}
</script>

<style scoped>
.ai-page { min-height: calc(100vh - 96px); font-size: 23px; }
.assistant-shell {
  display: grid;
  grid-template-columns: 340px minmax(0, 1fr);
  gap: 22px;
  max-width: 1280px;
  margin: 0 auto;
}
.knowledge-panel,
.chat-panel {
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}
.knowledge-panel { padding: 28px; align-self: start; }
.knowledge-panel h2 { margin: 0 0 14px; font-size: 34px; color: #303133; }
.knowledge-panel p { margin: 0 0 24px; color: #606266; line-height: 1.75; font-size: 24px; }
.quick-list { display: flex; flex-direction: column; gap: 12px; }
.quick-list button {
  border: 1px solid #dcdfe6;
  background: #fff;
  color: #303133;
  border-radius: 8px;
  padding: 14px 16px;
  text-align: left;
  cursor: pointer;
  font-size: 22px;
  line-height: 1.45;
}
.quick-list button:hover { color: #409eff; border-color: #409eff; }
.chat-panel { min-height: 720px; display: flex; flex-direction: column; overflow: hidden; }
.messages { flex: 1; padding: 28px; overflow-y: auto; background: #f7f9fc; }
.message-row { display: flex; margin-bottom: 20px; }
.message-row.user { justify-content: flex-end; }
.bubble {
  max-width: min(760px, 78%);
  padding: 18px 20px;
  border-radius: 8px;
  line-height: 1.7;
  white-space: pre-wrap;
  color: #303133;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  font-size: 23px;
}
.message-row.user .bubble { background: #409eff; color: #fff; }
.order-card {
  display: flex;
  align-items: center;
  gap: 18px;
  margin-top: 16px;
  padding: 16px;
  border: 1px solid #d9ecff;
  border-radius: 8px;
  background: #ecf5ff;
  white-space: normal;
}
.order-card-main { flex: 1; min-width: 0; }
.order-card-label { color: #409eff; font-size: 18px; line-height: 1.4; }
.order-card-title { margin-top: 4px; color: #303133; font-size: 24px; font-weight: 700; }
.order-card-meta { margin-top: 4px; color: #606266; font-size: 20px; }
.order-card .el-button { height: 48px; font-size: 20px; }
.input-bar {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 120px;
  gap: 14px;
  padding: 18px;
  background: #fff;
  border-top: 1px solid #ebeef5;
}
.input-bar :deep(.el-textarea__inner) { font-size: 23px; line-height: 1.6; min-height: 68px !important; }
.input-bar .el-button { height: 68px; font-size: 23px; }
@media (max-width: 860px) {
  .assistant-shell { grid-template-columns: 1fr; }
  .chat-panel { min-height: 560px; }
  .bubble { max-width: 88%; }
}
</style>
