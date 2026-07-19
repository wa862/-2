<template>
  <div class="pay-page">
    <header class="pay-header">
      <span class="back" @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
      </span>
      <span class="title">收银台</span>
    </header>

    <template v-if="!store.token">
      <el-empty description="请先登录">
        <el-button type="primary" @click="$router.push('/home/login')">去登录</el-button>
      </el-empty>
    </template>

    <template v-else>
      <div v-if="loading" class="loading-wrap"><el-icon class="is-loading"><Loading /></el-icon> 加载中...</div>
      <template v-else-if="!payment">
        <el-empty description="支付单不存在或已失效" />
      </template>
      <template v-else-if="payment.status === 'PAID'">
        <div class="paid-tip">
          <el-icon color="#67C23A" :size="48"><CircleCheck /></el-icon>
          <p>已支付成功</p>
          <el-button type="primary" @click="$router.push('/home/user/order')">返回订单</el-button>
        </div>
      </template>
      <div v-else class="pay-main">
        <section class="block amount-block">
          <div class="amount-label">支付金额</div>
          <div class="amount-value">¥{{ payment.amount?.toFixed(2) ?? '0.00' }}</div>
          <div class="order-no">订单号：{{ payment.orderNo }}</div>
        </section>

        <section class="block method-block">
          <div class="section-title">支付方式</div>
          <div class="method-list">
            <div class="method-item" :class="{ active: payMethod === 'ALIPAY' }" @click="payMethod = 'ALIPAY'">
              <span class="method-icon alipay">支</span>
              <span class="method-name">支付宝</span>
              <span class="method-desc">使用支付宝扫码或账户余额支付</span>
            </div>
            <div class="method-item" :class="{ active: payMethod === 'WECHAT' }" @click="payMethod = 'WECHAT'">
              <span class="method-icon wechat">微</span>
              <span class="method-name">微信支付</span>
              <span class="method-desc">使用微信扫码支付</span>
            </div>
            <div class="method-item" :class="{ active: payMethod === 'SIMULATE' }" @click="payMethod = 'SIMULATE'">
              <span class="method-icon">💳</span>
              <span class="method-name">模拟支付</span>
              <span class="method-desc">演示环境，点击确认即完成支付</span>
            </div>
          </div>
        </section>

        <div class="submit-wrap">
          <el-button
            type="primary"
            class="submit-btn"
            :loading="paying"
            @click="doConfirmPay"
          >
            确认支付 ¥{{ payment.amount?.toFixed(2) ?? '0.00' }}
          </el-button>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading, CircleCheck } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getPayment, confirmPayment, type PaymentItem } from '@/api/payment'

const store = useUserStore()
const route = useRoute()
const router = useRouter()
const payment = ref<PaymentItem | null>(null)
const loading = ref(true)
const paying = ref(false)
const payMethod = ref<'ALIPAY' | 'WECHAT' | 'SIMULATE'>('ALIPAY')

const paymentId = ref<number | null>(null)

function goBack() {
  router.push('/home/user/order')
}

function load() {
  const id = Number(route.query.paymentId)
  if (!id) {
    loading.value = false
    return
  }
  paymentId.value = id
  loading.value = true
  getPayment(id)
    .then((data) => {
      payment.value = data
    })
    .catch(() => {
      payment.value = null
    })
    .finally(() => {
      loading.value = false
    })
}

async function doConfirmPay() {
  if (!payment.value || payment.value.status === 'PAID') return
  paying.value = true
  try {
    await confirmPayment(payment.value.id, payMethod.value)
    ElMessage.success('支付成功')
    payment.value = { ...payment.value, status: 'PAID' }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '支付失败')
  } finally {
    paying.value = false
  }
}

onMounted(load)
watch(() => route.query.paymentId, load)
</script>

<style scoped>
.pay-page {
  min-height: 100vh;
  background: #F9F5F0;
  padding: 16px 16px 100px;
}
.pay-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}
.back {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #2D2A27;
  cursor: pointer;
  border-radius: 50%;
  background: #fff;
}
.title { font-size: 22px; font-weight: 600; color: #2D2A27; }
.loading-wrap { text-align: center; padding: 48px; color: #8F7F70; }

.paid-tip {
  text-align: center;
  padding: 48px 24px;
}
.paid-tip p { margin: 16px 0 24px; font-size: 20px; color: #2D2A27; }

.block {
  background: #fff;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(74, 63, 56, 0.06);
}
.amount-block { text-align: center; padding: 28px; }
.amount-label { font-size: 18px; color: #8F7F70; margin-bottom: 8px; }
.amount-value { font-size: 36px; font-weight: 700; color: #C17C5A; }
.order-no { font-size: 18px; color: #8F7F70; margin-top: 12px; }

.method-block .section-title { font-size: 18px; color: #8F7F70; margin-bottom: 12px; }
.method-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px;
  border: 1px solid #F0E9E2;
  border-radius: 12px;
  cursor: pointer;
  margin-bottom: 8px;
}
.method-item.active { border-color: #4A3F38; background: #F9F5F0; }
.method-icon {
  font-size: 22px;
  font-weight: 700;
  width: 36px;
  height: 36px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  color: #fff;
}
.method-icon.alipay { background: #1677ff; }
.method-icon.wechat { background: #07c160; }
.method-name { font-weight: 500; color: #2D2A27; flex: 1; }
.method-desc { font-size: 18px; color: #8F7F70; }

.submit-wrap { margin-top: 24px; }
.submit-btn { width: 100%; border-radius: 24px; font-weight: 500; height: 48px; }
</style>
