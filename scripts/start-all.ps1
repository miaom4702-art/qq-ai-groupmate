$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

& (Join-Path $PSScriptRoot "start-qdrant.ps1")
& (Join-Path $PSScriptRoot "init-db.ps1")

Write-Host "正在启动 NapCat（会弹出 UAC 和 QQ 登录窗口）..."
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $PSScriptRoot 'start-napcat.ps1')`""
Start-Sleep -Seconds 2

Write-Host "正在启动 NoneBot..."
& (Join-Path $PSScriptRoot "start-bot.ps1")
