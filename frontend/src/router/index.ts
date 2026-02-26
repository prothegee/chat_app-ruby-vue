import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: () => import('@/App.vue'),
      meta: { title: 'Chat App; Ruby x Vue' },
    },
  ],
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title || 'Default Title'
  next()
})

export default router
