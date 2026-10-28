# Linux / Docker deployment

Target: Ubuntu 22.04/24.04 with Docker and Docker Compose.

## Ports

| Port | Service | Exposure |
|---|---|---|
| `18080` | NoneBot / plugin WebUI | public, open this in the Aliyun security group |
| `16099` | NapCat WebUI | localhost only; use an SSH tunnel |
| `3001` | OneBot WebSocket | Docker network only |
| `6333` | Qdrant | Docker network only |

## Steps

```bash
git clone https://github.com/miaom4702-art/qq-ai-groupmate.git
cd qq-ai-groupmate
cp bot/.env.example bot/.env
# edit bot/.env: keys, SUPERUSERS, ONEBOT_ACCESS_TOKEN, target group

bash deploy/init.sh
```

`init.sh` writes the NapCat WebSocket token, generates `deploy/deploy.env`,
builds the bot image, and starts Qdrant + NapCat + bot.

## First QQ login

NapCat is headless. Either read the QR from logs:

```bash
sudo docker compose --env-file deploy/deploy.env -f deploy/docker-compose.yml logs -f napcat
```

or tunnel the WebUI to your local machine:

```bash
ssh -L 16099:127.0.0.1:16099 admin@<server-ip>
```

Then open `http://127.0.0.1:16099/webui?token=<NAPCAT_WEBUI_TOKEN>`.

Scan with the **bot account**. After login, NapCat writes
`data/napcat/config/onebot11_<QQ>.json` and the bot connects.

## Security group

The server's local firewall is inactive, but Aliyun security groups still block
ports. Add an inbound rule:

- Protocol: TCP
- Port: `18080`
- Source: your IP (recommended) or `0.0.0.0/0`

The plugin WebUI is then at:

```text
http://<server-ip>:18080/ai-groupmate/usage
```

Use the `AI_GROUPMATE__USAGE_WEBUI_TOKEN` from `bot/.env`.

## Memory

1.6 GB RAM + 2 GB swap is tight but workable. Watch:

```bash
free -h
sudo docker stats
```

If the server OOMs, add another 2 GB swap or move Qdrant to a remote instance.

## Stopping / updating

```bash
sudo docker compose --env-file deploy/deploy.env -f deploy/docker-compose.yml down
git pull
bash deploy/init.sh
```
