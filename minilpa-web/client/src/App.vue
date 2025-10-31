<template>
  <el-config-provider :locale="elementLocale">
    <div id="app" :class="{ 'dark-mode': isDarkMode }">
      <router-view />
    </div>
  </el-config-provider>
</template>

<script setup>
import { computed, watch, onMounted } from 'vue'
import { useSettingsStore } from './stores/settings'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import en from 'element-plus/dist/locale/en.mjs'
import ja from 'element-plus/dist/locale/ja.mjs'
import de from 'element-plus/dist/locale/de.mjs'

const settingsStore = useSettingsStore()

const isDarkMode = computed(() => settingsStore.isDarkMode)

const elementLocale = computed(() => {
  const locales = {
    'zh-CN': zhCn,
    'en-US': en,
    'ja-JP': ja,
    'de-DE': de
  }
  return locales[settingsStore.settings.language] || zhCn
})

// 监听主题变化
watch(isDarkMode, (dark) => {
  if (dark) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}, { immediate: true })

onMounted(() => {
  settingsStore.loadSettings()
})
</script>

<style lang="scss">
#app {
  min-height: 100vh;
  transition: background-color 0.3s, color 0.3s;
}

.dark-mode {
  background-color: #1a1a1a;
  color: #e0e0e0;
}
</style>

