import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    component: () => import('@/views/Layout.vue'),
    redirect: '/profiles',
    children: [
      {
        path: 'profiles',
        name: 'Profiles',
        component: () => import('@/views/Profiles.vue'),
        meta: { title: 'Profile', icon: 'Tickets' }
      },
      {
        path: 'notifications',
        name: 'Notifications',
        component: () => import('@/views/Notifications.vue'),
        meta: { title: 'Notification', icon: 'Bell' }
      },
      {
        path: 'chip',
        name: 'Chip',
        component: () => import('@/views/Chip.vue'),
        meta: { title: 'Chip', icon: 'Cpu' }
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/Settings.vue'),
        meta: { title: 'Setting', icon: 'Setting' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router

