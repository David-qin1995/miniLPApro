# LPAC 集成指南

本文档说明如何在 MiniLPA Web 中集成和使用真实的 lpac 功能。

## 📋 目录

- [什么是 LPAC](#什么是-lpac)
- [模拟模式 vs 真实模式](#模拟模式-vs-真实模式)
- [安装 LPAC](#安装-lpac)
- [配置项目](#配置项目)
- [使用说明](#使用说明)
- [故障排查](#故障排查)

## 什么是 LPAC

**lpac** 是一个开源的 LPA (Local Profile Assistant) 实现，用于管理 eUICC (eSIM) 配置文件。

- **项目地址**: https://github.com/estkme-group/lpac
- **功能**: 下载、安装、启用、禁用、删除 eSIM 配置文件
- **支持**: PCSC智能卡、AT命令、直接APDU等多种通信方式

## 模拟模式 vs 真实模式

### 模拟模式（默认）

- 使用数据库中的模拟数据
- 不需要实际的 eUICC 硬件
- 适合开发和测试

### 真实模式

- 使用 lpac 与真实的 eUICC 芯片通信
- 需要安装 lpac 和相关驱动
- 需要物理 eUICC 硬件（智能卡读卡器 + eSIM卡）

## 安装 LPAC

### 方式一：从源码编译（推荐）

#### Linux (Ubuntu/Debian)

```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y build-essential cmake libcurl4-openssl-dev libpcsclite-dev

# 克隆项目
git clone https://github.com/estkme-group/lpac.git
cd lpac

# 编译
mkdir build && cd build
cmake ..
make

# 安装
sudo make install

# 验证安装
lpac version
```

#### macOS

```bash
# 安装依赖
brew install cmake curl pcsc-lite

# 克隆项目
git clone https://github.com/estkme-group/lpac.git
cd lpac

# 编译
mkdir build && cd build
cmake ..
make

# 安装
sudo make install

# 验证安装
lpac version
```

#### CentOS 7

```bash
# 安装依赖
sudo yum install -y gcc gcc-c++ cmake3 libcurl-devel pcsc-lite-devel

# 克隆项目
git clone https://github.com/estkme-group/lpac.git
cd lpac

# 编译
mkdir build && cd build
cmake3 ..
make

# 安装
sudo make install

# 验证安装
lpac version
```

### 方式二：使用预编译二进制

从 [lpac Releases](https://github.com/estkme-group/lpac/releases) 下载适合您系统的二进制文件。

```bash
# 下载二进制文件（以 Linux x64 为例）
wget https://github.com/estkme-group/lpac/releases/latest/download/lpac-linux-x86_64
chmod +x lpac-linux-x86_64

# 移动到项目 bin 目录
mkdir -p /path/to/minilpa-web/bin
mv lpac-linux-x86_64 /path/to/minilpa-web/bin/lpac

# 或安装到系统路径
sudo mv lpac-linux-x86_64 /usr/local/bin/lpac
```

### 安装智能卡驱动（必需）

#### Linux

```bash
# Ubuntu/Debian
sudo apt-get install pcscd pcsc-tools

# CentOS/RHEL
sudo yum install pcsc-lite pcsc-tools

# 启动服务
sudo systemctl start pcscd
sudo systemctl enable pcscd
```

#### macOS

macOS 已内置 PCSC 支持，无需额外安装。

#### Windows

下载并安装 PCSC 驱动（Windows 通常已内置）。

## 配置项目

### 1. 更新环境变量

编辑 `.env` 文件：

```bash
# 是否使用模拟数据
# true = 模拟模式（默认）
# false = 真实模式（需要 lpac）
USE_MOCK_DATA=false

# APDU 驱动类型
# auto = 自动检测（推荐）
# pcsc = PCSC智能卡读卡器
# at = AT命令（调制解调器）
APDU_DRIVER=auto

# lpac 日志级别
# debug, info, warn, error
LPAC_LOG_LEVEL=info
```

### 2. 指定 lpac 路径（可选）

lpac 搜索顺序：
1. `<项目根目录>/bin/lpac`
2. `/usr/local/bin/lpac`
3. `/usr/bin/lpac`
4. `~/.local/bin/lpac`
5. 系统 PATH 中的 `lpac`

如果 lpac 在其他位置，可以创建符号链接：

```bash
ln -s /path/to/lpac /path/to/minilpa-web/bin/lpac
```

### 3. 测试 lpac 连接

```bash
# 启动服务器
npm start

# 在另一个终端测试
curl http://localhost:3000/api/lpac/status

# 应返回类似：
{
  "success": true,
  "data": {
    "available": true,
    "version": "lpac v2.0.0",
    "path": "/usr/local/bin/lpac",
    "useMockData": false,
    "apduDriver": "auto",
    "isAvailable": true
  }
}
```

## 使用说明

### 检查 lpac 状态

```bash
GET /api/lpac/status
```

返回 lpac 的可用性、版本和配置信息。

### 获取 lpac 版本

```bash
GET /api/lpac/version
```

### 同步数据

```bash
POST /api/lpac/sync
```

从 lpac 同步所有数据（Profiles、Notifications、Chip Info）到数据库。

### API 自动切换

所有 Profile 和 Notification API 会自动根据配置选择：
- 如果 `USE_MOCK_DATA=false` 且 lpac 可用 → 使用真实 lpac
- 否则 → 使用模拟数据

```bash
# 这些 API 会自动切换模式
GET    /api/profiles          # 列出 Profiles
POST   /api/profiles          # 下载 Profile
POST   /api/profiles/:id/enable   # 启用 Profile
POST   /api/profiles/:id/disable  # 禁用 Profile
DELETE /api/profiles/:id      # 删除 Profile
GET    /api/chip              # 获取芯片信息
GET    /api/notifications     # 获取通知
```

## 前端显示 lpac 状态

您可以在前端添加 lpac 状态显示：

```javascript
// 获取 lpac 状态
async function checkLPACStatus() {
  const response = await fetch('/api/lpac/status');
  const data = await response.json();
  
  if (data.success && data.data.isAvailable) {
    console.log('✅ LPAC 已连接');
    console.log('版本:', data.data.version);
  } else {
    console.log('⚠️  使用模拟模式');
  }
}
```

## 故障排查

### 问题1: lpac 未找到

```
错误: lpac 可能未安装或路径不正确
```

**解决方法**:
1. 确认 lpac 已安装: `which lpac` 或 `lpac version`
2. 检查 lpac 是否在支持的路径中
3. 创建符号链接到项目 bin 目录

### 问题2: PCSC 服务未运行

```
错误: Cannot connect to PCSC
```

**解决方法**:
```bash
# Linux
sudo systemctl start pcscd
sudo systemctl status pcscd

# 测试读卡器
pcsc_scan
```

### 问题3: 无法检测到智能卡

```
错误: No card detected
```

**解决方法**:
1. 检查读卡器是否正确连接
2. 检查 eSIM 卡是否正确插入
3. 使用 `pcsc_scan` 测试读卡器

### 问题4: 权限错误

```
错误: Permission denied
```

**解决方法**:
```bash
# 添加用户到 pcscd 组
sudo usermod -a -G pcscd $USER

# 重新登录或重启
```

### 问题5: lpac 命令执行失败

**解决方法**:
1. 手动测试 lpac 命令:
   ```bash
   lpac chip info
   lpac profile list
   ```
2. 检查日志: `logs/backend.log`
3. 启用调试模式: 设置 `LPAC_LOG_LEVEL=debug`

## 调试技巧

### 1. 启用详细日志

```bash
# .env
LPAC_LOG_LEVEL=debug
```

### 2. 手动测试 lpac

```bash
# 获取芯片信息
lpac chip info

# 列出 Profiles
lpac profile list

# 列出通知
lpac notification list
```

### 3. 查看服务器日志

```bash
# 实时查看日志
tail -f logs/backend.log

# 搜索 lpac 相关日志
grep "LPAC" logs/backend.log
```

### 4. 测试 PCSC

```bash
# 扫描智能卡
pcsc_scan

# 列出读卡器
pcsc_scan -l
```

## 性能优化

### 缓存机制

项目会自动缓存 lpac 数据到数据库，减少硬件访问次数。

### 异步操作

所有 lpac 操作都是异步的，不会阻塞其他请求。

### 超时处理

lpac 命令有30秒超时保护，防止长时间阻塞。

## 安全建议

1. **权限控制**: 限制对 lpac 的访问权限
2. **输入验证**: 验证激活码等用户输入
3. **日志审计**: 记录所有 lpac 操作
4. **错误处理**: 不要暴露敏感的系统信息

## 相关资源

- [lpac 项目](https://github.com/estkme-group/lpac)
- [GSMA eSIM 规范](https://www.gsma.com/esim/)
- [PCSC 官方文档](https://pcsclite.apdu.fr/)

## 总结

通过以上配置，您的 MiniLPA Web 项目现在可以：

✅ 自动检测 lpac 可用性
✅ 在真实模式和模拟模式间无缝切换
✅ 与真实的 eUICC 硬件通信
✅ 提供完整的 eSIM 管理功能

如有问题，请查看日志或提交 Issue。

