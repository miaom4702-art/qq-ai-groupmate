$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Python = Join-Path $Root "bot\.venv\Scripts\python.exe"
$Apply = Join-Path $Root "tools\apply_bailian_env.py"

$status = bl auth status --output json 2>$null | Out-String
try {
    $json = $status | ConvertFrom-Json
} catch {
    throw "无法读取 bl auth status，请先运行 bl auth login --console"
}
if (-not $json.authenticated) {
    throw "百炼 CLI 尚未登录，请先运行 bl auth login --console"
}

& $Python $Apply
