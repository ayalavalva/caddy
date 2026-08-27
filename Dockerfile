# --- Pinned, reproducible defaults (CI updates these; CI can also override via --build-arg if needed) ---
ARG CADDY_VERSION=2.11.4
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.4
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@de41b249af4fd2083612c3b2303197e92787d1c5

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
