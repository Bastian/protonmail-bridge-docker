FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

ARG BRIDGE_VER=3.21.2-1
ARG BRIDGE_SHA256=4ab7ed9b55ac0461371180de5f231349e14dd5079c04e576654e23ddc1dbc9c7

RUN set -eux; \
    url="https://proton.me/download/bridge/protonmail-bridge_${BRIDGE_VER}_amd64.deb"; \
    wget -O /tmp/bridge.deb "$url"; \
    actual="$(sha256sum /tmp/bridge.deb | awk '{print $1}')"; \
    if [ "${BRIDGE_SHA256:-}" != "$actual" ]; then \
    echo "SHA256 mismatch. correct hash: $actual"; \
    exit 1; \
    fi; \
    apt-get update && apt-get install -y /tmp/bridge.deb; \
    rm -rf /var/lib/apt/lists/* /tmp/bridge.deb

RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 pass tini \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN useradd -m -s /bin/bash bridge
USER bridge
WORKDIR /home/bridge

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["protonmail-bridge", "--cli"]
