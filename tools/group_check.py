import asyncio
import json
import os
from pathlib import Path

import websockets
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parents[1]
TOKEN = dotenv_values(ROOT / "bot" / ".env")["ONEBOT_ACCESS_TOKEN"]
TARGET_GROUP_ID = os.getenv("TARGET_GROUP_ID", "")


async def call(ws, action, params=None, echo="x"):
    await ws.send(json.dumps({"action": action, "params": params or {}, "echo": echo}))
    while True:
        msg = json.loads(await ws.recv())
        if msg.get("echo") == echo:
            return msg


async def main():
    async with websockets.connect(
        "ws://127.0.0.1:3001",
        additional_headers={"Authorization": "Bearer " + TOKEN},
    ) as ws:
        groups = (await call(ws, "get_group_list", echo="g")).get("data") or []
        print("COUNT", len(groups))
        for g in groups:
            print(g.get("group_id"), g.get("group_name"))
        if TARGET_GROUP_ID:
            target = next(
                (g for g in groups if str(g.get("group_id")) == TARGET_GROUP_ID),
                None,
            )
            print("TARGET_PRESENT", bool(target))
            if target:
                print(json.dumps(target, ensure_ascii=False))


asyncio.run(main())
