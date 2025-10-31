<template>
  <div class="chip-view">
    <el-row :gutter="20" v-loading="loading">
      <el-col :xs="24" :sm="24" :md="12">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>{{ $t('chip.title') }}</span>
              <el-button size="small" @click="refreshChipInfo">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          
          <el-descriptions :column="1" border v-if="chipInfo">
            <el-descriptions-item :label="$t('chip.eid')">
              <span class="mono-text">{{ chipInfo.eid }}</span>
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.platformVersion')">
              {{ chipInfo.platformVersion }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.platformLabel')">
              {{ chipInfo.platformLabel }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.freeSpace')">
              {{ formatBytes(chipInfo.freeSpace) }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.totalSpace')">
              {{ formatBytes(chipInfo.totalSpace) }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="12">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>{{ $t('chip.euiccInfo') }}</span>
            </div>
          </template>
          
          <el-descriptions :column="1" border v-if="chipInfo">
            <el-descriptions-item :label="$t('chip.svn')">
              {{ chipInfo.euiccInfo.svn }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.euiccFirmwareVer')">
              {{ chipInfo.euiccInfo.euiccFirmwareVer }}
            </el-descriptions-item>
            <el-descriptions-item label="Ext Card Resource">
              <span class="mono-text">{{ chipInfo.euiccInfo.extCardResource }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="UICC Capability">
              <span class="mono-text">{{ chipInfo.euiccInfo.uiccCapability }}</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="12">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>{{ $t('chip.manufacturer') }}</span>
            </div>
          </template>
          
          <el-descriptions :column="1" border v-if="chipInfo">
            <el-descriptions-item :label="$t('chip.commonName')">
              {{ chipInfo.manufacturer.name }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.productionDate')">
              {{ formatDate(chipInfo.manufacturer.productionDate) }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="12">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>{{ $t('chip.certificateIssuer') }}</span>
              <el-button size="small" @click="showCertificate">
                {{ $t('chip.viewCertificate') }}
              </el-button>
            </div>
          </template>
          
          <el-descriptions :column="1" border v-if="chipInfo">
            <el-descriptions-item :label="$t('chip.commonName')">
              {{ chipInfo.certificateIssuer.commonName }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.country')">
              {{ chipInfo.certificateIssuer.country }}
            </el-descriptions-item>
            <el-descriptions-item :label="$t('chip.organization')">
              {{ chipInfo.certificateIssuer.organization }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 证书对话框 -->
    <el-dialog 
      v-model="showCertificateDialog" 
      :title="$t('chip.certificate')"
      width="600px"
    >
      <el-descriptions :column="1" border v-if="certificate">
        <el-descriptions-item :label="$t('chip.subject')">
          <div>
            <p>CN: {{ certificate.subject.commonName }}</p>
            <p>O: {{ certificate.subject.organization }}</p>
            <p>C: {{ certificate.subject.country }}</p>
          </div>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('chip.issuer')">
          <div>
            <p>CN: {{ certificate.issuer.commonName }}</p>
            <p>O: {{ certificate.issuer.organization }}</p>
            <p>C: {{ certificate.issuer.country }}</p>
          </div>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('chip.serialNumber')">
          <span class="mono-text">{{ certificate.serialNumber }}</span>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('chip.validFrom')">
          {{ formatDate(certificate.validFrom) }}
        </el-descriptions-item>
        <el-descriptions-item :label="$t('chip.validTo')">
          {{ formatDate(certificate.validTo) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import { useI18n } from 'vue-i18n'
import dayjs from 'dayjs'
import * as chipApi from '@/api/chip'

const { t } = useI18n()

const loading = ref(false)
const chipInfo = ref(null)
const certificate = ref(null)
const showCertificateDialog = ref(false)

onMounted(() => {
  refreshChipInfo()
})

const refreshChipInfo = async () => {
  loading.value = true
  try {
    const response = await chipApi.getChipInfo()
    if (response.success) {
      chipInfo.value = response.data
    }
  } catch (error) {
    ElMessage.error(error.message)
  } finally {
    loading.value = false
  }
}

const showCertificate = async () => {
  try {
    const response = await chipApi.getChipCertificate()
    if (response.success) {
      certificate.value = response.data
      showCertificateDialog.value = true
    }
  } catch (error) {
    ElMessage.error(error.message)
  }
}

const formatBytes = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const formatDate = (date) => {
  return dayjs(date).format('YYYY-MM-DD HH:mm:ss')
}
</script>

<style scoped lang="scss">
.chip-view {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .mono-text {
    font-family: 'Courier New', Courier, monospace;
    font-size: 13px;
  }
  
  .el-card {
    margin-bottom: 20px;
  }
}
</style>

