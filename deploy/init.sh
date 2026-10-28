#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [ ! -f ../bot/.env ]; then
  echo "缺少 ../bot/.env，请先复制 bot/.env.example 并填写。" >&2
  exit 1
fi

TOKEN=$(grep -E '^ONEBOT_ACCESS_TOKEN=' ../bot/.env | head -1 | cut -d= -f2-)
if [ -z "${TOKEN}" ] || [ "${TOKEN}" = "change-me-to-a-random-token" ]; then
  echo "请先把 bot/.env 的 ONEBOT_ACCESS_TOKEN 改成随机字符串。" >&2
  exit 1
fi

mkdir -p data/qdrant data/napcat/config data/napcat/qq data/bot data/bot-config data/bot-cache
sed "s|__ONEBOT_TOKEN__|${TOKEN}|g" napcat-config/onebot11.json > data/napcat/config/onebot11.json

if [ ! -f deploy.env ]; then
  if command -v openssl >/dev/null 2>&1; then
    WEBUI_TOKEN=$(openssl rand -hex 16)
  else
    WEBUI_TOKEN=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
  fi
  echo "NAPCAT_WEBUI_TOKEN=${WEBUI_TOKEN}" > deploy.env
  echo "已生成 deploy/deploy.env（NapCat WebUI token）"
fi
chmod 600 deploy.env ../bot/.env || true

sudo chown -R 1000:1000 data 2>/dev/null || true
sudo docker compose --env-file deploy.env -f docker-compose.yml up -d --build
sudo docker compose --env-file deploy.env -f docker-compose.yml ps
