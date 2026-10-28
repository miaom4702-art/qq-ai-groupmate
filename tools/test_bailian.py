import json
import os
import sys

from openai import OpenAI

cfg = json.load(open(os.path.expanduser(r"~\.bailian\config.json"), encoding="utf-8"))
key = cfg["api_key"]
candidates = [
    "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "https://ws-8nwkpmsjob2xi08t.cn-beijing.maas.aliyuncs.com/compatible-mode/v1",
    "https://ws-8nwkpmsjob2xi08t.cn-beijing.maas.aliyuncs.com/v1",
]
for base in candidates:
    try:
        client = OpenAI(api_key=key, base_url=base, timeout=30)
        resp = client.chat.completions.create(
            model="qwen3.7-plus",
            messages=[{"role": "user", "content": "只回复 OK"}],
            max_tokens=10,
        )
        print("CHAT_OK", base, repr(resp.choices[0].message.content))
    except Exception as exc:
        msg = str(exc)
        if key in msg:
            msg = msg.replace(key, "***")
        print("CHAT_FAIL", base, type(exc).__name__, msg[:300])
