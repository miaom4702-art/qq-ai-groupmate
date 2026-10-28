param(
    [string]$QQNumber = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$OneKeyFiles = Join-Path $Root "napcat\onekey\files"

if (-not (Test-Path -LiteralPath $OneKeyFiles)) {
    throw "找不到 $OneKeyFiles。请先按 README 安装 NapCat OneKey（便携版 QQ + NapCat）。"
}

$Shell = Get-ChildItem -LiteralPath $OneKeyFiles -Directory -Filter "NapCat.*.Shell" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $Shell) {
    throw "在 $OneKeyFiles 中找不到 NapCat.*.Shell"
}
$ShellDir = $Shell.FullName
$Loader = Join-Path $ShellDir "NapCatWinBootMain.exe"

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "需要管理员权限，正在重新启动..."
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($QQNumber) { $argList += " -QQNumber $QQNumber" }
    Start-Process powershell.exe -Verb RunAs -ArgumentList $argList
    exit 0
}

Write-Host "便携版 QQ: $ShellDir\QQ.exe"
Write-Host "NapCat:    $ShellDir"
Write-Host "WebUI 默认: http://127.0.0.1:6099/webui"
Write-Host "首次登录请用手机 QQ 扫码。"
Write-Host ""

Set-Location -LiteralPath $ShellDir
if ($QQNumber) {
    & $Loader $QQNumber
} else {
    & $Loader
}
