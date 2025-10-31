<template>
  <el-container class="layout-container">
    <el-aside width="200px">
      <div class="logo">
        <h2>{{ $t('app.title') }}</h2>
      </div>
      <el-menu
        :default-active="currentRoute"
        router
        class="sidebar-menu"
        :collapse="isCollapse"
      >
        <el-menu-item index="/profiles">
          <el-icon><Tickets /></el-icon>
          <span class="menu-text">{{ $t('nav.profile') }}</span>
        </el-menu-item>
        <el-menu-item index="/notifications">
          <el-icon><Bell /></el-icon>
          <span class="menu-text">{{ $t('nav.notification') }}</span>
        </el-menu-item>
        <el-menu-item index="/chip">
          <el-icon><Cpu /></el-icon>
          <span class="menu-text">{{ $t('nav.chip') }}</span>
        </el-menu-item>
        <el-menu-item index="/settings">
          <el-icon><Setting /></el-icon>
          <span class="menu-text">{{ $t('nav.setting') }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    
    <el-container>
      <el-header>
        <div class="header-left">
          <el-icon class="menu-toggle" @click="toggleCollapse">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleThemeChange">
            <el-icon size="20"><Sunny /></el-icon>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="auto">{{ $t('setting.auto') }}</el-dropdown-item>
                <el-dropdown-item command="light">{{ $t('setting.light') }}</el-dropdown-item>
                <el-dropdown-item command="dark">{{ $t('setting.dark') }}</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      
      <el-main>
        <transition name="fade" mode="out-in">
          <router-view />
        </transition>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useSettingsStore } from '@/stores/settings'
import { 
  Tickets, 
  Bell, 
  Cpu, 
  Setting, 
  Fold, 
  Expand, 
  Sunny 
} from '@element-plus/icons-vue'

const route = useRoute()
const settingsStore = useSettingsStore()
const isCollapse = ref(false)

const currentRoute = computed(() => route.path)

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleThemeChange = async (theme) => {
  await settingsStore.saveSettings({ theme })
}
</script>

<style scoped lang="scss">
.layout-container {
  min-height: 100vh;
}

.el-aside {
  background-color: var(--el-bg-color);
  border-right: 1px solid var(--el-border-color);
  transition: width 0.3s;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid var(--el-border-color);
  
  h2 {
    font-size: 18px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }
}

.sidebar-menu {
  border-right: none;
  height: calc(100vh - 60px);
}

.el-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--el-border-color);
  background-color: var(--el-bg-color);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  
  .menu-toggle {
    font-size: 20px;
    cursor: pointer;
    transition: color 0.3s;
    
    &:hover {
      color: var(--el-color-primary);
    }
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
  
  .el-icon {
    cursor: pointer;
    transition: color 0.3s;
    
    &:hover {
      color: var(--el-color-primary);
    }
  }
}

.el-main {
  background-color: var(--el-bg-color-page);
  padding: 20px;
}

@media (max-width: 768px) {
  .el-aside {
    width: 60px !important;
  }
  
  .logo h2 {
    display: none;
  }
}
</style>

