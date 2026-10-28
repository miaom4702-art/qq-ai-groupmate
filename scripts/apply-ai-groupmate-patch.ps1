$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Ref = Join-Path $Root "reference\nonebot-plugin-ai-groupmate"
$Patch = Join-Path $Root "patches\ai-groupmate-active-groups.patch"
$Python = Join-Path $Root "bot\.venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $Ref)) {
    Write-Host "克隆上游插件..."
    $parent = Split-Path -Parent $Ref
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    gh repo clone yaowan233/nonebot-plugin-ai-groupmate $Ref
    git -C $Ref checkout 431cb42
}
if (-not (Test-Path -LiteralPath (Join-Path $Ref ".git"))) {
    throw "$Ref 不是 git 仓库，无法应用补丁"
}
if (-not (Test-Path -LiteralPath $Python)) {
    throw "请先运行 scripts\bootstrap.ps1 创建虚拟环境"
}

$oldPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git -C $Ref apply --reverse --check $Patch 2>$null
$alreadyApplied = ($LASTEXITCODE -eq 0)
if (-not $alreadyApplied) {
    git -C $Ref apply --check $Patch
    if ($LASTEXITCODE -ne 0) {
        $ErrorActionPreference = $oldPreference
        throw "补丁无法应用（上游代码可能已变化）。请手动查看 patches\ai-groupmate-active-groups.patch"
    }
    git -C $Ref apply $Patch
    if ($LASTEXITCODE -ne 0) {
        $ErrorActionPreference = $oldPreference
        throw "git apply 失败"
    }
}
$ErrorActionPreference = $oldPreference

Write-Host "补丁状态：$(if ($alreadyApplied) { '已应用' } else { '已应用（本次）' })"
$env:NO_PROXY = "*"
$env:no_proxy = "*"
& $Python -m pip install -e $Ref
if ($LASTEXITCODE -ne 0) {
    throw "安装 editable 插件失败"
}
Write-Host "完成。"
