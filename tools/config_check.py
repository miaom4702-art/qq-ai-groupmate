import os

import nonebot

nonebot.init()
nonebot.load_plugin("nonebot_plugin_ai_groupmate")

from nonebot_plugin_ai_groupmate.group_model_config import (  # noqa: E402
    resolve_group_reply_probability,
)
from nonebot_plugin_ai_groupmate.runtime_config import get_runtime_config  # noqa: E402

GROUP_ID = os.getenv("TARGET_GROUP_ID", "YOUR_GROUP_ID")
cfg = get_runtime_config()
print("reply_probability =", cfg.reply_probability, flush=True)
print("active_group_probabilities =", cfg.active_group_probabilities, flush=True)
print(f"group {GROUP_ID} =>", resolve_group_reply_probability(GROUP_ID), flush=True)
print("bot_name =", cfg.bot_name, flush=True)
os._exit(0)
