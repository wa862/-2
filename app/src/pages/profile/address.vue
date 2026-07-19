<template>
  <view class="page">
    <view class="panel">
      <view class="addr-head">
        <view class="section-head section-head-inline">
          <view class="section-mark"></view>
          <text class="section-title">取送地址</text>
        </view>
        <button class="add-btn" size="mini" @click="openAddressForm()">+ 新增</button>
      </view>
      <view v-if="!addressList.length" class="empty-wrap">暂无地址</view>
      <view v-for="a in addressList" :key="a.id" class="addr-item">
        <view class="pin">●</view>
        <view class="addr-info">
          <view class="addr-user">
            <text class="addr-name">{{ a.contactName }}</text>
            <text class="addr-phone">{{ a.phone }}</text>
          </view>
          <text class="addr-detail">{{ fullAddress(a) }}</text>
          <view class="addr-actions">
            <text @click="openAddressForm(a)">编辑</text>
            <text class="del" @click="deleteAddress(a.id)">删除</text>
          </view>
        </view>
      </view>
    </view>

    <view v-if="addressFormVisible" class="mask" @click="addressFormVisible=false">
      <view class="dialog" @click.stop>
        <text class="dialog-title">{{ editingAddressId ? '编辑地址' : '新增地址' }}</text>
        <input v-model="addressForm.contactName" class="input" placeholder="收货人" />
        <input v-model="addressForm.phone" class="input" type="number" maxlength="11" placeholder="手机号" />
        <input v-model="addressForm.province" class="input" placeholder="省" />
        <input v-model="addressForm.city" class="input" placeholder="市" />
        <input v-model="addressForm.district" class="input" placeholder="区" />
        <textarea v-model="addressForm.detailAddress" class="textarea" placeholder="详细地址" />
        <label class="check"><checkbox :checked="addressForm.isDefault" @click="addressForm.isDefault=!addressForm.isDefault" />设为默认</label>
        <button class="primary-btn" :loading="addressSaving" @click="saveAddress">保存</button>
      </view>
    </view>
    <AiFloat />
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import {
  getAddressList, createAddress, updateAddress, removeAddress,
  type UserAddressItem, type AddressCreateParams,
} from '@/api/address'
import { fullAddress } from '@/utils'

const addressList = ref<UserAddressItem[]>([])
const addressFormVisible = ref(false)
const addressSaving = ref(false)
const editingAddressId = ref<number | null>(null)
const addressForm = ref<AddressCreateParams>({
  contactName: '', phone: '', province: '', city: '', district: '', detailAddress: '', isDefault: false,
})

async function loadAddresses() {
  try { addressList.value = await getAddressList() } catch {}
}

function openAddressForm(a?: UserAddressItem) {
  editingAddressId.value = a && a.id ? a.id : null
  addressForm.value = a
    ? { contactName: a.contactName, phone: a.phone, province: a.province, city: a.city, district: a.district, detailAddress: a.detailAddress, isDefault: a.isDefault }
    : { contactName: '', phone: '', province: '', city: '', district: '', detailAddress: '', isDefault: false }
  addressFormVisible.value = true
}

async function saveAddress() {
  if (!addressForm.value.contactName || !addressForm.value.phone || !addressForm.value.detailAddress) {
    return uni.showToast({ title: '请填写完整信息', icon: 'none' })
  }
  addressSaving.value = true
  try {
    if (editingAddressId.value) {
      await updateAddress(editingAddressId.value, addressForm.value)
    } else {
      await createAddress(addressForm.value)
    }
    addressFormVisible.value = false
    loadAddresses()
    uni.showToast({ title: '保存成功', icon: 'success' })
  } catch (e: any) {
    uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
  } finally {
    addressSaving.value = false
  }
}

async function deleteAddress(id: number) {
  uni.showModal({
    title: '确认删除该地址？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await removeAddress(id)
        loadAddresses()
        uni.showToast({ title: '已删除', icon: 'success' })
      } catch (e: any) {
        uni.showToast({ title: (e && e.message) || '失败', icon: 'none' })
      }
    },
  })
}

onShow(loadAddresses)
onMounted(loadAddresses)
</script>

<style scoped lang="scss">
.page {
  min-height: 100vh;
  padding: 28rpx;
  box-sizing: border-box;
  background: #f5f9ff;
}
.panel {
  background: #fff;
  border-radius: 20rpx;
  padding: 32rpx;
  box-shadow: 0 12rpx 34rpx rgba(24, 55, 102, 0.08);
}
.addr-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;
}
.section-head {
  display: flex;
  align-items: center;
  gap: 14rpx;
}
.section-head-inline { margin-bottom: 0; }
.section-mark {
  width: 8rpx;
  height: 34rpx;
  border-radius: 8rpx;
  background: #2f78ff;
}
.section-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #1f2533;
}
.add-btn {
  height: 56rpx;
  line-height: 52rpx;
  padding: 0 26rpx;
  border-radius: 16rpx;
  border: 1rpx solid #31c35b;
  color: #20b64a;
  background: #fff;
  font-size: 26rpx;
}
.empty-wrap { padding: 60rpx 24rpx; text-align: center; color: #909399; }
.addr-item {
  display: flex;
  align-items: center;
  gap: 18rpx;
  padding: 24rpx 0;
  border-bottom: 1rpx dashed #e2e6ee;
}
.addr-item:last-child { border-bottom: none; padding-bottom: 4rpx; }
.pin {
  width: 54rpx;
  height: 54rpx;
  border-radius: 50%;
  background: #eaf2ff;
  color: #2f78ff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26rpx;
}
.addr-info { flex: 1; min-width: 0; }
.addr-user {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin-bottom: 6rpx;
}
.addr-name {
  color: #1f2533;
  font-size: 30rpx;
  font-weight: 700;
}
.addr-phone {
  color: #6f7684;
  font-size: 26rpx;
}
.addr-detail {
  display: block;
  color: #6f7684;
  font-size: 25rpx;
  line-height: 1.45;
}
.addr-actions {
  display: flex;
  gap: 30rpx;
  margin-top: 10rpx;
  color: #2f78ff;
  font-size: 25rpx;
}
.del { color: #ff4d4f; }
.mask {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: flex-end;
}
.dialog {
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  padding: 32rpx;
  box-sizing: border-box;
}
.dialog-title {
  font-size: 32rpx;
  font-weight: 600;
  display: block;
  margin-bottom: 20rpx;
}
.input {
  height: 82rpx;
  padding: 0 22rpx;
  border-radius: 12rpx;
  background: #f5f7fa;
  margin-bottom: 16rpx;
  font-size: 28rpx;
}
.textarea {
  width: 100%;
  min-height: 140rpx;
  background: #f5f7fa;
  border-radius: 12rpx;
  padding: 18rpx 22rpx;
  margin-bottom: 16rpx;
  box-sizing: border-box;
}
.check {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 20rpx;
  font-size: 26rpx;
}
.primary-btn {
  height: 78rpx;
  line-height: 78rpx;
  border-radius: 999rpx;
  background: linear-gradient(90deg, #3e80ff, #2f78ff);
  color: #fff;
  font-size: 29rpx;
}
</style>
