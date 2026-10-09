# 推送代码到 GitHub

## 当前状态
- origin: https://github.com/sunyh20231103-gif/beeftv-canvas.git ✅
- upstream: https://github.com/glanderness/BeefTV.git ✅
- 主分支已推送（不含 workflow 文件）

## 解决 workflow scope 问题

**原因**：当前 PAT 缺少 `workflow` 权限，无法推送 `.github/workflows/deploy-cloud.yml`

### 步骤 1：更新 GitHub Token

1. 浏览器已自动打开 https://github.com/settings/tokens
2. 找到对应的 token（名称含 gh_），点击 **Edit**
3. 在 **Select scopes** 中勾选 **workflow**
4. 滚动到底部点击 **Update token**

### 步骤 2：重新推送

Token 更新后，执行以下命令：

```powershell
cd F:/Canvas/BeefTV
git push origin main
```

> 系统会自动弹出浏览器让你确认授权（使用新 token）。

---

## 后续常用命令

| 操作 | 命令 |
|------|------|
| 拉取官方最新 | `git pull upstream main` |
| 推送到自己仓库 | `git push origin main` |
| 同时拉取并推送 | `git pull upstream main && git push origin main` |

## 云端部署

代码推送后，可以按以下方式部署：

### Render.com（免费）
1. 注册 https://render.com
2. 新建 Web Service，选择 `beeftv-canvas` 仓库
3. 设置环境变量（见 DEPLOY.md）

### Fly.io（有免费额度）
```bash
fly auth login          # 登录 Fly.io
fly apps create beeftv-canvas --region hkg
fly deploy
```
