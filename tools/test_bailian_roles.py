import base64
import io
import json
import os

from openai import OpenAI
from PIL import Image, ImageDraw

cfg = json.load(open(os.path.expanduser(r"~\.bailian\config.json"), encoding="utf-8"))
key = cfg["api_key"]
base = "https://dashscope.aliyuncs.com/compatible-mode/v1"
client = OpenAI(api_key=key, base_url=base, timeout=60)

for model in ("qwen-flash", "qwen3.7-plus"):
    try:
        resp = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": "只回复 OK"}],
            max_tokens=10,
        )
        print("TEXT_OK", model, repr(resp.choices[0].message.content))
    except Exception as exc:
        print("TEXT_FAIL", model, str(exc)[:300])

try:
    resp = client.embeddings.create(
        model="text-embedding-v4",
        input=["群友表情包：猫猫大笑"],
        dimensions=1024,
    )
    print("EMBED_OK", len(resp.data[0].embedding))
except Exception as exc:
    print("EMBED_FAIL", str(exc)[:400])

img = Image.new("RGB", (128, 128), "white")
draw = ImageDraw.Draw(img)
draw.rectangle((20, 50, 108, 90), fill="black")
buf = io.BytesIO()
img.save(buf, format="PNG")
data_uri = "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()

for model in ("qwen3-vl-plus", "qwen3.7-plus"):
    try:
        resp = client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "用一句话描述图片。"},
                        {"type": "image_url", "image_url": {"url": data_uri}},
                    ],
                }
            ],
            max_tokens=80,
        )
        print("VISION_OK", model, repr(resp.choices[0].message.content))
    except Exception as exc:
        print("VISION_FAIL", model, str(exc)[:400])
