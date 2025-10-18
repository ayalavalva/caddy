# Caddy (with Cloudflare + Tailscale plugins)

This repository builds a **reproducible**, **multi-arch** Caddy image with:
- **Cloudflare plugin**: `github.com/caddy-dns/cloudflare`
- **Tailscale plugin**: `github.com/tailscale/caddy-tailscale`

Images are published to **GitHub Container Registry (GHCR)**:

- ghcr.io/<owner>/<repo>:latest
- ghcr.io/<owner>/<repo>:<caddy_version>
- Traceability tags (branch/SHA) are added automatically

> ⚠️ GHCR paths must be **lowercase** (`<owner>/<repo>`).

---

## Why this repo?

Useful Caddy build with the ability to generate Cloudflare SSL certificates with DNS01, and with an extended Tailscale integration.

- **Reproducible**: Caddy and plugins are pinned (Caddy to a tag; plugins to a tag or commit).
- **Multi-arch**: Builds for `linux/amd64` and `linux/arm64`.
- **Automated**: CI watches for new Caddy releases and plugin updates, bumps the pins in the Dockerfile, and rebuilds.
- **Supply-chain**: Publishes SBOM and SLSA provenance for each image.

---

## How it works

- **Workflow**: `.github/workflows/build-docker.yml`
  - Triggers:
    - `push` to `main` (rebuilds only when relevant files change)
    - `pull_request` (build only; no push)
    - **Nightly schedule** (detects new upstreams)
    - Manual `workflow_dispatch`
  - **Detect & bump pins**
    - Gets latest stable Caddy tag.
    - Gets latest Cloudflare plugin tag.
    - Gets latest commit on main for Tailscale plugin (no upstream tags).
    - If any changed, CI commits updated pins directly to Dockerfile.
  - **Auto-bump pins**
    - If any upstream changed, CI commits updated pins to:
      - `Dockerfile` (`ARG CADDY_VERSION=…`)
      - `plugins.lock` (plugin refs)
  - **build & publish**:
    - Multi-arch build to GHCR.
    - Adds `latest`, `<caddy_version>`, branch and short-SHA tags.
    - Attaches SBOM/provenance.

---

## Pin locations (Dockerfile)

```
ARG CADDY_VERSION=2.10.2
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@<commit-sha>
```

> You normally don’t edit these by hand. The workflow detects upstream changes and updates these lines for you.

---

## Tags

Dockerfile (defaults; CI overrides via build-args):

- `latest` (default branch only)
- `<caddy_version>` (e.g. `2.10.2`)
- Branch and `git-<shortsha>` tags for traceability

---

## Pull & Run

If the package is public:

`docker pull ghcr.io/<owner>/<repo>:latest`

If private, authenticate first:

```bash
echo "<YOUR_GH_PAT>" | docker login ghcr.io -u <your_gh_user> --password-stdin
docker pull ghcr.io/<owner>/<repo>:latest
# or pin a version:
docker pull ghcr.io/<owner>/<repo>:2.10.2
```

> Create a classic GitHub PAT with read:packages (and write:packages if you push locally).

Run

```bash
docker run -d --name caddy \
  -p 80:80 -p 443:443 \
  -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/<owner>/<repo>:latest
```

---

## Making the package public

1. Repo → Packages (right sidebar) → select the container.
2. Package settings → Visibility → Public.
3. (Optional) Add description/README at the package level.

---

## File map

- `Dockerfile` — build recipe; pins `CADDY_VERSION`, `CF_PLUGIN`, `TS_PLUGIN`. CI updates these lines.
- `.github/workflows/build-docker.yml` — detects upstream updates, commits pin bumps, builds & publishes.
