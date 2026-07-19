<template>
  <div class="profile-page">
    <!-- 左侧：用户信息 + 导航 -->
    <aside class="profile-aside">
      <div class="user-summary">
        <div class="user-avatar clickable" @click="openAvatarDialog">
          <img v-if="displayAvatarUrl" :src="displayAvatarUrl" alt="头像" class="avatar-img" />
          <span v-else>{{ (store.user?.username || store.user?.phone || 'U').charAt(0).toUpperCase() }}</span>
        </div>
        <div class="user-name">{{ store.user?.username || store.user?.phone || '用户' }}</div>
        <div class="user-phone">{{ store.user?.phone || '未绑定手机号' }}</div>
      </div>
      <nav class="profile-nav">
        <div
          class="nav-item"
          :class="{ active: activeTab === 'info' }"
          @click="activeTab = 'info'"
        >
          个人信息
        </div>
        <router-link to="/home/user/order" class="nav-item">我的订单</router-link>
        <div
          class="nav-item"
          :class="{ active: activeTab === 'password' }"
          @click="activeTab = 'password'"
        >
          修改密码
        </div>
      </nav>
    </aside>

    <!-- 右侧：主内容 -->
    <main class="profile-main">
      <!-- 个人信息 -->
      <template v-if="activeTab === 'info'">
        <h1 class="main-title">个人中心</h1>
        <p class="main-subtitle">管理您的个人信息和设置</p>

        <el-card class="info-card" shadow="never">
          <el-form :model="profileForm" label-width="100px" class="info-form">
            <el-form-item label="用户名">
              <el-input v-model="profileForm.username" placeholder="请输入用户名" maxlength="32" show-word-limit clearable />
            </el-form-item>
            <el-form-item label="手机号">
              <el-input v-model="profileForm.phone" disabled placeholder="-" />
              <div class="readonly-tip">手机号唯一，不可修改</div>
            </el-form-item>
            <el-form-item label="姓名">
              <el-input v-model="profileForm.realName" placeholder="选填，请输入姓名" maxlength="32" show-word-limit clearable />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="profileSaving" @click="saveProfile">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <el-card class="address-card" shadow="never">
          <template #header>
            <span>取送地址</span>
            <el-button type="primary" size="small" @click="openAddressForm()">新增地址</el-button>
          </template>
          <div v-if="addressList.length" class="address-list">
            <div v-for="a in addressList" :key="a.id" class="address-item">
              <div class="addr-main">
                <span class="addr-contact">{{ a.contactName }} {{ a.phone }}</span>
                <span class="addr-detail addr-ellipsis" :title="fullAddress(a)">{{ fullAddress(a) }}</span>
              </div>
              <div class="addr-actions">
                <el-button link type="primary" size="small" @click="openAddressForm(a)">编辑</el-button>
                <el-button link type="danger" size="small" @click="onDeleteAddress(a.id)">删除</el-button>
              </div>
            </div>
          </div>
          <el-empty v-else description="暂无取送地址，请点击「新增地址」添加" :image-size="64" />
        </el-card>
      </template>

      <!-- 修改密码 -->
      <template v-if="activeTab === 'password'">
        <h1 class="main-title">修改密码</h1>
        <p class="main-subtitle">请先输入当前密码，再设置新密码</p>

        <el-card class="password-card" shadow="never">
          <el-form :model="passwordForm" label-width="100px" class="password-form">
            <el-form-item label="当前密码" required>
              <el-input v-model="passwordForm.currentPassword" type="password" placeholder="请输入当前密码" show-password clearable />
            </el-form-item>
            <el-form-item label="新密码" required>
              <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码（至少6位）" show-password clearable />
            </el-form-item>
            <el-form-item label="确认新密码" required>
              <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" show-password clearable />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="passwordSaving" @click="savePassword">保存</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </template>
    </main>

    <!-- 更换头像弹窗 -->
    <el-dialog v-model="avatarDialogVisible" title="更换头像" width="420px" @close="avatarUrlInput = ''">
      <div class="avatar-dialog-body">
        <div class="avatar-option">
          <div class="option-label">本地上传</div>
          <el-upload
            :http-request="handleAvatarUpload"
            :show-file-list="false"
            accept="image/jpeg,image/png,image/gif"
          >
            <el-button type="primary" plain size="small">选择图片</el-button>
            <span class="upload-tip">支持 JPG/PNG/GIF，不超过 2MB</span>
          </el-upload>
        </div>
        <div class="avatar-option">
          <div class="option-label">或填写图片地址</div>
          <el-input v-model="avatarUrlInput" placeholder="请输入图片 URL" clearable />
        </div>
        <div v-if="avatarUrlInput || profileForm.avatar" class="avatar-preview">
          <img v-if="previewAvatarUrl" :src="previewAvatarUrl" alt="预览" class="preview-img" />
        </div>
      </div>
      <template #footer>
        <el-button @click="avatarDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmAvatar">确定</el-button>
      </template>
    </el-dialog>

    <!-- 新增/编辑地址弹窗 -->
    <el-dialog v-model="addressFormVisible" :title="editingAddressId ? '编辑地址' : '新增地址'" width="520px">
      <el-form :model="addressForm" label-width="80px">
        <el-form-item label="收货人" required>
          <el-input v-model="addressForm.contactName" placeholder="请输入姓名" maxlength="32" show-word-limit />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="addressForm.phone" placeholder="请输入11位手机号" maxlength="11" inputmode="numeric" />
        </el-form-item>
        <el-form-item label="省市区" required>
          <el-cascader
            v-model="cascadeRegion"
            :options="regionOptionsRef"
            :props="{ expandTrigger: 'hover', checkStrictly: false, emitPath: true }"
            placeholder="请选择省/市/区"
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="详细地址" required>
          <el-input v-model="addressForm.detailAddress" type="textarea" placeholder="街道、楼栋、门牌号等" :rows="2" />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="addressForm.isDefault">设为默认地址</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addressFormVisible = false">取消</el-button>
        <el-button type="primary" :loading="addressSaving" @click="saveAddress">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { updateProfile } from '@/api/auth'
