# docker-library

Container image sources used across the platform (CI/CD pipelines, cluster ops, developer workflows). Each subdirectory = one image with its own `Dockerfile`, optional `Makefile`, and README.

## Current Images
| Directory | Purpose | Notes |
|-----------|---------|-------|
| `utils/`  | Multi-cloud & Kubernetes ops toolbox (kubectl, argocd, eksctl, aws, gcloud, az, gh, yq, etc.) | Version-pinned via build args; supports multi-arch builds |

## Quick Start (utils image)
```bash
# Build (defaults)
make -C utils build IMAGE_NAME=utils TAG=dev

# Override a tool version
make -C utils build TAG=dev BUILD_ARGS='--build-arg KUBECTL_VERSION=v1.32.0'

# Push
make -C utils push REGISTRY=ghcr.io/myorg IMAGE_NAME=utils TAG=dev

# Multi-arch push
make -C utils multi-arch REGISTRY=ghcr.io/myorg IMAGE_NAME=utils TAG=v1.0.0
```

Run ephemeral container:
```bash
docker run --rm -it \
  -v $HOME/.kube:/root/.kube \
  -v $HOME/.aws:/root/.aws \
  vaibhavthakur/utils:dev bash
```

## Adding a New Image
1. Create a directory: `mkdir <name>`
2. Add `Dockerfile` (pin base + primary tooling versions)
3. Add `README.md` (purpose, tools, usage)
4. (Optional) Add `Makefile` patterned after `utils/` for build/push/multi-arch
5. Test locally; consider `docker scout` / Trivy scan
6. Open PR / commit with concise changelog message

## Versioning & Tags
- Prefer semantic tags for stable (`vX.Y.Z`) and `-rc` or date tags for prerelease
- Add a git SHA tag (`make push-sha`) for immutable references
- Keep README tables in sync with default ARG versions

## Security & Hardening Guidelines
- Pin exact versions and/or image digests (`FROM ubuntu@sha256:<digest>`)
- Use multi-stage builds to discard build-only layers
- Drop privileges (non-root user) when runtime tooling permits
- Minimize layer count & remove package manager caches
- Scan regularly (e.g., Trivy / Grype) and patch promptly

## Common Build Args (utils)
See `utils/Dockerfile` `ARG` declarations (kubectl, argocd, eksctl, aws cli, etc.). Use `make print-versions` to list them.

## CI/CD (Suggested)
- Lint Dockerfiles (hadolint)
- Build & scan on PR
- Multi-arch publish on merge to main
- Optional SBOM generation (syft) & provenance (SLSA / cosign)


## License
Each image inherits upstream tool licenses; repository content itself MIT unless overridden in a subdirectory.

