<template>
  <div class="profiles-view">
    <div class="toolbar">
      <el-input
        v-model="searchText"
        :placeholder="$t('profile.search')"
        class="search-box"
        clearable
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
      
      <div class="toolbar-actions">
        <el-button type="primary" @click="showDownloadDialog = true">
          <el-icon><Download /></el-icon>
          {{ $t('profile.download') }}
        </el-button>
        <el-button @click="refreshProfiles">
          <el-icon><Refresh /></el-icon>
          {{ $t('profile.refresh') }}
        </el-button>
      </div>
    </div>
    
    <el-row :gutter="16" v-loading="profilesStore.loading">
      <el-col 
        v-for="profile in filteredProfiles" 
        :key="profile.id"
        :xs="24" 
        :sm="12" 
        :md="8" 
        :lg="6"
      >
        <el-card class="profile-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="profile-icon">{{ profile.icon }}</span>
              <el-tag 
                :type="profile.state === 'enabled' ? 'success' : 'info'"
                size="small"
              >
                {{ profile.state === 'enabled' ? $t('profile.enabled') : $t('profile.disabled') }}
              </el-tag>
            </div>
          </template>
          
          <div class="profile-info">
            <h3 class="profile-name">{{ profile.nickname || profile.name }}</h3>
            <p class="profile-provider">{{ profile.provider }}</p>
            <el-divider />
            <div class="profile-detail">
              <span class="label">{{ $t('profile.iccid') }}:</span>
              <span class="value">{{ profile.iccid }}</span>
            </div>
          </div>
          
          <template #footer>
            <el-button-group class="profile-actions">
              <el-button 
                size="small" 
                :type="profile.state === 'enabled' ? 'danger' : 'success'"
                @click="toggleProfile(profile)"
              >
                {{ profile.state === 'enabled' ? $t('profile.disable') : $t('profile.enable') }}
              </el-button>
              <el-button size="small" @click="editProfile(profile)">
                <el-icon><Edit /></el-icon>
              </el-button>
              <el-button 
                size="small" 
                type="danger" 
                @click="confirmDelete(profile)"
              >
                <el-icon><Delete /></el-icon>
              </el-button>
            </el-button-group>
          </template>
        </el-card>
      </el-col>
    </el-row>
    
    <div v-if="filteredProfiles.length === 0 && !profilesStore.loading" class="empty-state">
      <div class="empty-icon">📱</div>
      <div class="empty-text">{{ $t('common.noData') }}</div>
    </div>
    
    <!-- 下载对话框 -->
    <el-dialog 
      v-model="showDownloadDialog" 
      :title="$t('profile.download')"
      width="500px"
    >
      <div class="download-form">
        <div 
          class="drop-area"
          :class="{ 'drag-over': isDragOver }"
          @drop.prevent="handleDrop"
          @dragover.prevent="isDragOver = true"
          @dragleave="isDragOver = false"
          @click="triggerFileInput"
          @paste="handlePaste"
        >
          <p>{{ $t('profile.dragQRCode') }}</p>
          <p>{{ $t('profile.pasteQRCode') }}</p>
          <input 
            ref="fileInput" 
            type="file" 
            accept="image/*" 
            style="display: none"
            @change="handleFileSelect"
          >
        </div>
        
        <el-divider>{{ $t('common.or') }}</el-divider>
        
        <el-form :model="downloadForm" label-width="120px">
          <el-form-item :label="$t('profile.activationCode')">
            <el-input 
              v-model="downloadForm.activationCode"
              type="textarea"
              :rows="3"
              :placeholder="$t('profile.enterActivationCode')"
            />
          </el-form-item>
          <el-form-item :label="$t('profile.nickname')">
            <el-input v-model="downloadForm.nickname" />
          </el-form-item>
        </el-form>
      </div>
      
      <template #footer>
        <el-button @click="showDownloadDialog = false">{{ $t('common.cancel') }}</el-button>
        <el-button type="primary" @click="downloadProfile" :loading="downloading">
          {{ $t('common.confirm') }}
        </el-button>
      </template>
    </el-dialog>
    
    <!-- 编辑对话框 -->
    <el-dialog 
      v-model="showEditDialog" 
      :title="$t('profile.edit')"
      width="400px"
    >
      <el-form :model="editForm" label-width="100px">
        <el-form-item :label="$t('profile.nickname')">
          <el-input v-model="editForm.nickname" />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="showEditDialog = false">{{ $t('common.cancel') }}</el-button>
        <el-button type="primary" @click="saveProfile">{{ $t('common.save') }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Search, 
  Download, 
  Refresh, 
  Edit, 
  Delete 
} from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import { useProfilesStore } from '@/stores/profiles'
import { parseQRCode, parseText } from '@/api/qrcode'

const { t } = useI18n()
const profilesStore = useProfilesStore()

const searchText = ref('')
const showDownloadDialog = ref(false)
const showEditDialog = ref(false)
const downloading = ref(false)
const isDragOver = ref(false)
const fileInput = ref(null)

const downloadForm = ref({
  activationCode: '',
  confirmationCode: '',
  matchingId: '',
  smdpAddress: '',
  nickname: ''
})

