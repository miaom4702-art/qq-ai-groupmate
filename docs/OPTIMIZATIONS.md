# Small, reproducible optimizations

This project intentionally stays close to the upstream
`nonebot-plugin-ai-groupmate` design. The following changes are small and
focused on group-chat quality rather than rewriting the agent.

## 1. Per-group activity without a separate model

Upstream only allows a group-level proactive probability together with a
group-owned API configuration, and its local sampling hard-caps the probability
at 0.1. That makes a single active group hard to tune.

Patch: `patches/ai-groupmate-active-groups.patch`

- Adds `AI_GROUPMATE__ACTIVE_GROUP_PROBABILITIES`, e.g.
  `{"123456789": 1.0}`.
- Resolves that value before the group/global fallback.
- Allows the configured active group to exceed the old 0.1 cap while leaving
  all other groups capped at 0.1.

Apply it with:

```powershell
D:\QQ-AI-Bot\scripts\apply-ai-groupmate-patch.ps1
```

The patch was tested against upstream 2.5.16. If upstream changes those
functions, apply it manually and re-run the tests.

## 2. Bot identity and nicknames

Set `AI_GROUPMATE__BOT_NAME` and `NICKNAME` to the name group members actually
use. Upstream uses the bot name for direct-address detection and disengagement
phrases; keeping a stale placeholder makes the bot ignore messages like
“yuki 在吗”.

## 3. Group-chat persona

The persona prompt now explicitly asks for:

- short, spoken-style turns, one point at a time
- ACG/anime/game context awareness
- reading context before explaining an unfamiliar meme
- no AI self-introduction, no summaries or lectures every turn
- silence when there is nothing useful to add

This is configuration-only (`AI_GROUPMATE__PERSONALITY_SETTING`).

## 4. Context window tuning

- `GROUP_MESSAGE_DEBOUNCE_SECONDS=1.5` collects a little more context before a
  turn.
- `CONTINUOUS_CONVERSATION_MINUTES=8` follows a thread longer without turning
  every message into a new conversation.
- `MEDIA_VECTORIZE_MIN_REFERENCES=2` learns frequently used stickers sooner
  while avoiding collecting every one-off photo.
- Upstream still handles rolling summaries, group memory, RAG and long-context
  compression; no custom summarizer is needed.

## 5. Sampling strategy

- Global `REPLY_PROBABILITY=0.05` keeps the bot quiet in unrelated groups.
- `ACTIVE_GROUP_PROBABILITIES` gives the target group a much higher chance.
- Upstream cooldowns, per-group rate limits, Gatekeeper judgment, and the daily
  quota remain in force, so a high probability does not mean replying to every
  message.

## 6. Model roles

One Bailian key is reused with role-specific models:

| Role | Model |
|---|---|
| chat / tools | `qwen3.7-plus` |
| gatekeeper | `qwen-flash` |
| summary | `qwen-flash` |
| sticker tagging / vision | `qwen3-vl-plus` |
| embeddings (1024d) | `text-embedding-v4` |
