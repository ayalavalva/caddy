# Choose the exact Caddy and plugin versions you trust
ARG CADDY_VERSION=2.10.2
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@32b202f0a9530858ffc25bb29daec98977923229

FROM caddy:${CADDY_VERSION}-builder AS builder

# xcaddy expects the git tag with leading v
RUN xcaddy build "${CADDY_VERSION}" \
  --with "${CF_PLUGIN}" \
  --with "${TS_PLUGIN}"

FROM caddy:${CADDY_VERSION}

LABEL org.opencontainers.image.title="Caddy (Cloudflare DNS + Tailscale)" \
      org.opencontainers.image.description="Pinned Caddy build with Cloudflare DNS and Tailscale modules" \
      org.opencontainers.image.licenses="Apache-2.0"
      
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
