# BeefTV Canvas 远程部署说明

## 仓库结构（Fork 模式）

```
upstream  → https://github.com/glanderness/BeefTV.git   （上游官方仓库）
origin    → 你自己的 GitHub 仓库（待配置）
```

## 后续操作

### 1. 推送代码到你的 GitHub

替换 `YOUR_USERNAME` 为你的 GitHub 用户名，然后执行：

```powershell
# 在你的 GitHub 创建空仓库，例如：yourname/beeftv-canvas
cd F:/Canvas/BeefTV
git remote add origin https://github.com/YOUR_USERNAME/beeftv-canvas.git
git branch -M main
git push -u origin main
```

### 2. 从上游拉取更新

```powershell
cd F:/Canvas/BeefTV
git pull upstream main          # 拉取官方最新代码
# 如有冲突，解决后：git push origin main
```

---

## 云服务器部署脚本

将以下脚本保存到云服务器的 `/opt/beeftv/deploy.sh`，然后执行。

服务器需要安装：Go 1.25+、Node.js 20+、Git、Systemd

```bash
#!/bin/bash
set -e

REPO_DIR="/opt/beeftv"
DATA_DIR="/opt/beeftv/data"
LOG_FILE="/opt/beeftv/logs/app.log"
FRONTEND_PORT=3000
BACKEND_PORT=8080

# 创建目录
mkdir -p "$REPO_DIR" "$DATA_DIR" "$(dirname $LOG_FILE)"

# 克隆仓库（替换为你的 origin）
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone https://github.com/YOUR_USERNAME/beeftv-canvas.git "$REPO_DIR"
fi
cd "$REPO_DIR"
git pull origin main

# 编译后端
cd "$REPO_DIR/backend"
CGO_ENABLED=0 go build -o "$REPO_DIR/beeftv-server.exe" ./cmd/server

# 安装前端依赖
cd "$REPO_DIR/web"
bun install 2>/dev/null || npm install 2>/dev/null

# 创建 systemd 服务
cat > /etc/systemd/system/beeftv-backend.service << 'EOF'
[Unit]
Description=BeefTV Backend
After=network.target

[Service]
Environment="CANVAS_OFFICIAL_PLUGIN_DIR=/opt/beeftv/BeefTV-app/plugin-packages"
Environment="CANVAS_CORS_ORIGINS=http://localhost:$FRONTEND_PORT"
Environment="BEEFTV_ALLOWED_ORIGINS=http://localhost:$FRONTEND_PORT"
Environment="BEEFTV_UI_BOOTSTRAP=1"
ExecStart=/opt/beeftv/beeftv-server.exe
WorkingDirectory=/opt/beeftv
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/beeftv-frontend.service << 'EOF'
[Unit]
Description=BeefTV Frontend
After=network.target

[Service]
WorkingDirectory=/opt/beeftv/BeefTV/web
ExecStart=bun run dev -- --host 0.0.0.0 --port $FRONTEND_PORT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable beeftv-backend beeftv-frontend
systemctl restart beeftv-backend beeftv-frontend
echo "Deployed! Backend: http://YOUR_SERVER_IP:$BACKEND_PORT"
echo "            Frontend: http://YOUR_SERVER_IP:$FRONTEND_PORT"
```

### 部署步骤（在云服务器上）

```bash
# 1. 安装依赖（Ubuntu/Debian）
apt-get update && apt-get install -y golang-go nodejs npm git
# Node.js 需要 >=20，建议用 nvm 安装
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc && nvm install 20
npm install -g bun

# 2. 克隆并准备 BeefTV-app（包含 plugin-packages）
#    在本地已解压的 BeefTV-app 目录复制到服务器 /opt/beeftv/

# 3. 执行部署脚本
chmod +x /opt/beeftv/deploy.sh
/opt/beeftv/deploy.sh

# 4. 开放防火墙端口
ufw allow 3000/tcp
ufw allow 8080/tcp
```

---

## 当前本地状态

- 前端（Vite）：http://localhost:3000 ✅
- 后端（Go）：http://127.0.0.1:8080 ✅
- 已保留修改：agent_ops.go（trustedWebUI）、go.mod（glebarez/sqlite）