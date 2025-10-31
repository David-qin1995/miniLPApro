# 环境变量配置

本文档说明 MiniLPA Web 项目的环境变量配置。

## 配置文件位置

项目根目录下的 `.env` 文件

## 环境变量列表

### 服务器配置

```bash
# 服务器端口
PORT=3000

# 运行环境 (development | production | test)
NODE_ENV=production
```

### 数据库配置

```bash
# 数据库文件路径
DB_PATH=./data/db.json
```

### CORS 配置

```bash
# 允许的跨域源
# 开发环境可以设置为 *
# 生产环境建议设置为具体域名
CORS_ORIGIN=*

# 生产环境示例
# CORS_ORIGIN=https://yourdomain.com
```

### 文件上传配置

```bash
# 上传文件存储路径
UPLOAD_PATH=./uploads

# 最大文件大小 (bytes)
# 默认: 10485760 (10MB)
MAX_FILE_SIZE=10485760
```

### Session 配置

```bash
# Session 密钥
# 生产环境务必修改为随机字符串
SESSION_SECRET=your-secret-key-change-this
```

## 开发环境示例

创建 `.env` 文件：

```bash
PORT=3000
NODE_ENV=development
DB_PATH=./data/db.json
CORS_ORIGIN=*
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
SESSION_SECRET=dev-secret-key
```

## 生产环境示例

创建 `.env` 文件：

```bash
PORT=3000
NODE_ENV=production
DB_PATH=./data/db.json
CORS_ORIGIN=https://yourdomain.com
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
SESSION_SECRET=your-random-secret-key-here
```

## 生成安全的 Secret Key

使用以下命令生成随机密钥：

```bash
# 使用 Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# 或使用 OpenSSL
openssl rand -hex 32
```

## 配置说明

### PORT

应用监听的端口号。确保该端口未被其他应用占用。

### NODE_ENV

运行环境：
- `development`: 开发环境，输出详细日志
- `production`: 生产环境，优化性能
- `test`: 测试环境

### DB_PATH

LowDB 数据库文件路径。路径可以是相对路径或绝对路径。

### CORS_ORIGIN

跨域资源共享配置：
- `*`: 允许所有域名（开发环境）
- 具体域名: 只允许指定域名（生产环境推荐）
- 多个域名: 使用逗号分隔

### UPLOAD_PATH

文件上传存储目录。确保该目录存在且有写入权限。

### MAX_FILE_SIZE

允许上传的最大文件大小（字节）：
- 1MB = 1048576
- 10MB = 10485760
- 100MB = 104857600

### SESSION_SECRET

用于加密 Session 的密钥。生产环境必须使用强随机字符串。

## 安全建议

1. **不要提交 .env 文件到版本控制**
   - `.env` 文件已在 `.gitignore` 中
   
2. **定期更换密钥**
   - 特别是 `SESSION_SECRET`
   
3. **限制 CORS**
   - 生产环境不要使用 `*`
   
4. **使用环境变量管理工具**
   - 考虑使用 dotenv-vault 或类似工具
   
5. **备份配置**
   - 保存生产环境配置的副本（去除敏感信息）

## 故障排查

### 应用无法启动

检查：
- `.env` 文件是否存在
- 环境变量格式是否正确
- 端口是否被占用

### 文件上传失败

检查：
- `UPLOAD_PATH` 目录是否存在
- 目录是否有写入权限
- `MAX_FILE_SIZE` 是否足够大

### CORS 错误

检查：
- `CORS_ORIGIN` 是否包含前端域名
- 是否使用了正确的协议（http/https）
- 浏览器控制台的具体错误信息

## 相关文档

- [快速开始](./quick-start.md)
- [宝塔部署](./baota-deployment.md)

---

配置有问题？请查看 [常见问题](./faq.md) 或提交 Issue。

