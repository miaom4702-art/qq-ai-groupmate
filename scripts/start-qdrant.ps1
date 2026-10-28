$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$QdrantDir = Join-Path $Root "qdrant\bin"
$QdrantExe = Join-Path $QdrantDir "qdrant.exe"

if (-not (Test-Path -LiteralPath $QdrantExe)) {
    throw "找不到 $QdrantExe，请确认 qdrant 已解压到 qdrant\bin"
}

if (Get-Process -Name qdrant -ErrorAction SilentlyContinue) {
    Write-Host "Qdrant 已经在运行。"
    exit 0
}

Write-Host "启动 Qdrant（数据保存在 $QdrantDir\storage）..."
Start-Process -FilePath $QdrantExe -WorkingDirectory $QdrantDir -WindowStyle Minimized
Start-Sleep -Seconds 3

try {
    Invoke-RestMethod -Uri "http://127.0.0.1:6333/healthz" -TimeoutSec 10 | Out-Null
    Write-Host "Qdrant 就绪：http://127.0.0.1:6333"
} catch {
    throw "Qdrant 启动失败：$($_.Exception.Message)"
}
