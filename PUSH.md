# 推送代码到 GitHub

## 当前状态 ✅
- origin: https://github.com/sunyh20231103-gif/beeftv-canvas.git ✅
- upstream: https://github.com/glanderness/BeefTV.git ✅
- 远程已同步到最新 commit: acdd6c4

## 推送命令

```powershell
cd F:/Canvas/BeefTV
git add -A
git commit -m "描述修改内容"
git push --force origin main
```

> 使用 `--force` 是因为移除了上游的 workflow 文件，需要覆盖远程。

## 从官方拉取最新代码

```powershell
cd F:/Canvas/BeefTV
git pull upstream main --no-edit
git add -A
git commit -m "sync: pull upstream changes"
git push --force origin main
```

## 云端部署

代码在 GitHub 后，按以下方式部署：

### Render.com（免费套餐）
1. 注册 https://render.com
2. 新建 **Web Service** → 选择 `sunyh20231103-gif/beeftv-canvas` 仓库
3. 基础设置：
   - Name: `beeftv-canvas`
   - Region: Singapore
   - Branch: `main`
   - Root Directory: `./backend`（Go 服务）
   - Build Command: `go build -o bin/server ./cmd/server`
   - Start Command: `./bin/server`
4. 环境变量（必需）：
   - `DATABASE_URL`: 用 Render 内置 PostgreSQL（免费）或留空用 SQLite
   - `JWT_SECRET`: 随机字符串
   - `BEACTV_VERSION`: `v1`
5. 再建一个 **Static Site** 用于前端：
   - Root Directory: `./web`
   - Build Command: `npm install && npm run build`
   - Output Directory: `dist`

### Fly.io（有 $100 免费额度）
```bash
fly auth login          # 登录 Fly.io
cd backend
fly apps create beeftv-canvas --region hkg
fly deploy
```

### GitHub Actions 自动部署
仓库已配置 `.github/workflows/deploy-cloud.yml`，推送代码后会自动构建 Docker 镜像推送到 GitHub Container Registry (ghcr.io)。
