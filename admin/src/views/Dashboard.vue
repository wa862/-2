<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">待处理订单</div>
          <div class="stat-value">{{ pendingOrders }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">今日订单</div>
          <div class="stat-value">{{ stats.todayOrders }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">订单总数</div>
          <div class="stat-value">{{ stats.totalOrders }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 10px">
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">销售额</div>
          <div class="stat-value">¥{{ stats.sales }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-label">用户数量</div>
          <div class="stat-value">{{ stats.userCount }}</div>
        </el-card>
      </el-col>
    </el-row>
    <el-card shadow="hover" class="chart-card">
      <template #header>订单趋势</template>
      <div ref="chartRef" class="chart-wrap"></div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { getStats, type StatsRes, getOrderTrend, type OrderTrendItem } from '@/api/stats'
import { getOrderList } from '@/api/order'

const stats = ref<StatsRes>({
  todayOrders: 0,
  totalOrders: 0,
  sales: '0',
  userCount: 0,
})

const pendingOrders = ref(0)

const chartRef = ref<HTMLElement | null>(null)
let chartInstance: any = null
let trendTimer: number | null = null

async function initChart() {
  const echarts = await import('echarts')
  if (!chartRef.value) return
  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value)
    window.addEventListener('resize', () => chartInstance && chartInstance.resize())
  }
}

function setTrendOption(trend: OrderTrendItem[]) {
  if (!chartInstance) return
  const dates = trend.map((t) => t.date.slice(5).replace('-', '/')) // 显示成 MM/dd
  const orders = trend.map((t) => t.orderCount)
  const sales = trend.map((t) => t.sales)
  chartInstance.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单数', '销售额(元)'], bottom: 0, textStyle: { fontSize: 24 } },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: dates, axisLabel: { fontSize: 22 } },
    yAxis: [
      { type: 'value', name: '订单数', nameTextStyle: { fontSize: 22 }, axisLabel: { formatter: '{value}', fontSize: 20 } },
      { type: 'value', name: '销售额', nameTextStyle: { fontSize: 22 }, axisLabel: { formatter: '¥{value}', fontSize: 20 } },
    ],
    series: [
      { name: '订单数', type: 'line', smooth: true, data: orders, symbolSize: 14, lineStyle: { width: 5 }, itemStyle: { color: '#409EFF' } },
      { name: '销售额(元)', type: 'bar', yAxisIndex: 1, data: sales, barWidth: 28, itemStyle: { color: '#67C23A' } },
    ],
  })
}

async function loadTrend() {
  try {
    await initChart()
    const data = await getOrderTrend(7)
    setTrendOption(data)
  } catch (_) {
    // ignore
  }
}

onMounted(async () => {
  // 概览统计
  getStats().then((data) => {
    stats.value = data
  }).catch(() => {})

  // 待处理订单数量：按状态 PENDING 统计总条数
  getOrderList({ page: 0, size: 1, status: 'PENDING' })
    .then((res) => { pendingOrders.value = res.totalElements ?? 0 })
    .catch(() => { pendingOrders.value = 0 })

  // 订单趋势图：真实数据 + 定时刷新
  await loadTrend()
  trendTimer = window.setInterval(loadTrend, 60 * 1000) // 每分钟刷新一次
})

onBeforeUnmount(() => {
  if (trendTimer != null) {
    window.clearInterval(trendTimer)
    trendTimer = null
  }
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
})
</script>

<style scoped>
.dashboard { font-size: 18px; }
.stat-card { margin-bottom: 20px; }
.stat-label { font-size: 20px; color: #909399; margin-bottom: 10px; }
.stat-value { font-size: 34px; font-weight: 700; color: #303133; }
.chart-card { margin-top: 20px; }
.chart-card :deep(.el-card__header) {
  font-size: 22px;
  font-weight: 600;
}
.chart-wrap { width: 100%; height: 560px; }
</style>
