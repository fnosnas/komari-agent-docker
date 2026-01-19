FROM alpine:3.19

ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl \
    && update-ca-certificates

WORKDIR /opt/komari

# 下载 Agent 二进制文件
RUN curl -fsSL \
    https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-${TARGETARCH:-amd64} \
    -o agent \
 && chmod +x agent

# 对应你 Claw Cloud 截图中的 Key
ENV DOMAIN=""
ENV TOKEN=""

RUN addgroup -S komari && adduser -S komari -G komari
USER komari

# 使用 sh -c 来执行命令，并将环境变量注入到正确的参数中 (-e 和 -t)
ENTRYPOINT ["sh", "-c", "/opt/komari/agent -e ${DOMAIN} -t ${TOKEN}"]
