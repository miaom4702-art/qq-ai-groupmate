$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$BotDir = Join-Path $Root "bot"
$Python = Join-Path $BotDir ".venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $Python)) {
    throw "找不到虚拟环境，请先创建 bot\.venv 并安装依赖"
}

$env:PYTHONUTF8 = "1"
$env:NO_PROXY = "127.0.0.1,localhost"
chcp 65001 > $null
Set-Location -LiteralPath $BotDir
& $Python bot.py
