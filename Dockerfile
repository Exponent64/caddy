ARG UID=1056
ARG GID=1056

FROM docker.io/caddy:builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM docker.io/caddy:latest

ARG UID
ARG GID

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk -U upgrade \
    && apk add libstdc++ \
    && rm -rf /var/cache/apk/*

RUN --network=none \
    addgroup -g ${GID} caddy \
    && adduser -u ${UID} --ingroup caddy --disabled-password --system caddy

COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

USER caddy
