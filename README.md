# QQ Group AI · NapCat + WebSocket + NoneBot

一个会自己看群、自己判断要不要接话、会学习群友表情包的 QQ 群友。

项目基于成熟开源方案组合，而不是从零写聊天逻辑：

- **NapCatQQ**：QQ 协议端，OneBot V11
- **NoneBot2**：Bot 框架，WebSocket 连接
- **nonebot-plugin-ai-groupmate**：群聊 Agent（Gatekeeper、群体记忆、上下文压缩、RAG、表情包学习）
- **Qdrant**：本地向量库
- **阿里云百炼 / DashScope**：聊天、判断、摘要、视觉标注、Embedding

## 技术报告

[PDF 下载：QQ-AI-Groupmate-Technical-Report.pdf](docs/QQ-AI-Groupmate-Technical-Report.pdf)

## 功能

- 不需要 @，按概率自主判断是否参与群聊
- Gatekeeper 过滤“没话找话”，结合群氛围决定是否发言
- 最近消息 + 群体认知档案 + 明确记忆 + 聊天 RAG，长群聊不会无限塞上下文
- 自动收集群友表情包，用视觉模型标注情绪/场景/图内文字，按语义检索并在合适时发送
- 单群活跃度可单独提高，不影响其他群
- 本地运行，默认只监听 127.0.0.1

## 目录

```text
.
├─ bot\                       NoneBot 项目
│  ├─ bot.py                  启动入口
│  ├─ pyproject.toml
│  ├─ .env.example            配置模板
│  └─ data\                   数据库与本地缓存（运行时生成）
├─ config\
│  └─ onebot11.example.json   NapCat WebSocket 配置模板
├─ patches\
│  └─ ai-groupmate-active-groups.patch
├─ scripts\                   安装、启动、自检、打补丁
├─ tools\                     百炼 Key 同步、群/配置检查
├─ docs\OPTIMIZATIONS.md      小优化说明
├─ LICENSE
├─ NOTICE.md
└─ SECURITY.md
```

不包含 NapCat、Qdrant、QQ 二进制，也不包含任何 Key、token、群号或聊天数据。

## 快速开始（Windows）

### 0. 前置

- Windows 10/11
- Python **3.12**
- Git、GitHub CLI（`gh`）
- Node.js ≥ 18（安装百炼 CLI 用）
- 一个用于 Bot 的 QQ 小号

### 1. 克隆并安装 Python 依赖

```powershell
git clone https://github.com/miaom4702-art/qq-ai-groupmate.git
cd qq-ai-groupmate
powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1
```

`bootstrap.ps1` 会：

- 创建 `bot\.venv`
- 安装 NoneBot / ORM / nb-cli
- 克隆 `nonebot-plugin-ai-groupmate` 到 `reference\`
- 应用 `patches\ai-groupmate-active-groups.patch`
- editable 安装插件

### 2. Qdrant

```powershell
New-Item -ItemType Directory -Force qdrant | Out-Null
gh release download v1.20.0 -R qdrant/qdrant -p "qdrant-x86_64-pc-windows-msvc.zip" -D qdrant
Expand-Archive qdrant\qdrant-x86_64-pc-windows-msvc.zip -DestinationPath qdrant\bin -Force
```

### 3. NapCat（便携版 QQ + NapCat）

当前系统 QQ 的版本可能与 NapCat Shell 不匹配。推荐用 OneKey 安装器，它会安装配套的便携版 QQ：

```powershell
New-Item -ItemType Directory -Force napcat\onekey | Out-Null
gh release download v4.18.41 -R NapNeko/NapCatQQ -p "NapCat.Shell.Windows.OneKey.zip" -D napcat\onekey
Expand-Archive napcat\onekey\NapCat.Shell.Windows.OneKey.zip -DestinationPath napcat\onekey\files -Force
Start-Process -FilePath napcat\onekey\files\NapCatInstaller.exe -ArgumentList "-y" -WorkingDirectory napcat\onekey\files
```

安装完成后会得到 `napcat\onekey\files\NapCat.<版本>.Shell\`。

### 4. 阿里云百炼 CLI 与 Key

```powershell
npm install -g bailian-cli --registry=https://registry.npmjs.org
bl auth login --console
```

登录后 CLI 会自动创建 API Key。同步到项目：

```powershell
bot\.venv\Scripts\python.exe tools\apply_bailian_env.py
```

### 5. 配置

```powershell
Copy-Item bot\.env.example bot\.env
```

编辑 `bot\.env`：

- `SUPERUSERS`：你的 QQ 号
- `NICKNAME` / `AI_GROUPMATE__BOT_NAME`：Bot 的实际昵称（群友怎么叫它）
- `ONEBOT_ACCESS_TOKEN`：随机字符串
- `AI_GROUPMATE__ACTIVE_GROUP_PROBABILITIES`：重点群，例如 `{"123456789": 1.0}`
- 百炼 Key 已由同步脚本填好

把 WebSocket 配置写入 NapCat：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\apply-napcat-config.ps1
```

### 6. 初始化并启动

```powershell
powershell -ExecutionPolicy Bypass -File scripts\init-db.ps1
powershell -ExecutionPolicy Bypass -File scripts\start-all.ps1
```

在弹出的便携版 QQ 窗口用 **Bot 小号**扫码。登录后：

- NapCat WebUI：`http://127.0.0.1:6099/webui`
- NoneBot / 插件面板：`http://127.0.0.1:8080/ai-groupmate/usage`
- 把 Bot 拉进群，@ 一次即可开始

## 让某个群更活跃

上游插件把单群抽样概率硬限制在 0.1。本项目的补丁支持：

```dotenv
AI_GROUPMATE__REPLY_PROBABILITY=0.05
AI_GROUPMATE__ACTIVE_GROUP_PROBABILITIES={"123456789": 1.0}
```

含义：

- 其他群每条消息只有 5% 进入接话判断
- 重点群每条消息都进入判断
- Gatekeeper、冷却、频率上限、每日额度仍然生效，不会无限刷屏

> 概率高不等于一定回复；Gatekeeper 仍会判断语境。

## 验证

```powershell
powershell -ExecutionPolicy Bypass -File scripts\doctor.ps1
```

期望结果：

- 百炼 CLI 已登录
- Qdrant 正在运行
- 数据库已初始化
- NapCat token 与 `bot\.env` 一致
- `bot-run.log` 出现 `Bot <QQ> connected`

## 排错

- **NapCat 注入后没有窗口**：QQ 版本不匹配。使用 OneKey 便携版，不要用系统安装的普通 QQ。
- **OneBot 一直重连**：NapCat 未登录、3001 未监听、或 token 不一致。
- **Bot 不回复**：
  - `AI_GROUPMATE__BOT_NAME` 是否等于群友实际叫它的名字
  - 该群是否在 `ACTIVE_GROUP_PROBABILITIES`
  - 是否触发冷却 / 每日额度
  - Gatekeeper 可能判断“无需接话”
- **Embedding 401/404**：检查百炼 Key、`text-embedding-v4` 是否可用。
- **pip 代理错误**：系统代理未启动时，脚本会临时设置 `NO_PROXY=*`。
- **表情包不发送**：Qdrant 是否运行、图片是否达到收录次数、视觉模型是否可用。

## 小优化与实现细节

见 [docs/OPTIMIZATIONS.md](docs/OPTIMIZATIONS.md)。

## 安全

见 [SECURITY.md](SECURITY.md)。请务必使用小号、不要把 3001/6099/8080 暴露到公网、不要提交 `.env`。

## License

本项目 MIT。上游项目与 NapCat 的许可说明见 [NOTICE.md](NOTICE.md)。
