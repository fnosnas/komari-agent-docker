FROM alpine:3.19

ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl bash wget \
    && update-ca-certificates

WORKDIR /opt/komari

ENV DOMAIN=""
ENV TOKEN=""
ENV RESTART_DELAY=5
ENV AGENT_VERSION=1.1.93

RUN addgroup -S komari && adduser -S komari -G komari
USER komari

ENTRYPOINT ["bash", "-c", "\
set -e; \

echo '==================================='; \
echo ' Komari Agent Container Supervisor '; \
echo '==================================='; \

if [ -z \"$DOMAIN\" ] || [ -z \"$TOKEN\" ]; then \
  echo '[FATAL] DOMAIN or TOKEN is empty'; \
  sleep infinity; \
fi; \

ARCH=${TARGETARCH}; \
if [ -z \"$ARCH\" ]; then \
  ARCH=$(uname -m); \
  case $ARCH in \
    x86_64) ARCH=amd64 ;; \
    aarch64) ARCH=arm64 ;; \
    *) echo 'Unsupported architecture'; exit 1 ;; \
  esac; \
fi; \

echo \"[INFO] Detected arch: $ARCH\"; \

download_agent() { \
  echo '[INFO] Downloading Komari Agent version:' ${AGENT_VERSION}; \
  wget -q -O /opt/komari/agent \
  https://github.com/komari-monitor/komari-agent/releases/download/${AGENT_VERSION}/komari-agent-linux-${ARCH}; \
  chmod +x /opt/komari/agent; \
}; \

if [ ! -f /opt/komari/agent ]; then \
  download_agent; \
fi; \

while true; do \
  echo '[INFO] Launching Komari Agent...'; \
  /opt/komari/agent -e \"$DOMAIN\" -t \"$TOKEN\" & \
  PID=$!; \

  while kill -0 $PID 2>/dev/null; do \
    sleep 10; \
  done; \

  echo '[WARN] Agent crashed or disconnected'; \
  echo '[INFO] Re-downloading binary in case of update'; \
  download_agent; \
  echo '[INFO] Restarting in' ${RESTART_DELAY}s; \
  sleep ${RESTART_DELAY}; \
done \
"]
