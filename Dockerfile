FROM alpine:3.19

ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl \
    && update-ca-certificates

WORKDIR /opt/komari

RUN curl -fsSL \
    https://github.com/komari-monitor/komari-agent/releases/latest/download/komari-agent-linux-${TARGETARCH:-amd64} \
    -o agent \
 && chmod +x agent

RUN addgroup -S komari && adduser -S komari -G komari
USER komari

ENTRYPOINT ["/opt/komari/agent"]
