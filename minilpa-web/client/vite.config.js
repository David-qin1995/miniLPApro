import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      },
      '/uploads': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    // 优化构建性能
    minify: 'esbuild', // 使用 esbuild 压缩（比 terser 快 10-20 倍）
    chunkSizeWarningLimit: 1000,
    // 优化 rollup 选项（代码分割）
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-vendor': ['vue', 'vue-router', 'pinia'],
          'element-vendor': ['element-plus', '@element-plus/icons-vue'],
          'utils-vendor': ['axios', 'dayjs', 'lodash-es', 'vue-i18n']
        }
      }
    },
    // 提高构建性能
    target: 'es2015',
    cssCodeSplit: true
  },
  // 优化 CSS 构建（减少 Sass 警告）
  css: {
    preprocessorOptions: {
      scss: {
        // 静默 Sass 弃用警告（不影响功能）
        quietDeps: true,
        logger: {
          warn: () => {} // 忽略警告
        }
      }
    }
  }
})

