# Caddy (Cloudflare DNS + Tailscale) — Docker Image via GitHub Actions

This repository builds a **reproducible**, **multi-arch** Caddy Docker image with:
- **Cloudflare DNS** plugin: `github.com/caddy-dns/cloudflare`
- **Tailscale** plugin: `github.com/tailscale/caddy-tailscale`

Images are published to **GitHub Container Registry (GHCR)**:

ghcr.io/<owner>/<repo>:latest
ghcr.io/<owner>/<repo>:<caddy_version>

> Note: GHCR namespace must be **lowercase** (owner and repo).

It tags images as:
- `latest` (only on the default branch)
- `<CADDY_VERSION>` (e.g., `2.10.2`)

## Why this repo?
- **Reproducibility**: Caddy base image is pinned via `ARG CADDY_VERSION`.
- **Safety**: You can (optionally) pin plugin versions to avoid surprise breakage.
- **Multi-arch**: Builds for `linux/amd64` and `linux/arm64`.
- **Automation**: A scheduled job checks for new Caddy releases and auto-bumps `CADDY_VERSION`.

## How it works

- **Workflow**: `.github/workflows/build-docker.yml`
  - Triggers on:
    - `push` to `main` (Dockerfile or workflow changes)
    - `pull_request` (build only, no push)
    - **Schedule**: daily check for a new Caddy release (stable)
    - Manual `workflow_dispatch`
  - Job **check-caddy-version**:
    - Fetches the latest **stable** Caddy release from GitHub
    - Compares with `ARG CADDY_VERSION` in `Dockerfile`
    - If changed, commits a bump to the repo
  - Job **build**:
    - Builds and (if not PR) pushes a **multi-arch** image
    - Emits **SBOM** and **provenance** metadata

## Multi-arch

Images are built for:

- linux/amd64
- linux/arm64

## Provenance & SBOM

The workflow publishes SLSA provenance and SBOM, so you can trace build inputs and dependencies.

## Registries

This setup pushes to **Docker Hub**. Set the following **repository secrets**:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD` (or an access token)

Change the `images:` in the `docker/metadata-action` step if you prefer GHCR:
```yaml
with:
  images: ghcr.io/<owner>/<repo>
```

## Usage

Replace … with your Caddyfile/binds:

```docker
docker run -d --name caddy \
  -p 80:80 -p 443:443 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile:ro \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/<owner>/<repo>:latest
```
