import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', name: 'Login', component: () => import('@/views/Login.vue'), meta: { public: true } },
  {
    path: '/',
    component: () => import('@/layouts/AdminLayout.vue'),
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/views/Dashboard.vue') },
      { path: 'service', name: 'ServiceManage', component: () => import('@/views/ServiceManage.vue') },
      { path: 'product', name: 'ProductManage', component: () => import('@/views/ProductManage.vue') },
      { path: 'order', name: 'OrderManage', component: () => import('@/views/OrderManage.vue') },
      { path: 'user', name: 'UserManage', component: () => import('@/views/UserManage.vue') },
      { path: 'store', name: 'StoreManage', component: () => import('@/views/StoreManage.vue') },
      { path: 'comment', name: 'CommentManage', component: () => import('@/views/CommentManage.vue') },
      { path: 'ai-knowledge', name: 'AiKnowledgeManage', component: () => import('@/views/AiKnowledgeManage.vue') },
      { path: 'settings', name: 'SystemSettings', component: () => import('@/views/SystemSettings.vue') },
    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach((to, _from, next) => {
  const store = useUserStore()
  if (to.meta.public) {
    next()
    return
  }
  if (!store.token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
