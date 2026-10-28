$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$BotDir = Join-Path $Root "bot"
$NbExe = Join-Path $BotDir ".venv\Scripts\nb.exe"

if (-not (Test-Path -LiteralPath $NbExe)) {
    throw "找不到 nb.exe，请先安装 Python 依赖"
}

$env:NO_PROXY = "*"
$env:no_proxy = "*"
Set-Location -LiteralPath $BotDir
$oldPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $NbExe orm upgrade 2>&1 | ForEach-Object { Write-Host $_ }
$code = $LASTEXITCODE
$ErrorActionPreference = $oldPreference
if ($code -ne 0) {
    throw "数据库迁移失败，退出码 $code"
}
Write-Host "数据库迁移完成：bot\data\ai_groupmate.db"
