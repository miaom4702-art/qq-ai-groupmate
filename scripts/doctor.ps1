$Root = Split-Path -Parent $PSScriptRoot
$BotDir = Join-Path $Root "bot"
$EnvFile = Join-Path $BotDir ".env"
$DbFile = Join-Path $BotDir "data\ai_groupmate.db"
$Python = Join-Path $BotDir ".venv\Scripts\python.exe"
$OneKeyFiles = Join-Path $Root "napcat\onekey\files"

$problems = @()

if (-not (Test-Path -LiteralPath $EnvFile)) {
    $problems += "缺少 bot\.env"
} else {
    $envText = Get-Content -LiteralPath $EnvFile -Raw
    if ($envText -match "REPLACE_WITH|change-me|YOUR_GROUP_ID|你的QQ号") {
        $problems += "bot\.env 里还有占位符，请填写/同步 Key 与 token"
    }
}

try {
    $auth = bl auth status --output json 2>$null | Out-String | ConvertFrom-Json
    if ($auth.authenticated) {
        Write-Host "[OK] 百炼 CLI 已登录：$($auth.api_key.masked)"
    } else {
        $problems += "百炼 CLI 未登录，请运行 bl auth login --console"
    }
} catch {
    $problems += "未找到可用的 bl 命令，请确认 Bailian CLI 已安装并在 PATH 中"
}

if (-not (Test-Path -LiteralPath $Python)) {
    $problems += "缺少 bot\.venv，请运行 scripts\bootstrap.ps1"
}

if (-not (Test-Path -LiteralPath $DbFile)) {
    $problems += "数据库未初始化，请运行 scripts\init-db.ps1"
}

try {
    Invoke-RestMethod -Uri "http://127.0.0.1:6333/healthz" -TimeoutSec 3 | Out-Null
    Write-Host "[OK] Qdrant 正在运行"
} catch {
    $problems += "Qdrant 未运行，请运行 scripts\start-qdrant.ps1"
}

$napcatRoot = $null
if (Test-Path -LiteralPath $OneKeyFiles) {
    $shell = Get-ChildItem -LiteralPath $OneKeyFiles -Directory -Filter "NapCat.*.Shell" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($shell) { $napcatRoot = $shell.FullName }
}
if (-not $napcatRoot) {
    $problems += "未找到 NapCat OneKey 目录，请按 README 安装"
} else {
    $napcatConfig = Get-ChildItem -LiteralPath (Join-Path $napcatRoot "versions") -Recurse -Filter "onebot11.json" -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $napcatConfig) {
        $problems += "未找到 NapCat 的 onebot11.json"
    } else {
        $napcat = Get-Content -LiteralPath $napcatConfig.FullName -Raw | ConvertFrom-Json
        $ws = $napcat.network.websocketServers | Select-Object -First 1
        if (-not $ws -or -not $ws.enable) {
            $problems += "NapCat WebSocket 服务端未启用"
        } elseif ($envText -and $envText -notmatch [regex]::Escape($ws.token)) {
            $problems += "NapCat 的 token 与 bot\.env 的 ONEBOT_ACCESS_TOKEN 不一致"
        }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $napcatRoot "QQ.exe"))) {
        $problems += "未找到 OneKey 便携版 QQ.exe"
    }
}

if ($problems.Count -eq 0) {
    Write-Host ""
    Write-Host "检查通过。"
    Write-Host "首次：bootstrap -> 填写 .env -> start-qdrant -> init-db -> start-all"
} else {
    Write-Host ""
    Write-Host "需要处理："
    $problems | ForEach-Object { Write-Host " - $_" }
}
