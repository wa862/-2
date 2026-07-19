<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'
import { useUserStore } from '@/stores/user'
import { getCurrentUser } from '@/api/auth'

onLaunch(async () => {
  const store = useUserStore()
  if (store.token) {
    try {
      const user = await getCurrentUser()
      store.setAuth(store.token, user)
    } catch {
      store.logout()
    }
  }
})
</script>

<style lang="scss">
page {
  background-color: #f5f7fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  font-size: 28rpx;
  color: #303133;
}

.btn-primary {
  background: #409eff;
  color: #fff;
  border-radius: 40rpx;
  font-size: 28rpx;
  border: none;
}

.btn-primary::after {
  border: none;
}

.btn-primary[disabled] {
  opacity: 0.6;
}

.card {
  background: #fff;
  border-radius: 16rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #303133;
  margin-bottom: 20rpx;
}

.price {
  color: #ff4d4f;
  font-weight: 700;
}

.empty-wrap {
  padding: 80rpx 0;
  text-align: center;
  color: #909399;
}
</style>
