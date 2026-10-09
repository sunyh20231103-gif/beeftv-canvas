<#
.SYNOPSIS
    将本地代码推送到你的 GitHub 仓库（origin remote）。
.DESCRIPTION
    首次使用前需要先添加 origin remote：
    git remote add origin https://github.com/YOUR_USERNAME/beeftv-canvas.git
#>
param(
    [string]$Branch = "main",
    [switch]$CreateRemote,
    [string]$GithubUser = ""
)

$repoRoot = Split-Path $PSScriptRoot -Parent

# 确保本地提交存在
$latest = & git log --oneline -1
Write-Host "最新提交: $latest"

# 添加 origin（如果不存在）
$originRemote = git remote get-url origin 2>$null
if (-not $originRemote) {
    if ($CreateRemote -and $GithubUser) {
        git remote add origin "https://github.com/$GithubUser/beeftv-canvas.git"
        Write-Host "已添加 origin: https://github.com/$GithubUser/beeftv-canvas.git"
    } else {
        Write-Host "请先添加 origin remote：" -ForegroundColor Yellow
        Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/beeftv-canvas.git"
        exit 1
    }
}

# 推送到 origin
Write-Host "推送到 origin ($Branch)..." -ForegroundColor Yellow
git push -u origin $Branch 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "推送成功！" -ForegroundColor Green
    Write-Host "仓库地址: $originRemote"
} else {
    Write-Host "推送失败，请检查网络或认证。" -ForegroundColor Red
}
