FROM alpine:3.19

ARG TARGETARCH

# 基础依赖
RUN apk add --no-cache ca-certificates curl bash \
    && update-ca-certificates

WORKDIR /opt/komari

# 下载 Komari Agent 二进制
RUN curl -fsSL \
    https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-${TARGETARCH:-amd64} \
    -o agent \
 && chmod +x agent

# 平台环境变量（由 Zeabur / Claw Cloud / Railway 注入）
ENV DOMAIN=""
ENV TOKEN=""
ENV RESTART_DELAY=5

# 非 root 用户
RUN addgroup -S komari && adduser -S komari -G komari
USER komari

# =========================
# 自动重连 + 常驻 ENTRYPOINT
# =========================
ENTRYPOINT ["bash", "-c", "\
set -e; \
echo \"Komari Agent Docker (auto-restart mode)\"; \
if [ -z \"$DOMAIN\" ] || [ -z \"$TOKEN\" ]; then \
  echo \"[FATAL] DOMAIN or TOKEN is empty\"; \
  echo \"Please set DOMAIN and TOKEN environment variables\"; \
  echo \"Container will stay alive for inspection\"; \
  sleep infinity; \
fi; \
\
while true; do \
  echo \"[INFO] Starting Komari Agent...\"; \
  /opt/komari/agent -e \"$DOMAIN\" -t \"$TOKEN\"; \
  CODE=$?; \
  echo \"[WARN] Agent exited with code $CODE\"; \
  echo \"[INFO] Restarting in ${RESTART_DELAY}s...\"; \
  sleep ${RESTART_DELAY}; \
done \
"]
