import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  { path: '/', redirect: '/home' },
  {
    path: '/home',
    component: () => import('@/layouts/FrontLayout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('@/views/front/Home.vue') },
      { path: 'login', name: 'Login', component: () => import('@/views/front/Login.vue') },
      { path: 'register', name: 'Register', component: () => import('@/views/front/Register.vue') },
      { path: 'user', redirect: '/user/service' },
      { path: 'user/service', name: 'ServiceList', component: () => import('@/views/user/ServiceList.vue') },
      { path: 'user/service/:id', name: 'ServiceDetail', component: () => import('@/views/user/ServiceDetail.vue') },
      { path: 'user/product', name: 'ProductList', component: () => import('@/views/user/ProductList.vue') },
      { path: 'user/product/:id', name: 'ProductDetail', component: () => import('@/views/user/ProductDetail.vue') },
      { path: 'user/cart', name: 'Cart', component: () => import('@/views/user/Cart.vue') },
      { path: 'user/checkout', name: 'Checkout', component: () => import('@/views/user/Checkout.vue') },
      { path: 'user/store', name: 'NearbyStore', component: () => import('@/views/user/NearbyStore.vue') },
      { path: 'user/ai', name: 'AiAssistant', component: () => import('@/views/user/AiAssistant.vue') },
      { path: 'user/order', name: 'MyOrders', component: () => import('@/views/user/MyOrders.vue') },
      { path: 'user/order/pay', name: 'OrderPay', component: () => import('@/views/user/OrderPay.vue') },
      { path: 'user/order/create', name: 'OrderCreate', component: () => import('@/views/user/OrderCreate.vue') },
      { path: 'user/comment/:targetType/:targetId', name: 'CommentList', component: () => import('@/views/user/CommentList.vue') },
      { path: 'user/profile', name: 'Profile', component: () => import('@/views/user/Profile.vue') },
    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach((to, _from, next) => {
  const store = useUserStore()
  const needAuth =
    to.path.startsWith('/home/user/order') ||
    to.path.startsWith('/home/user/checkout') ||
    to.path.startsWith('/home/user/cart') ||
    to.path.startsWith('/home/user/profile')
  if (needAuth && !store.token) {
    next({ path: '/home/login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
