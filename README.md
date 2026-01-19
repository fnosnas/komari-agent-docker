
# Komari Agent Docker 镜像

本项目用于构建 Komari Monitor 的 Agent Docker 镜像。

---

## ⚙️ 需要配置的变量

在启动容器前，请先准备以下两个变量：

```text
DOMAIN=xxxxxxx
TOKEN=xxxxxx
示例：
https://komari.example.com
请在 Komari 管理面板中生成

Docker 启动
docker run -d \
  ghcr.io/你的用户名/komari-agent-docker/komari-agent:latest \
  -e $DOMAIN \
  -t $TOKEN
