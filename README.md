# Komari Agent Docker 镜像

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
  -t TOKEN="your_token_here" \
  ghcr.io/fnosnas/komari-agent-docker/komari-agent:latest
```

用Node.js环境:   
上传index.js  package.json    
一键运行：   
```
node index.js
```
注：如果你希望让它在后台持续挂机、关闭终端也不会断开，可以使用 nohup 或者 pm2 来守护：
```
nohup node index.js > output.log 2>&1 &
```

