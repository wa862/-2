import { createSSRApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import AiFloat from '@/components/AiFloat.vue'

export function createApp() {
  const app = createSSRApp(App)
  app.use(createPinia())
  app.component('AiFloat', AiFloat)
  return { app }
}