import request from '@/utils/request'
import {
  getAddressList,
  createAddress,
  updateAddress,
  removeAddress,
  type UserAddressItem,
  type AddressCreateParams,
} from '@/api/address'
import { regionOptionsRef, loadBaiduRegion, regionToAddress, addressToRegion } from '@/data/region'

const store = useUserStore()
const activeTab = ref<'info' | 'password'>('info')
const profileSaving = ref(false)
const passwordSaving = ref(false)

const profileForm = ref({
  username: '',
  phone: '',
  realName: '',
  avatar: '',
})
const avatarDialogVisible = ref(false)
const avatarUrlInput = ref('')
const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const addressList = ref<UserAddressItem[]>([])
const addressFormVisible = ref(false)
const addressSaving = ref(false)
const editingAddressId = ref<number | null>(null)
const addressForm = ref<AddressCreateParams & { id?: number }>({
  contactName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false,
})

const cascadeRegion = computed({
  get: () => addressToRegion(addressForm.value.province, addressForm.value.city, addressForm.value.district),
  set: (val: string[] | undefined) => {
    const { province, city, district } = regionToAddress(val)
    addressForm.value.province = province
    addressForm.value.city = city
    addressForm.value.district = district
  },
})

function syncProfileForm() {
  profileForm.value = {
    username: store.user?.username ?? '',
    phone: store.user?.phone ?? '',
    realName: store.user?.realName ?? '',
    avatar: store.user?.avatar ?? '',
  }
}

/** 用于显示的头像 URL：绝对地址直接用，相对地址按当前站点解析 */
function resolveAvatarUrl(url: string | undefined): string {
  if (!url?.trim()) return ''
  const u = url.trim()
  if (u.startsWith('http://') || u.startsWith('https://')) return u
  return u.startsWith('/') ? u : '/' + u
}