const editForm = ref({
  id: '',
  nickname: ''
})

const filteredProfiles = computed(() => {
  if (!searchText.value) return profilesStore.profiles
  
  const text = searchText.value.toLowerCase()
  return profilesStore.profiles.filter(profile => 
    profile.name?.toLowerCase().includes(text) ||
    profile.nickname?.toLowerCase().includes(text) ||
    profile.iccid?.toLowerCase().includes(text) ||
    profile.provider?.toLowerCase().includes(text)
  )
})

onMounted(() => {
  refreshProfiles()
})

const refreshProfiles = async () => {
  await profilesStore.fetchProfiles()
}

const toggleProfile = async (profile) => {
  try {
    if (profile.state === 'enabled') {
      await profilesStore.disableProfile(profile.id)
      ElMessage.success(t('profile.disableSuccess'))
    } else {
      await profilesStore.enableProfile(profile.id)
      ElMessage.success(t('profile.enableSuccess'))
    }
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const editProfile = (profile) => {
  editForm.value = {
    id: profile.id,
    nickname: profile.nickname
  }
  showEditDialog.value = true
}

const saveProfile = async () => {
  try {
    await profilesStore.updateProfile(editForm.value.id, {
      nickname: editForm.value.nickname
    })
    ElMessage.success(t('profile.updateSuccess'))
    showEditDialog.value = false
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const confirmDelete = async (profile) => {
  try {
    await ElMessageBox.confirm(
      t('common.deleteWarning'),
      t('common.warning'),
      {
        confirmButtonText: t('common.confirm'),
        cancelButtonText: t('common.cancel'),
        type: 'warning'
      }
    )
    
    await profilesStore.deleteProfile(profile.id)
    ElMessage.success(t('profile.deleteSuccess'))
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message)
    }
  }
}

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileSelect = async (event) => {
  const file = event.target.files[0]
  if (file) {
    await parseQRCodeImage(file)
  }
}

const handleDrop = async (event) => {
  isDragOver.value = false
  const file = event.dataTransfer.files[0]
  if (file && file.type.startsWith('image/')) {
    await parseQRCodeImage(file)
  } else {
    const text = event.dataTransfer.getData('text')
    if (text) {
      await parseActivationCode(text)
    }
  }
}

const handlePaste = async (event) => {
  const items = event.clipboardData?.items
  if (!items) return
  
  for (const item of items) {
    if (item.type.startsWith('image/')) {
      const file = item.getAsFile()
      if (file) {
        await parseQRCodeImage(file)
        return
      }
    }
  }
  
  const text = event.clipboardData?.getData('text')
  if (text) {
    await parseActivationCode(text)
  }
}

const parseQRCodeImage = async (file) => {
  try {
    const response = await parseQRCode(file)
    if (response.success) {
      Object.assign(downloadForm.value, response.data)
      ElMessage.success(t('common.success'))
    }
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const parseActivationCode = async (text) => {
  try {
    const response = await parseText(text)
    if (response.success) {
      Object.assign(downloadForm.value, response.data)
      ElMessage.success(t('common.success'))
    }
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const downloadProfile = async () => {
  downloading.value = true
  try {
    await profilesStore.addProfile(downloadForm.value)
    ElMessage.success(t('profile.downloadSuccess'))
    showDownloadDialog.value = false
    downloadForm.value = {
      activationCode: '',
      confirmationCode: '',
      matchingId: '',
      smdpAddress: '',
      nickname: ''
    }
  } catch (error) {
    ElMessage.error(error.message)
  } finally {
    downloading.value = false
  }
}
</script>

<style scoped lang="scss">
.profiles-view {
  .toolbar {
    margin-bottom: 20px;
    display: flex;
    gap: 16px;
    
    .search-box {
      flex: 1;
      max-width: 400px;
    }
    
    .toolbar-actions {
      display: flex;
      gap: 8px;
    }
  }
  
  .profile-card {
    margin-bottom: 16px;
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .profile-icon {
        font-size: 24px;
      }
    }
    
    .profile-info {
      .profile-name {
        font-size: 16px;
        font-weight: 600;
        margin-bottom: 4px;
      }
      
      .profile-provider {
        font-size: 12px;
        color: var(--el-text-color-secondary);
        margin-bottom: 12px;
      }
      
      .profile-detail {
        font-size: 12px;
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        
        .label {
          color: var(--el-text-color-secondary);
        }
        
        .value {
          font-family: monospace;
        }
      }
    }
    
    .profile-actions {
      width: 100%;
      display: flex;
    }
  }
  
  .download-form {
    .drop-area {
      border: 2px dashed var(--el-border-color);
      border-radius: 8px;
      padding: 40px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;
      
      &:hover,
      &.drag-over {
        border-color: var(--el-color-primary);
        background-color: var(--el-fill-color-light);
      }
      
      p {
        margin: 8px 0;
        color: var(--el-text-color-secondary);
      }
    }
  }
}

@media (max-width: 768px) {
  .toolbar {
    flex-direction: column;
    
    .search-box {
      max-width: 100%;
    }
    
    .toolbar-actions {
      width: 100%;
      
      .el-button {
        flex: 1;
      }
    }
  }
}
</style>

