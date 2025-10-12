# Caddy (Cloudflare DNS + Tailscale) — built with GitHub Actions

This repository builds a **reproducible**, **multi-arch** Caddy image with:
- **Cloudflare DNS**: `github.com/caddy-dns/cloudflare`
- **Tailscale**: `github.com/tailscale/caddy-tailscale`

Images are published to **GitHub Container Registry (GHCR)**:

- ghcr.io/<owner>/<repo>:latest
- ghcr.io/<owner>/<repo>:<caddy_version>

> ⚠️ GHCR paths must be **lowercase** (`<owner>/<repo>`).

---

## Why this repo?

- **Reproducible**: `CADDY_VERSION` is pinned; plugins can be pinned to tags or commits.
- **Multi-arch**: `linux/amd64` and `linux/arm64`.
- **Automated**: A scheduled job checks upstream Caddy releases and auto-bumps `CADDY_VERSION`.
- **Supply-chain**: Publishes SBOM and SLSA provenance.

---

## How it works

- **Workflow**: `.github/workflows/build-docker.yml`
  - Triggers:
    - `push` to `main` (only rebuilds/pushes when relevant files change)
    - `pull_request` (builds, but does **not** push)
    - **Schedule** (daily) — checks for a new *stable* Caddy release
    - Manual `workflow_dispatch`
  - **check-caddy-version**:
    - Fetches the latest stable Caddy tag
    - Compares against `ARG CADDY_VERSION` in `Dockerfile`
    - If different, commits a bump (`chore: bump CADDY_VERSION to X.Y.Z`)
  - **build**:
    - Builds and (if not a PR) pushes a **multi-arch** image to GHCR
    - Emits **SBOM** and **provenance**

---

## Tags

- `latest` (default branch only)
- `<caddy_version>` (e.g. `2.10.2`)
- Additional branch/SHA tags for traceability

---

## Pinning strategy

- **Caddy**: pinned via `ARG CADDY_VERSION` (bumped automatically on new releases).
- **Cloudflare plugin**: **tagged** → pin to a tag (e.g. `@v0.2.1`).
- **Tailscale plugin**: **no tags** → pin to a **commit SHA** for reproducibility, or use `@main` if you accept tip-of-tree.

Edit these in the `Dockerfile`:

```dockerfile
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@<commit-sha-or-main>
```

## Pulling the image

If the package is public:

`docker pull ghcr.io/<owner>/<repo>:latest`

If private, authenticate first:

```
echo <YOUR_GH_PAT> | docker login ghcr.io -u <your_gh_user> --password-stdin
docker pull ghcr.io/<owner>/<repo>:latest
```

> Create a classic GitHub PAT with read:packages (and write:packages if you push locally).

## Run

```docker
docker run -d --name caddy \
  -p 80:80 -p 443:443 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile:ro \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/<owner>/<repo>:latest
```

## Making the package public

1. Repo → Packages (right sidebar) → select the container.
2. Package settings → Visibility → Public.
3. (Optional) Add description/README at the package level.

## Troubleshooting

- Build fails with ${CF_PLUGIN} / ${TS_PLUGIN}
Add ARG CF_PLUGIN / ARG TS_PLUGIN to the Dockerfile (with defaults), or hardcode the plugin strings in xcaddy build.

- 401 pulling from GHCR
Ensure the package is public or you’re logged in to GHCR with a PAT that has read:packages.

- Tag not found
Check that the workflow run finished successfully and that your image path is lowercase (ghcr.io/<owner>/<repo>).
