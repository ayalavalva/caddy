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
- **Automated**: CI watches for new Caddy releases and plugin updates, bumps pins in-repo, and rebuilds.
- **Supply-chain**: Publishes SBOM and SLSA provenance for each image.

---

## How it works

- **Workflow**: `.github/workflows/build-docker.yml`
  - Triggers:
    - `push` to `main` (only rebuilds/pushes when relevant files change)
    - `pull_request` (build only; no push)
    - **Nightly schedule** (detect new Caddy or plugin updates)
    - Manual `workflow_dispatch`
  - **Detect updates**
    - Gets latest stable Caddy release.
    - Gets latest tag for the Cloudflare plugin.
    - Gets latest commit on main for the Tailscale plugin (no tags upstream).
  - **Auto-bump pins**
    - If any upstream changed, CI commits updated pins to:
      - `Dockerfile` (`ARG CADDY_VERSION=…`)
      - `plugins.lock` (plugin refs)
  - **build & publish**:
    - Multi-arch build to GHCR.
    - Adds `latest`, `<caddy_version>`, branch and short-SHA tags.
    - Attaches SBOM/provenance.

---

## Where pins live

Dockerfile (defaults; CI overrides via build-args):

```
ARG CADDY_VERSION=2.10.2
ARG CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
ARG TS_PLUGIN=github.com/tailscale/caddy-tailscale@32b202f0a9530858ffc25bb29daec98977923229
```

---

## Tags

Dockerfile (defaults; CI overrides via build-args):

- `latest` (default branch only)
- `<caddy_version>` (e.g. `2.10.2`)
- Additional branch/SHA tags for traceability

plugins.lock (single source of truth for plugins; owned by CI):

```
CF_PLUGIN=github.com/caddy-dns/cloudflare@v0.2.1
TS_PLUGIN=github.com/tailscale/caddy-tailscale@32b202f0a9530858ffc25bb29daec98977923229
```

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

> You generally never edit pins by hand. CI bumps them when upstream changes are detected. If you do need a manual override, edit `plugins.lock` (for plugins) and/or the Dockerfile’s `CADDY_VERSION`, then push to `main`.

---

## Tags you’ll see

- `latest` (default branch only)
- `<caddy_version>` (e.g. `2.10.2`)
- `git-<shortsha>` and branch tags for traceability

Pull the immutable `<caddy_version>` tag in production if you want strict repeatability.

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

## Troubleshooting

**Why a `plugins.lock` file?**

It’s an auditable, single source of truth for plugin pins. CI reads it, bumps it when upstream changes, Dockerfile stays clean.

**Can I unpin plugins?**

Possible, but not recommended. Pinning ensures reproducible builds. This repo already auto-bumps to new versions/commits, so you get updates without losing control.

**I see a `git-<sha>` tag, what is it?**

A traceability tag tied to the repo commit that built the image. Use `<caddy_version>` for immutable pulls; `latest` for convenience.

**401 pulling from GHCR**

Make sure the package is public or login with a PAT that has `read:packages`.

**Tag not found**

Check that the latest workflow run succeeded and that your `ghcr.io/<owner>/<repo>` path is lowercase.

---

## File map

- `Dockerfile` — build recipe; accepts `CADDY_VERSION`, `CF_PLUGIN`, `TS_PLUGIN` build args.
- `plugins.lock` — plugin pins (tag or commit).
- `.github/workflows/build-docker.yml` — detects updates, bumps pins, builds & publishes.
