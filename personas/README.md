# Personas

A persona is injected into `AI_GROUPMATE__PERSONALITY_SETTING` in `bot/.env`.

```powershell
bot\.venv\Scripts\python.exe tools\apply_persona.py
```

Default persona: [tsukishiro-yuki.md](tsukishiro-yuki.md).

The persona file is a system-prompt-style character card. It includes an
explicit safety boundary: no real-world harm instructions, no targeting real
group members, and drop the role if someone is in genuine distress.
