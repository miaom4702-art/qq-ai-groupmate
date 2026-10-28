# Security

- Never commit `bot/.env`, API keys, OneBot tokens, QQ cookies, chat databases,
  downloaded images, or logs. They are covered by `.gitignore`.
- If a key or token is exposed, revoke it and generate a new one. Re-sync the
  Bailian key with `scripts/sync-bailian-key.ps1` and update the NapCat token.
- Keep `HOST=127.0.0.1` and do not expose ports 3001, 6099, or 8080 to the internet.
- Use a secondary QQ account for the bot. Third-party protocol implementations
  carry account-risk.
- Keep `AI_GROUPMATE__AGENT_FILE_TOOLS_ENABLED=false` unless you understand the
  risk of letting group members ask the bot to read files or fetch URLs.
- Group messages and stickers are stored locally for memory/RAG. Confirm your
  group's rules and privacy expectations before enabling collection.

Please report security issues privately to the repository owner rather than
opening a public issue with secrets.
