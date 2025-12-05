# --- Pinned, reproducible defaults (CI can override via --build-arg) ---
ARG CADDY_VERSION=2.10.2
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.2
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@f070d146dd6169aa29376ee9ac5a3e16763f9cb2

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
