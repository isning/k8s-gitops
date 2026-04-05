Manual operations needed for Bay deployment. Please refer to the following steps:
1. Go to Astrbot Web UI (https://astrbot.isning.moe) and log in with your credentials.
2. Api Key is stored in shipyard-neo/secret.yaml, you can find it in the `api-key` field. Rotate it if you need to, but make sure to update the secret in Kubernetes and the Bay configuration accordingly.
3. Follow https://docs.astrbot.app/use/astrbot-agent-sandbox.html#%E9%85%8D%E7%BD%AE-shipyard-neo to set up Shipyard Neo, and use the copied API key when configuring Bay.

Manual operations needed for OneBot v11 adapters. Please refer to the following steps:
1. Go to Astrbot Web UI (https://astrbot.isning.moe) and log in with your credentials.
2. Add OneBot v11 protocol adapter in Astrbot Web UI accroding to https://docs.astrbot.app/platform/aiocqhttp.html#_1-%E9%85%8D%E7%BD%AE-onebot-v11 .
3. Ensure the WebSocket port is exposed in AstrBot deployment and service, and the WebSocket URL is accessible. The WebSocket URL should be in the format of `ws://<astrbot-service-url>/ws`, for example:
```url
ws://astrbot.prod.svc.cluster.local:6199/ws
```
4. Update the configuration of OneBot V11 implementation. (e.g. `napcat/onebot-secret.yaml` for Napcat).
