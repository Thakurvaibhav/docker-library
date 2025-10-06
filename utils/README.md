# utils Container Image

A utility CLI toolbox image for multi-cloud (AWS, Azure, GCP) and Kubernetes platform operations. Provides pinned versions of common cluster + GitOps tooling with easy upgrade via Docker build args.

## Included Tooling (Versions)
| Tool | Version Arg | Default | Purpose |
|------|-------------|---------|---------|
| Ubuntu Base | n/a | 22.04 | Stable LTS base (glibc + apt ecosystem) |
| Python | PYTHON_VERSION | 3.12 | Automation / scripting / SDKs |
| kubectl | KUBECTL_VERSION | v1.32.0 | Kubernetes API client |
| yq | YQ_VERSION | v4.44.3 | YAML processing (jq-style) |
| Argo CD CLI | ARGOCD_VERSION | v3.1.8 | GitOps operations (apps, diffs, rollbacks) |
| eksctl | EKSCTL_VERSION | v0.214.0 | Amazon EKS cluster + nodegroup management |
| aws-iam-authenticator | AWS_IAM_AUTH_VERSION | 0.7.3 | EKS IAM auth support |
| AWS CLI v2 | AWSCLI_VERSION | 2.17.40 | AWS API / EKS / IAM / STS operations |
| img | IMG_VERSION | v0.5.11 | Rootless container image builder |
| kubelogin (Azure) | KUBELOGIN_VERSION | v0.1.3 | OIDC auth helper for AKS / kubectl exec |
| Azure CLI | (apt latest) | latest | Azure resource & AKS management |
| GitHub CLI | GH_VERSION | 2.60.1 | Repo / workflow automation |
| Google Cloud SDK | (latest) | rolling | GKE / GCS / IAM operations |
| jq | (apt) | latest | JSON processing |
| curl / wget | (apt) | latest | HTTP retrieval |
| redis-tools | (apt) | latest | Redis CLI debugging |
| netcat-openbsd, httping, bind9-host, dnsutils | (apt) | latest | Network / DNS diagnostics |
| openssh-client | (apt) | latest | Git + SSH operations |
| p7zip-full | (apt) | latest | Archive extraction |

## Build (Docker CLI)
```bash
docker build -t my-utils:latest \
  --build-arg KUBECTL_VERSION=v1.32.0 \
  --build-arg ARGOCD_VERSION=v3.1.8 .
```
Omit args to use defaults.

## Build / Push (Makefile)
The included `Makefile` supports quick builds and pushes.

Targets:
- `make build` (vars: IMAGE_NAME, REGISTRY, TAG, BUILD_ARGS)
- `make push` (build + push TAG)
- `make push-sha` (adds git short SHA tag)
- `make multi-arch` (amd64 + arm64 via buildx and push)
- `make clean` (remove local image)
- `make print-versions` (list ARG lines from Dockerfile)

Examples:
```bash
# Build with default registry (ghcr.io/$USER)
make build IMAGE_NAME=utils TAG=v1.0.0

# Build overriding kubectl and argo-cd versions
make build TAG=test-build BUILD_ARGS='--build-arg KUBECTL_VERSION=v1.31.3 --build-arg ARGOCD_VERSION=v3.0.4'

# Build and push
make push TAG=v1.0.0 REGISTRY=ghcr.io/myorg IMAGE_NAME=utils

# Multi-arch push
make multi-arch TAG=v1.0.0 REGISTRY=ghcr.io/myorg IMAGE_NAME=utils

# Add separate git sha tag
make push-sha TAG=v1.0.0 REGISTRY=ghcr.io/myorg IMAGE_NAME=utils
```

## Run (Ephemeral)
```bash
docker run --rm -it \
  -v $HOME/.kube:/root/.kube \
  -v $HOME/.config/gcloud:/root/.config/gcloud \
  -v $HOME/.aws:/root/.aws \
  -v $HOME/.azure:/root/.azure \
  my-utils:latest bash
```

## Updating Tool Versions
1. Edit ARG defaults in `Dockerfile` or pass `--build-arg` at build time.
2. Rebuild (or `make build`). Version summary prints at end of build for verification.

## Authentication Notes
- AWS: Relies on host-mounted `~/.aws` for credentials / SSO cache.
- GCP: Mount gcloud config; run `gcloud auth login` inside container if interactive.
- Azure: `az login` (device code or service principal) refreshes tokens in mounted `~/.azure`.
- GitHub: `gh auth login` (token) persisted in `~/.config/gh` if mounted.

## Rootless Image Builds (img)
The `img` tool supports building OCI images without Docker daemon. Example:
```bash
img build -t myrepo/app:dev .
```
For large builds allocate additional storage via mounted volume (e.g. `-v img-cache:/root/.local/share/img`).

## Kubernetes Context
Ensure kubeconfig is mounted. For multiple contexts:
```bash
kubectl config get-contexts
kubectl config use-context prod
```

## Argo CD Usage
```bash
argocd login argocd.mydomain.com --sso
argocd app list
argocd app diff platform --revision HEAD
```

## Security Hardening Suggestions
- Pin digest instead of tag for base image: `FROM ubuntu@sha256:<digest>`.
- Enable non-root user (add user + chown writable dirs) if writing artifacts.
- Use minimal CA trust injection if corporate proxy certs needed.
- Consider multi-stage to trim build dependencies (keep only binaries).

## Extending
Add additional tools by introducing new ARG + curl URL; mimic existing pattern and append to the version summary block.

## License
Tool binaries subject to their upstream licenses; this Dockerfile itself MIT.
