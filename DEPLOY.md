# BeefTV Canvas 部署指南

## 仓库结构（Fork 模式）

```
upstream  → https://github.com/glanderness/BeefTV.git   （上游官方仓库）
origin    → 你自己的 GitHub 仓库（待配置）
```

---

## 一、推送代码到你的 GitHub

### 1. 在 GitHub 创建新仓库

访问 https://github.com/new，创建仓库（例如：`yourname/beeftv-canvas`），不要初始化 README。

### 2. 添加 origin remote 并推送

```powershell
cd F:/Canvas/BeefTV

# 添加你的 GitHub 仓库
git remote add origin https://github.com/YOUR_USERNAME/beeftv-canvas.git

# 推送到你的仓库
git push -u origin main
```

### 3. 本地更新命令

```powershell
# 从官方拉取最新代码（保留本地修改）
cd F:/Canvas/BeefTV
.\scripts\update.ps1

# 推送到你的 GitHub
.\scripts\push-to-origin.ps1
```

---

## 二、云端部署（免费方案）

### 方案 A：Render.com（推荐，全免费）

**优点**：永久免费、无需信用卡、GitHub 一键部署  
**限制**：90 天无流量会自动暂停（访问即恢复）

#### 步骤

1. **注册 Render**：https://dashboard.render.com，用 GitHub 登录

2. **部署 Backend**（SQLite + Go）：
   ```
   New → Web Service
   Repository: yourname/beeftv-canvas
   Root Directory: backend
   Build Command: go build -o bin/server ./cmd/server
   Start Command: ./bin/server
   Environment Variables:
     GIN_MODE = release
     CANVAS_BACKEND_ADDR = :8080
     CANVAS_BACKEND_DATA_DIR = /data
     CANVAS_AUTO_MIGRATE = true
     CANVAS_DATABASE_DRIVER = sqlite
     CANVAS_CORS_ORIGINS = https://your-domain.onrender.com
     BEEFTV_ALLOWED_ORIGINS = https://your-domain.onrender.com
     BEEFTV_UI_BOOTSTRAP = 1
   Disk: Mount at /data, size 1GB
   ```

3. **部署 Frontend**（静态文件）：
   ```
   New → Static Site
   Repository: yourname/beeftv-canvas
   Publish Directory: web/dist
   Build Command: bun install && bun run build
   ```

4. **连接域名**（可选）：在 Render 设置中添加自定义域名

#### 自动部署（GitHub Actions）

已配置 `.github/workflows/deploy-cloud.yml`：
- 推送 `main` 分支时自动构建 Docker 镜像到 GHCR
- 需要配置 `RENDER_API_TOKEN` 或 `FLY_API_TOKEN` 才能自动触发部署

---

### 方案 B：Fly.io（推荐，有持久化存储）

**优点**：免费额度内持久运行、有持久化磁盘、SST 自动恢复  
**限制**：需要绑定信用卡、存储费用约 $0.5/月

#### 步骤

1. **安装 Fly CLI**：
   ```bash
   # Windows
   winget install fly.io
   
   # 或从 https://fly.io/docs/hands-on/ 下载安装
   ```

2. **登录并初始化**：
   ```bash
   fly auth login
   fly apps create beeftv-canvas --region hkg
   ```

3. **部署**：
   ```bash
   cd F:/Canvas/BeefTV
   fly deploy
   ```

4. **验证**：
   ```bash
   fly status
   fly logs
   ```

---

## 三、本地开发（当前环境）

| 服务 | 地址 | 状态 |
|------|------|------|
| 前端 (Vite) | http://localhost:3000 | ✅ |
| 后端 (Go) | http://127.0.0.1:8080 | ✅ |

**环境变量**：
```powershell
$env:CANVAS_OFFICIAL_PLUGIN_DIR = "F:/Canvas/BeefTV-app/plugin-packages"
$env:CANVAS_CORS_ORIGINS = "http://localhost:3000"
$env:BEEFTV_ALLOWED_ORIGINS = "http://localhost:3000"
$env:BEEFTV_UI_BOOTSTRAP = "1"
```

---

## 四、升级流程

```powershell
# 1. 从官方拉取最新代码
cd F:/Canvas/BeefTV
git pull upstream main

# 2. 重新编译（仅后端需要）
cd backend
$env:CGO_ENABLED = "0"
& "$env:TEMP\go\go\bin\go.exe" build -o "../beeftv-server.exe" "./cmd/server"

# 3. 重启后端服务
# （停止当前进程，重新启动）

# 4. 推送到你的 GitHub
git add -A
git commit -m "chore: sync upstream v1.x.x"
git push origin main
```

---

## 五、注意事项

1. **助手功能**：由于 `@earendil-works/pi-coding-agent` 与 Node.js v24 不兼容，
   助手功能暂时不可用。画布保存和生图功能正常工作。

2. **生图问题**："excessive system load" 是上游中转服务过载，重试即可。

3. **数据库迁移**：首次启动时后端会自动迁移数据库 schema，无需手动操作。

4. **配置文件**：`F:/Canvas/data/agent_config.json` 配置助手启动命令。
