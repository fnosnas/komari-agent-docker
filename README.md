# Komari Agent Docker 镜像

Fork本项目到你自己GitHub用于构建镜像,自己改个镜像名,用同名容器平台会GG

---

## ⚙️ 环境变量配置

在启动容器时，请设置以下环境变量：

| 变量名 | 说明 | 示例 |
| :--- | :--- | :--- |
| `DOMAIN` | 服务端 API 地址 (需包含协议头) | `https://komari.example.com` |
| `TOKEN` | 在管理面板生成的 Agent Token | `your_token_here` |

---

## 🚀 启动命令

### Docker Run
```bash
docker run -d \
  --name komari-agent \
  --restart always \
  --network host \
  -e DOMAIN="https://komari.example.com" \
  -e TOKEN="your_token_here" \
  ghcr.io/fnosnas/komari-agent-docker/komari-agent:latest
