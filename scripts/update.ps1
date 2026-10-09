<#
.SYNOPSIS
    从 BeefTV 官方仓库拉取最新代码，重新编译，重启服务。
.DESCRIPTION
    使用 upstream remote 拉取官方更新，保留本地 fork 的补丁。
    需要安装：Go 1.25+, Bun, Git
.PARAMETER NoRestart
    跳过重启后端（仅拉取代码）
.PARAMETER ReinstallWebDeps
    重新安装 web 目录的依赖
.EXAMPLE
    .\scripts\update.ps1
    .\scripts\update.ps1 -NoRestart
#>
param(
    [switch]$NoRestart,
    [switch]$ReinstallWebDeps
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent

Write-Host "=== BeefTV 更新工具 ===" -ForegroundColor Cyan
Write-Host "仓库: $repoRoot"
Write-Host ""

# 1. 拉取 upstream 最新代码
Write-Host "[1/4] 拉取官方最新代码..." -ForegroundColor Yellow
Push-Location $repoRoot
git fetch upstream main 2>&1
git pull upstream main --ff-only 2>&1
Pop-Location
if ($LASTEXITCODE -ne 0) {
    Write-Host "git pull 失败，尝试强制合并..." -ForegroundColor Red
    Push-Location $repoRoot
    git pull upstream main --allow-unrelated-histories 2>&1
    Pop-Location
}

# 2. 编译后端
Write-Host "[2/4] 编译后端..." -ForegroundColor Yellow
Push-Location "$repoRoot\backend"
$env:CGO_ENABLED = "0"
& "$env:TEMP\go\go\bin\go.exe" build -o "$repoRoot\beeftv-server.exe" "./cmd/server" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "编译失败！" -ForegroundColor Red
    exit 1
}
Write-Host "后端编译完成: $repoRoot\beeftv-server.exe" -ForegroundColor Green
Pop-Location

# 3. 安装前端依赖
Write-Host "[3/4] 检查前端依赖..." -ForegroundColor Yellow
Push-Location "$repoRoot\web"
if ($ReinstallWebDeps -or -not (Test-Path "node_modules")) {
    bun install 2>&1
}
Write-Host "前端依赖检查完成" -ForegroundColor Green
Pop-Location

# 4. 重启后端
if (-not $NoRestart) {
    Write-Host "[4/4] 重启后端服务..." -ForegroundColor Yellow
    $server = Get-Process -Name "beeftv-server" -ErrorAction SilentlyContinue
    if ($server) {
        Stop-Process -Id $server.Id -Force
        Start-Sleep -Seconds 1
    }
    
    $env:CANVAS_OFFICIAL_PLUGIN_DIR = "$repoRoot\BeefTV-app\plugin-packages"
    $env:CANVAS_CORS_ORIGINS = "http://localhost:3000"
    $env:BEEFTV_ALLOWED_ORIGINS = "http://localhost:3000"
    $env:BEEFTV_UI_BOOTSTRAP = "1"
    
    Start-Process -FilePath "$repoRoot\beeftv-server.exe" -WorkingDirectory $repoRoot
    Start-Sleep -Seconds 2
    
    Write-Host "后端已重启，监听端口 8080" -ForegroundColor Green
} else {
    Write-Host "[4/4] 跳过重启（--NoRestart）" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== 更新完成 ===" -ForegroundColor Green
Write-Host "前端: http://localhost:3000"
Write-Host "后端: http://localhost:8080"
