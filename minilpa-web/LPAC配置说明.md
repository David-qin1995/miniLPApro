# LPAC 功能配置说明

## 🎯 快速开始

MiniLPA Web 现在支持两种运行模式：

### 模式 1: 模拟模式（默认，无需硬件）

适合：开发、测试、演示

```bash
# .env 配置
USE_MOCK_DATA=true  # 或不设置（默认）
```

### 模式 2: 真实模式（需要 lpac + 硬件）

适合：实际使用、生产环境

```bash
# .env 配置
USE_MOCK_DATA=false
APDU_DRIVER=auto
```

## 📦 安装 lpac（真实模式需要）

### 快速安装（Linux/macOS）

```bash
# 1. 安装依赖
# Ubuntu/Debian
sudo apt-get install -y build-essential cmake libcurl4-openssl-dev libpcsclite-dev pcscd

# macOS
brew install cmake curl pcsc-lite

# 2. 编译安装 lpac
git clone https://github.com/estkme-group/lpac.git
cd lpac
mkdir build && cd build
cmake ..
make
sudo make install

# 3. 验证
lpac version
```

### 或下载预编译版本

从 https://github.com/estkme-group/lpac/releases 下载

## ⚙️ 配置文件说明

编辑 `.env`:

```bash
# ========================================
# LPAC 配置
# ========================================

# 是否使用模拟数据
# true  = 模拟模式（不需要 lpac 和硬件）
# false = 真实模式（需要 lpac 和 eUICC 硬件）
USE_MOCK_DATA=false

# APDU 驱动类型
# auto = 自动检测（推荐）
# pcsc = PCSC 智能卡读卡器
# at   = AT 命令（调制解调器）
APDU_DRIVER=auto

# lpac 日志级别
LPAC_LOG_LEVEL=info
```

## 🔌 硬件要求（真实模式）

1. **智能卡读卡器**
   - 支持 PCSC 协议的任何读卡器
   - USB 或内置读卡器均可

2. **eSIM 卡**
   - 支持 GSMA eSIM 标准的 eUICC 卡
   - 例如：ESTKme-ECO、5ber、速易卡等

3. **PCSC 服务**
   - Linux: `pcscd` 服务
   - macOS: 已内置
   - Windows: 已内置

## ✅ 测试 lpac 是否工作

### 方法1: API 测试

```bash
# 启动服务器
npm start

# 测试 lpac 状态
curl http://localhost:3000/api/lpac/status

# 期望输出：
{
  "success": true,
  "data": {
    "available": true,        # lpac 可用
    "version": "lpac v2.0.0",
    "path": "/usr/local/bin/lpac",
    "useMockData": false,     # 非模拟模式
    "isAvailable": true
  }
}
```

### 方法2: 命令行测试

```bash
# 测试 lpac 命令
lpac chip info

# 如果成功，会显示芯片信息
```

## 🔄 功能对比

| 功能 | 模拟模式 | 真实模式 |
|------|---------|---------|
| 查看 Profile 列表 | ✅ (模拟数据) | ✅ (真实数据) |
| 下载 Profile | ✅ (假装下载) | ✅ (真实下载) |
| 启用/禁用 Profile | ✅ (数据库操作) | ✅ (真实操作) |
| 删除 Profile | ✅ (数据库操作) | ✅ (真实删除) |
| 芯片信息 | ✅ (模拟数据) | ✅ (真实数据) |
| 通知管理 | ✅ (模拟数据) | ✅ (真实数据) |
| 需要硬件 | ❌ | ✅ |
| 需要 lpac | ❌ | ✅ |

## 🚨 故障排查

### lpac 未找到

```bash
# 检查是否安装
which lpac
lpac version

# 如果未找到，安装或创建链接
ln -s /path/to/lpac /usr/local/bin/lpac
```

### PCSC 服务未运行

```bash
# 启动 PCSC 服务
sudo systemctl start pcscd

# 检查状态
sudo systemctl status pcscd

# 测试读卡器
pcsc_scan
```

### 无法检测到卡

1. 检查读卡器是否连接
2. 检查 eSIM 卡是否正确插入
3. 尝试重启 pcscd: `sudo systemctl restart pcscd`

### API 返回 available: false

检查：
- `.env` 中 `USE_MOCK_DATA` 是否为 `false`
- lpac 是否正确安装
- PCSC 服务是否运行
- 查看服务器日志: `logs/backend.log`

## 📊 查看当前模式

访问前端设置页面，会显示当前运行模式：
- 🔵 真实模式 - 使用 lpac
- 🟡 模拟模式 - 使用模拟数据

或通过 API：
```bash
curl http://localhost:3000/api/lpac/status
```

## 💡 推荐配置

### 开发环境
```bash
USE_MOCK_DATA=true  # 使用模拟数据，快速开发
```

### 测试环境
```bash
USE_MOCK_DATA=false  # 测试真实功能
LPAC_LOG_LEVEL=debug  # 详细日志
```

### 生产环境
```bash
USE_MOCK_DATA=false  # 真实功能
APDU_DRIVER=pcsc     # 明确指定驱动
LPAC_LOG_LEVEL=warn  # 只记录警告和错误
```

## 📚 更多文档

- 详细集成指南: `docs/lpac-integration.md`
- lpac 官方文档: https://github.com/estkme-group/lpac

## ✨ 特点

1. **自动切换**: 根据配置自动在真实/模拟模式间切换
2. **优雅降级**: lpac 不可用时自动回退到模拟模式
3. **透明接口**: API 接口保持一致，前端无需修改
4. **详细日志**: 记录所有 lpac 操作，便于调试

---

现在您的项目已完全支持 lpac 功能！🎉

