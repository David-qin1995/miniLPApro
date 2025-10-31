<template>
  <div class="notifications-view">
    <div class="toolbar">
      <el-input
        v-model="searchText"
        :placeholder="$t('notification.search')"
        class="search-box"
        clearable
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
      
      <div class="toolbar-actions">
        <el-button 
          v-if="selectedNotifications.length > 0"
          type="primary"
          @click="batchProcess"
        >
          <el-icon><Check /></el-icon>
          {{ $t('notification.batchProcess') }}
        </el-button>
        <el-button 
          v-if="selectedNotifications.length > 0"
          type="danger"
          @click="batchDelete"
        >
          <el-icon><Delete /></el-icon>
          {{ $t('notification.batchDelete') }}
        </el-button>
        <el-button @click="refreshNotifications">
          <el-icon><Refresh /></el-icon>
          {{ $t('notification.refresh') }}
        </el-button>
      </div>
    </div>
    
    <el-table
      :data="filteredNotifications"
      v-loading="loading"
      @selection-change="handleSelectionChange"
      style="width: 100%"
    >
      <el-table-column type="selection" width="55" />
      <el-table-column 
        prop="seqNumber" 
        :label="$t('notification.seqNumber')" 
        width="100"
      />
      <el-table-column 
        prop="type" 
        :label="$t('notification.type')" 
        width="120"
      >
        <template #default="{ row }">
          <el-tag :type="getTypeTagType(row.type)" size="small">
            {{ $t(`notification.${row.type}`) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column 
        prop="profileIccid" 
        :label="$t('notification.profileIccid')"
      />
      <el-table-column 
        prop="notificationAddress" 
        :label="$t('notification.notificationAddress')"
      />
      <el-table-column 
        prop="createdAt" 
        :label="$t('notification.createdAt')" 
        width="180"
      >
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column 
        :label="$t('notification.processed')" 
        width="100"
      >
        <template #default="{ row }">
          <el-tag :type="row.processed ? 'success' : 'warning'" size="small">
            {{ row.processed ? $t('notification.processed') : $t('notification.unprocessed') }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column :label="$t('common.actions')" width="180" fixed="right">
        <template #default="{ row }">
          <el-button 
            v-if="!row.processed"
            type="primary" 
            size="small"
            @click="processNotification(row)"
          >
            {{ $t('notification.process') }}
          </el-button>
          <el-button 
            type="danger" 
            size="small"
            @click="deleteNotification(row)"
          >
            {{ $t('notification.remove') }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <div v-if="filteredNotifications.length === 0 && !loading" class="empty-state">
      <div class="empty-icon">🔔</div>
      <div class="empty-text">{{ $t('common.noData') }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Search, 
  Refresh, 
  Check, 
  Delete 
} from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import dayjs from 'dayjs'
import * as notificationsApi from '@/api/notifications'

const { t } = useI18n()

const searchText = ref('')
const loading = ref(false)
const notifications = ref([])
const selectedNotifications = ref([])

const filteredNotifications = computed(() => {
  if (!searchText.value) return notifications.value
  
  const text = searchText.value.toLowerCase()
  return notifications.value.filter(notification => 
    notification.type?.toLowerCase().includes(text) ||
    notification.profileIccid?.toLowerCase().includes(text) ||
    notification.notificationAddress?.toLowerCase().includes(text)
  )
})

onMounted(() => {
  refreshNotifications()
})

const refreshNotifications = async () => {
  loading.value = true
  try {
    const response = await notificationsApi.getNotifications()
    if (response.success) {
      notifications.value = response.data
    }
  } catch (error) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

const handleSelectionChange = (selection) => {
  selectedNotifications.value = selection
}

const processNotification = async (notification) => {
  try {
    await notificationsApi.processNotification(notification.id)
    ElMessage.success(t('notification.processSuccess'))
    await refreshNotifications()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const deleteNotification = async (notification) => {
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
    
    await notificationsApi.deleteNotification(notification.id)
    ElMessage.success(t('notification.deleteSuccess'))
    await refreshNotifications()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message)
    }
  }
}

const batchProcess = async () => {
  try {
    const ids = selectedNotifications.value.map(n => n.id)
    await notificationsApi.batchProcessNotifications(ids)
    ElMessage.success(t('notification.batchProcessSuccess'))
    await refreshNotifications()
    selectedNotifications.value = []
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const batchDelete = async () => {
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
    
    const ids = selectedNotifications.value.map(n => n.id)
    await notificationsApi.batchDeleteNotifications(ids)
    ElMessage.success(t('notification.batchDeleteSuccess'))
    await refreshNotifications()
    selectedNotifications.value = []
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message)
    }
  }
}

const getTypeTagType = (type) => {
  const typeMap = {
    install: 'success',
    enable: 'primary',
    disable: 'warning',
    delete: 'danger'
  }
  return typeMap[type] || 'info'
}

const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss')
}
</script>

<style scoped lang="scss">
.notifications-view {
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
}

@media (max-width: 768px) {
  .toolbar {
    flex-direction: column;
    
    .search-box {
      max-width: 100%;
    }
    
    .toolbar-actions {
      width: 100%;
      flex-wrap: wrap;
      
      .el-button {
        flex: 1;
      }
    }
  }
}
</style>

