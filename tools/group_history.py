import asyncio
import json
import os
from pathlib import Path

import websockets
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parents[1]
TOKEN = dotenv_values(ROOT / "bot" / ".env")["ONEBOT_ACCESS_TOKEN"]
GROUP = int(os.getenv("TARGET_GROUP_ID", "0"))


async def call(ws, action, params=None, echo="x"):
    await ws.send(json.dumps({"action": action, "params": params or {}, "echo": echo}))
    while True:
        msg = json.loads(await ws.recv())
        if msg.get("echo") == echo:
            return msg


async def main():
    if not GROUP:
        raise SystemExit("请先设置环境变量 TARGET_GROUP_ID，例如 $env:TARGET_GROUP_ID='123456789'")
    async with websockets.connect(
        "ws://127.0.0.1:3001",
        additional_headers={"Authorization": "Bearer " + TOKEN},
    ) as ws:
        res = await call(
            ws,
            "get_group_msg_history",
            {"group_id": GROUP, "count": 25},
            echo="h",
        )
        data = res.get("data") or {}
        msgs = data.get("messages") or []
        print("STATUS", res.get("status"), "COUNT", len(msgs))
        for m in msgs:
            sender = (m.get("sender") or {}).get("card") or (m.get("sender") or {}).get("nickname") or m.get("user_id")
            text = m.get("raw_message") or ""
            print(m.get("time"), m.get("user_id"), sender, repr(text[:120]))


asyncio.run(main())
