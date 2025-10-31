import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { getSettings, updateSettings } from '@/api/settings'

export const useSettingsStore = defineStore('settings', () => {
  const settings = ref({
    language: 'zh-CN',
    theme: 'auto',
    daytimeTheme: 'light',
    nighttimeTheme: 'dark',
    autoNightMode: 'SYSTEM',
    emojiDesign: 'twemoji',
    behavior: {
      sendInstallNotification: false,
      removeInstallNotification: false,
      sendEnableNotification: false,
      removeEnableNotification: false,
      sendDisableNotification: false,
      removeDisableNotification: false,
      sendDeleteNotification: false,
      removeDeleteNotification: false
    }
  })

  const isDarkMode = computed(() => {
    if (settings.value.theme === 'dark') return true
    if (settings.value.theme === 'light') return false
    
    // Auto mode: check system preference
    if (settings.value.autoNightMode === 'SYSTEM') {
      return window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    
    // Auto mode: check time
    if (settings.value.autoNightMode === 'TIME') {
      const hour = new Date().getHours()
      return hour >= 18 || hour < 6
    }
    
    return false
  })

  async function loadSettings() {
    try {
      const response = await getSettings()
      if (response.success) {
        settings.value = response.data
      }
    } catch (error) {
      console.error('Failed to load settings:', error)
    }
  }

  async function saveSettings(newSettings) {
    try {
      const response = await updateSettings(newSettings)
      if (response.success) {
        settings.value = { ...settings.value, ...newSettings }
      }
      return response
    } catch (error) {
      console.error('Failed to save settings:', error)
      throw error
    }
  }

  return {
    settings,
    isDarkMode,
    loadSettings,
    saveSettings
  }
})