const displayAvatarUrl = computed(() => resolveAvatarUrl(store.user?.avatar))
const previewAvatarUrl = computed(() =>
  resolveAvatarUrl(avatarUrlInput.value || profileForm.value.avatar)
)

function openAvatarDialog() {
  avatarUrlInput.value = profileForm.value.avatar || ''
  avatarDialogVisible.value = true
}

async function handleAvatarUpload({ file, onSuccess, onError }: { file: File; onSuccess: (res: any) => void; onError: (err: any) => void }) {
  const formData = new FormData()
  formData.append('file', file)
  try {
    const res = await request.post<any, { url: string }>('/upload/product-image', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    if (res?.url) {
      avatarUrlInput.value = res.url
      onSuccess(res)
    } else {
      onError(new Error('未返回图片地址'))
    }
  } catch (e: any) {
    const msg = e?.response?.data?.message || '上传失败'
    ElMessage.error(msg)
    onError(e)
  }
}

function confirmAvatar() {
  const v = avatarUrlInput.value?.trim()
  profileForm.value.avatar = v || ''
  avatarDialogVisible.value = false
  if (v) ElMessage.success('头像已更新，请点击「保存修改」保存到服务器')
}

function fullAddress(a: UserAddressItem) {
  const parts = [a.province, a.city, a.district, a.detailAddress].filter(Boolean)
  return parts.join(' ') || a.detailAddress
}

function openAddressForm(addr?: UserAddressItem) {
  editingAddressId.value = addr?.id ?? null
  addressForm.value = addr
    ? {
        contactName: addr.contactName,
        phone: addr.phone,
        province: addr.province || '',
        city: addr.city || '',
        district: addr.district || '',
        detailAddress: addr.detailAddress,
        isDefault: addr.isDefault,
      }
    : {
        contactName: '',
        phone: '',
        province: '',
        city: '',
        district: '',
        detailAddress: '',
        isDefault: false,
      }
  addressFormVisible.value = true
}

async function saveProfile() {
  profileSaving.value = true
  try {
    const user = await updateProfile({
      username: profileForm.value.username?.trim() || undefined,
      realName: profileForm.value.realName?.trim() || undefined,
      avatar: profileForm.value.avatar?.trim() || undefined,
    })
    store.setAuth(store.token, user as any)
    ElMessage.success('保存成功')
    syncProfileForm()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '保存失败')
  } finally {
    profileSaving.value = false
  }
}

async function savePassword() {
  const { currentPassword, newPassword, confirmPassword } = passwordForm.value
  if (!currentPassword?.trim()) {
    ElMessage.warning('请输入当前密码')
    return
  }
  if (!newPassword?.trim()) {
    ElMessage.warning('请输入新密码')
    return
  }
  if (newPassword.length < 6) {
    ElMessage.warning('新密码至少6位')
    return
  }
  if (newPassword !== confirmPassword) {
    ElMessage.warning('两次输入的新密码不一致')
    return
  }
  passwordSaving.value = true
  try {
    await updateProfile({
      currentPassword: currentPassword.trim(),
      newPassword: newPassword.trim(),
    })
    ElMessage.success('密码已修改，请使用新密码登录')
    passwordForm.value = { currentPassword: '', newPassword: '', confirmPassword: '' }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '修改失败')
  } finally {
    passwordSaving.value = false
  }
}

async function saveAddress() {
  const f = addressForm.value
  if (!f.contactName?.trim() || !f.phone?.trim() || !f.detailAddress?.trim()) {
    ElMessage.warning('请填写收货人、手机号和详细地址')
    return
  }
  const phone = f.phone.trim()
  if (!/^1[3-9]\d{9}$/.test(phone)) {
    ElMessage.warning('请输入正确的手机号（1开头的11位大陆手机号）')
    return
  }
  if (!f.province?.trim() || !f.city?.trim() || !f.district?.trim()) {
    ElMessage.warning('请选择省/市/区')
    return
  }
  addressSaving.value = true
  try {
    const payload: AddressCreateParams = {
      contactName: f.contactName.trim(),
      phone,
      province: f.province.trim(),
      city: f.city.trim(),
      district: f.district.trim(),
      detailAddress: f.detailAddress.trim(),
      isDefault: f.isDefault,
    }
    if (editingAddressId.value) {
      await updateAddress(editingAddressId.value, payload)
      ElMessage.success('地址已更新')
    } else {
      await createAddress(payload)
      ElMessage.success('地址已添加')
    }
    addressFormVisible.value = false
    loadAddresses()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '保存失败')
  } finally {
    addressSaving.value = false
  }
}

