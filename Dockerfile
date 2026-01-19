FROM alpine:3.19

ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl \
    && update-ca-certificates

WORKDIR /opt/komari

# 下载对应架构的二进制文件
RUN curl -fsSL \
    https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-${TARGETARCH:-amd64} \
    -o agent \
 && chmod +x agent

# 定义默认环境变量（空值）
ENV DOMAIN=""
ENV TOKEN=""

RUN addgroup -S komari && adduser -S komari -G komari
USER komari

# 使用 sh -c 来确保环境变量被解析为启动参数
ENTRYPOINT ["sh", "-c", "/opt/komari/agent --server ${DOMAIN} --token ${TOKEN}"]
