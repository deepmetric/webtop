# Conservative overlay on your existing Webtop image.
# Keeps the original ENTRYPOINT/CMD and s6 service supervision.
FROM webtop:alpine-icewm

USER root

RUN set -eux; \
    if ! command -v chromium >/dev/null 2>&1 \
       && ! command -v chromium-browser >/dev/null 2>&1; then \
        apk add --no-cache chromium; \
    fi; \
    apk add --no-cache bash procps coreutils; \
    mkdir -p /opt/webtop/scripts /config/.config/chromium

COPY scripts/ /opt/webtop/scripts/
RUN chmod +x /opt/webtop/scripts/*.sh

ENV TZ=Asia/Kolkata \
    PUID=1000 \
    PGID=1000

EXPOSE 3001

# Intentionally do not override ENTRYPOINT or CMD.
