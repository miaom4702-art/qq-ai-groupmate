# Changelog

## v1.0.0 — 2026-10-28

首个公开版本：一个可自主参与 QQ 群聊的智能体。

### 核心能力

- NapCatQQ + OneBot v11 WebSocket + NoneBot2 的完整接入链路
- 群聊自主参与：概率抽样 + Gatekeeper 语境判断 + 冷却与频率限制
- 长期记忆：最近消息、群体认知档案、明确记忆、聊天 RAG
- 上下文压缩：后台摘要与语义检索，避免长群聊无限堆叠原文
- 表情包学习：收集、去重、视觉标注、文本向量化、语义检索与发送
- 单群活跃度补丁：重点群可突破上游 0.1 的主动抽样上限，其他群不受影响
- 人设、昵称、防抖、连续对话窗口与收录阈值可配置

### 部署

- Windows 本地：Python 3.12 + OneKey 便携版 QQ + NapCat
- Linux 云服务器：Docker Compose 编排 Qdrant / NapCat / Bot
- Bot 容器启动前自动执行 `nb orm upgrade`
- 支持 NapCat `ACCOUNT` 快速登录
- 端口最小暴露：OneBot/Qdrant 走容器网络，NapCat WebUI 仅本机

### 文档

- [技术报告 PDF](docs/QQ-AI-Groupmate-Technical-Report.pdf)
- [优化说明](docs/OPTIMIZATIONS.md)
- [Docker 部署说明](deploy/README.md)

### 已知限制

- QQ 第三方协议端存在账号风控风险；请使用专用小号
- 公网访问 Bot WebUI 需在阿里云安全组放行 TCP 18080
- 1.6 GiB 内存的 ECS 资源偏紧，建议 2 GiB 以上
- QQ 登录态失效时需要重新扫码；`ACCOUNT` 只能缓解进程重启场景

### 许可

MIT。第三方组件与 NapCat 的许可说明见 [NOTICE.md](NOTICE.md)。
