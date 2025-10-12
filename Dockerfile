# Choose the exact Caddy and plugin versions you trust
ARG CADDY_VERSION=2.10.2

FROM caddy:${CADDY_VERSION}-builder AS builder

# xcaddy expects the git tag with leading v
RUN xcaddy build "v${CADDY_VERSION}" \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/tailscale/caddy-tailscale

FROM caddy:${CADDY_VERSION}

LABEL org.opencontainers.image.title="Caddy (Cloudflare DNS + Tailscale)" \
      org.opencontainers.image.description="Pinned Caddy build with Cloudflare DNS and Tailscale modules" \
      org.opencontainers.image.licenses="Apache-2.0"
      
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
