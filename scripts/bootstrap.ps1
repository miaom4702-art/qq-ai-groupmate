$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$BotDir = Join-Path $Root "bot"
$Python = Join-Path $BotDir ".venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $Python)) {
    Write-Host "创建 Python 3.12 虚拟环境..."
    py -3.12 -m venv (Join-Path $BotDir ".venv")
    if ($LASTEXITCODE -ne 0) {
        throw "创建虚拟环境失败，请安装 Python 3.12"
    }
}

$env:NO_PROXY = "*"
$env:no_proxy = "*"
Write-Host "安装 NoneBot 基础依赖..."
& $Python -m pip install -U pip
& $Python -m pip install "nonebot2[fastapi]" "nonebot-adapter-onebot" "nonebot-plugin-orm" aiosqlite nb-cli
if ($LASTEXITCODE -ne 0) {
    throw "安装基础依赖失败"
}

& (Join-Path $PSScriptRoot "apply-ai-groupmate-patch.ps1")

$EnvFile = Join-Path $BotDir ".env"
if (-not (Test-Path -LiteralPath $EnvFile)) {
    Copy-Item (Join-Path $BotDir ".env.example") $EnvFile
    Write-Host "已创建 bot\.env，请填写百炼 Key、群号和 token。"
}

Write-Host ""
Write-Host "下一步："
Write-Host "1. 编辑 bot\.env"
Write-Host "2. 准备 Qdrant 与 NapCat（见 README）"
Write-Host "3. 运行 scripts\init-db.ps1"
Write-Host "4. 运行 scripts\start-all.ps1"
