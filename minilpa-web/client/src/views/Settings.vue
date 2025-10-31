<template>
  <div class="settings-view">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <span>{{ $t('setting.title') }}</span>
          <el-button type="danger" plain @click="resetSettings">
            {{ $t('setting.reset') }}
          </el-button>
        </div>
      </template>
      
      <el-form :model="settings" label-width="180px" v-loading="loading">
        <el-divider content-position="left">{{ $t('setting.language') }}</el-divider>
        
        <el-form-item :label="$t('setting.language')">
          <el-select v-model="settings.language" @change="handleLanguageChange">
            <el-option label="简体中文" value="zh-CN" />
            <el-option label="English" value="en-US" />
            <el-option label="日本語" value="ja-JP" />
            <el-option label="Deutsch" value="de-DE" />
          </el-select>
        </el-form-item>
        
        <el-divider content-position="left">{{ $t('setting.theme') }}</el-divider>
        
        <el-form-item :label="$t('setting.theme')">
          <el-radio-group v-model="settings.theme">
            <el-radio label="auto">{{ $t('setting.auto') }}</el-radio>
            <el-radio label="light">{{ $t('setting.light') }}</el-radio>
            <el-radio label="dark">{{ $t('setting.dark') }}</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item :label="$t('setting.autoNightMode')">
          <el-radio-group v-model="settings.autoNightMode">
            <el-radio label="SYSTEM">{{ $t('setting.system') }}</el-radio>
            <el-radio label="TIME">{{ $t('setting.time') }}</el-radio>
            <el-radio label="DISABLED">{{ $t('setting.disabled') }}</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item :label="$t('setting.emojiDesign')">
          <el-radio-group v-model="settings.emojiDesign">
            <el-radio label="twemoji">Twemoji</el-radio>
            <el-radio label="emojitwo">EmojiTwo</el-radio>
            <el-radio label="openmoji">OpenMoji</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-divider content-position="left">{{ $t('setting.behavior') }}</el-divider>
        
        <el-form-item :label="$t('setting.sendInstallNotification')">
          <el-switch v-model="settings.behavior.sendInstallNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.removeInstallNotification')">
          <el-switch v-model="settings.behavior.removeInstallNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.sendEnableNotification')">
          <el-switch v-model="settings.behavior.sendEnableNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.removeEnableNotification')">
          <el-switch v-model="settings.behavior.removeEnableNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.sendDisableNotification')">
          <el-switch v-model="settings.behavior.sendDisableNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.removeDisableNotification')">
          <el-switch v-model="settings.behavior.removeDisableNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.sendDeleteNotification')">
          <el-switch v-model="settings.behavior.sendDeleteNotification" />
        </el-form-item>
        
        <el-form-item :label="$t('setting.removeDeleteNotification')">
          <el-switch v-model="settings.behavior.removeDeleteNotification" />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="saveSettings">
            {{ $t('common.save') }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import { useSettingsStore } from '@/stores/settings'
import * as settingsApi from '@/api/settings'

const { t, locale } = useI18n()
const settingsStore = useSettingsStore()

const loading = ref(false)
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

onMounted(async () => {
  await loadSettings()
})

const loadSettings = async () => {
  loading.value = true
  try {
    const response = await settingsApi.getSettings()
    if (response.success) {
      settings.value = response.data
    }
  } catch (error) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

const saveSettings = async () => {
  loading.value = true
  try {
    await settingsStore.saveSettings(settings.value)
    ElMessage.success(t('setting.saveSuccess'))
  } catch (error) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

const resetSettings = async () => {
  try {
    await ElMessageBox.confirm(
      t('common.confirmDelete'),
      t('common.warning'),
      {
        confirmButtonText: t('common.confirm'),
        cancelButtonText: t('common.cancel'),
        type: 'warning'
      }
    )
    
    loading.value = true
    const response = await settingsApi.resetSettings()
    if (response.success) {
      settings.value = response.data
      ElMessage.success(t('setting.resetSuccess'))
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message)
    }
  } finally {
    loading.value = false
  }
}

const handleLanguageChange = (lang) => {
  locale.value = lang
  localStorage.setItem('language', lang)
}
</script>

<style scoped lang="scss">
.settings-view {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .el-form {
    max-width: 800px;
  }
  
  .el-divider {
    margin: 24px 0;
  }
}
</style>

