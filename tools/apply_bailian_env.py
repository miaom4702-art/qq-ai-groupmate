import json
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
cfg_path = Path.home() / ".bailian" / "config.json"
env_path = ROOT / "bot" / ".env"

cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
key = cfg["api_key"]
base = "https://dashscope.aliyuncs.com/compatible-mode/v1"

updates = {
    "AI_GROUPMATE__LLM_API_KEY": key,
    "AI_GROUPMATE__LLM_BASE_URL": base,
    "AI_GROUPMATE__CHAT_MODEL": "qwen3.7-plus",
    "AI_GROUPMATE__CHAT_MULTIMODAL": "true",
    "AI_GROUPMATE__CHAT_MAX_TOKENS": "8192",
    "AI_GROUPMATE__FLASH_MODEL": "qwen-flash",
    "AI_GROUPMATE__FLASH_MAX_TOKENS": "128",
    "AI_GROUPMATE__SUMMARY_MODEL": "qwen-flash",
    "AI_GROUPMATE__TAGGING_MODEL": "qwen3-vl-plus",
    "AI_GROUPMATE__TAGGING_API_KEY": key,
    "AI_GROUPMATE__TAGGING_BASE_URL": base,
    "AI_GROUPMATE__VISION_MODEL": "qwen3-vl-plus",
    "AI_GROUPMATE__VISION_API_KEY": key,
    "AI_GROUPMATE__VISION_BASE_URL": base,
    "AI_GROUPMATE__EMBEDDING_API_KEY": key,
    "AI_GROUPMATE__EMBEDDING_BASE_URL": base,
    "AI_GROUPMATE__EMBEDDING_MODEL": "text-embedding-v4",
    "AI_GROUPMATE__EMBEDDING_DIMENSION": "1024",
    "AI_GROUPMATE__MEME_EMBEDDING_MODE": "text",
}

lines = env_path.read_text(encoding="utf-8").splitlines()
seen = set()
out = []
for line in lines:
    m = re.match(r"^([A-Z0-9_]+)=(.*)$", line)
    if m and m.group(1) in updates:
        name = m.group(1)
        out.append(f"{name}={updates[name]}")
        seen.add(name)
    else:
        out.append(line)

for name, value in updates.items():
    if name not in seen:
        out.append(f"{name}={value}")

env_path.write_text("\n".join(out) + "\n", encoding="utf-8")

masked = key[:6] + "..." + key[-4:]
print("updated:", ", ".join(sorted(updates)))
print("key_masked:", masked)
print("base_url:", base)
