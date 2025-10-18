# --- Pinned, reproducible defaults (CI can override via --build-arg) ---
ARG CADDY_VERSION=2.10.2
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@01d084e119cb2ddb49630edb89bb5c6d7c4e8bc0

FROM caddy:${CADDY_VERSION}-builder AS builder

ARG CADDY_VERSION
ARG CF_PLUGIN
ARG TS_PLUGIN

RUN xcaddy build "v${CADDY_VERSION#v}" \
  --with "${CF_PLUGIN}" \
  --with "${TS_PLUGIN}"

FROM caddy:${CADDY_VERSION}

LABEL org.opencontainers.image.title="Caddy (Cloudflare DNS + Tailscale)" \
      org.opencontainers.image.description="Pinned Caddy build with Cloudflare DNS and Tailscale modules" \
      org.opencontainers.image.licenses="Apache-2.0"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
