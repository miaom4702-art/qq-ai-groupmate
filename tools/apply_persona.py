import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERSONA = ROOT / "personas" / "tsukishiro-yuki.md"
ENV = ROOT / "bot" / ".env"

if not PERSONA.exists():
    raise SystemExit(f"missing persona: {PERSONA}")
if not ENV.exists():
    raise SystemExit(f"missing env: {ENV}")

text = PERSONA.read_text(encoding="utf-8").strip()
value = text.replace("\\", "\\\\").replace('"', '\\"').replace("\r\n", "\n").replace("\n", "\\n")

lines = ENV.read_text(encoding="utf-8").splitlines()
out = []
found = False
for line in lines:
    if re.match(r"^AI_GROUPMATE__PERSONALITY_SETTING=", line):
        out.append(f'AI_GROUPMATE__PERSONALITY_SETTING="{value}"')
        found = True
    else:
        out.append(line)
if not found:
    out.append(f'AI_GROUPMATE__PERSONALITY_SETTING="{value}"')

ENV.write_text("\n".join(out) + "\n", encoding="utf-8")
print(f"persona injected: {len(text)} chars")
