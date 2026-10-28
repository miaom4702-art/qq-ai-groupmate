$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $Root "bot\.env"
$Template = Join-Path $Root "config\onebot11.example.json"
$OneKeyFiles = Join-Path $Root "napcat\onekey\files"

if (-not (Test-Path -LiteralPath $EnvFile)) {
    throw "找不到 bot\.env，请先复制 bot\.env.example 并填写"
}
if (-not (Test-Path -LiteralPath $Template)) {
    throw "找不到 $Template"
}

$tokenLine = Get-Content -LiteralPath $EnvFile | Where-Object { $_ -match '^ONEBOT_ACCESS_TOKEN=' } | Select-Object -First 1
if (-not $tokenLine) {
    throw "bot\.env 缺少 ONEBOT_ACCESS_TOKEN"
}
$token = ($tokenLine -split '=', 2)[1].Trim()
if (-not $token -or $token -eq 'change-me-to-a-random-token') {
    throw "请先把 ONEBOT_ACCESS_TOKEN 改成随机字符串"
}

$shell = Get-ChildItem -LiteralPath $OneKeyFiles -Directory -Filter "NapCat.*.Shell" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $shell) {
    throw "找不到 NapCat OneKey 目录，请先安装 NapCat"
}

$configDir = Get-ChildItem -LiteralPath (Join-Path $shell.FullName "versions") -Recurse -Directory -Filter "config" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\app\\napcat\\config$' } |
    Select-Object -First 1
if (-not $configDir) {
    throw "找不到 NapCat 的 config 目录"
}

$text = Get-Content -LiteralPath $Template -Raw
$text = $text.Replace('change-me-to-a-random-token', $token)
[IO.File]::WriteAllText((Join-Path $configDir.FullName "onebot11.json"), $text, (New-Object Text.UTF8Encoding($false)))

# 已登录过时，NapCat 会读取 onebot11_<QQ>.json；同步更新已有配置。
Get-ChildItem -LiteralPath $configDir.FullName -Filter "onebot11_*.json" | ForEach-Object {
    try {
        $json = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
        if ($json.network.websocketServers -and $json.network.websocketServers.Count -gt 0) {
            $json.network.websocketServers[0].enable = $true
            $json.network.websocketServers[0].host = "127.0.0.1"
            $json.network.websocketServers[0].port = 3001
            $json.network.websocketServers[0].token = $token
            $out = $json | ConvertTo-Json -Depth 20
            [IO.File]::WriteAllText($_.FullName, $out, (New-Object Text.UTF8Encoding($false)))
        }
    } catch {
        Write-Warning "更新 $($_.Name) 失败：$($_.Exception.Message)"
    }
}

Write-Host "NapCat WebSocket 配置已写入：$configDir"
Write-Host "如需生效，重启 NapCat。"