async function onDeleteAddress(id: number) {
  try {
    await ElMessageBox.confirm('确定删除该地址吗？', '提示', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await removeAddress(id)
    ElMessage.success('地址已删除')
    loadAddresses()
  } catch (_) {}
}

function loadAddresses() {
  return getAddressList()
    .then((data) => { addressList.value = data ?? [] })
    .catch(() => { addressList.value = [] })
}

watch(() => store.user, syncProfileForm, { deep: true })

onMounted(() => {
  loadBaiduRegion()
  loadAddresses()
  syncProfileForm()
})
</script>

<style scoped>
.profile-page {
  display: flex;
  gap: 24px;
  max-width: 960px;
  margin: 0 auto;
  padding: 24px 16px;
  min-height: 60vh;
}

.profile-aside {
  width: 220px;
  flex-shrink: 0;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  padding: 24px 0;
}

.user-summary {
  text-align: center;
  padding: 0 16px 20px;
  border-bottom: 1px solid #ebeef5;
}

.user-avatar {
  width: 64px;
  height: 64px;
  margin: 0 auto 12px;
  border-radius: 50%;
  background: linear-gradient(135deg, #409eff, #66b1ff);
  color: #fff;
  font-size: 28px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.user-avatar.clickable {
  cursor: pointer;
  transition: opacity 0.2s;
}

.user-avatar.clickable:hover {
  opacity: 0.9;
}

.user-avatar .avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-dialog-body {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.avatar-option {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.avatar-option .option-label {
  font-size: 18px;
  color: #606266;
}

.avatar-option .upload-tip {
  font-size: 18px;
  color: #909399;
  margin-left: 8px;
}

.avatar-preview {
  margin-top: 8px;
  text-align: center;
}

.avatar-preview .preview-img {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid #ebeef5;
}

.user-name {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.user-phone {
  font-size: 18px;
  color: #909399;
}

.profile-nav {
  padding: 12px 0;
}

.nav-item {
  display: block;
  padding: 12px 24px;
  font-size: 18px;
  color: #606266;
  text-decoration: none;
  cursor: pointer;
  transition: color 0.2s, background 0.2s;
}

.nav-item:hover {
  color: #409eff;
  background: #ecf5ff;
}

.nav-item.active {
  color: #409eff;
  font-weight: 500;
  background: #ecf5ff;
  border-right: 3px solid #409eff;
}

.profile-main {
  flex: 1;
  min-width: 0;
}

.main-title {
  font-size: 26px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.main-subtitle {
  font-size: 18px;
  color: #909399;
  margin: 0 0 24px 0;
}

.info-card,
.address-card,
.password-card {
  border-radius: 12px;
  margin-bottom: 20px;
}

.info-card :deep(.el-card__header),
.address-card :deep(.el-card__header),
.password-card :deep(.el-card__header) {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 500;
  color: #303133;
}

.info-form,
.password-form {
  max-width: 480px;
}

.readonly-tip {
  font-size: 18px;
  color: #909399;
  margin-top: 4px;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fafafa;
}

.addr-main {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}

.addr-contact {
  font-weight: 500;
  color: #303133;
  margin-right: 8px;
}

.addr-detail {
  font-size: 18px;
  color: #909399;
  display: block;
  margin-top: 4px;
}

.addr-ellipsis {
  min-width: 0;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.addr-actions {
  flex-shrink: 0;
}

@media (max-width: 768px) {
  .profile-page {
    flex-direction: column;
  }
  .profile-aside {
    width: 100%;
  }
}
</style>
