FROM ubuntu:22.04

# Version args for easier upgrades
ARG KUBECTL_VERSION=v1.32.0
ARG YQ_VERSION=v4.44.3
ARG ARGOCD_VERSION=v3.1.8
ARG EKSCTL_VERSION=v0.214.0
ARG AWS_IAM_AUTH_VERSION=0.7.3
ARG KUBELOGIN_VERSION=v0.1.3
ARG GH_VERSION=2.60.1
ARG IMG_VERSION=v0.5.11
ARG PYTHON_VERSION=3.12
ARG AWSCLI_VERSION=2.17.40

# Avoid interactive tzdata / locale dialogs
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Install common packages (include tzdata first to satisfy locale setup without prompt)
RUN set -eux; \
  ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime; \
  apt-get update; \
  apt-get install --no-install-recommends -y tzdata; \
  apt-get install --no-install-recommends -y \
    locales bind9-host curl dnsutils httpie iputils-ping jq netcat-openbsd \
    net-tools redis-tools swaks telnet vim nano wget python3-pip python3-venv \
    openssh-client p7zip-full httping uidmap ca-certificates gnupg unzip software-properties-common; \
  rm -rf /var/lib/apt/lists/*; \
  dpkg-reconfigure --frontend noninteractive tzdata || true

# Install newer Python (optional override via deadsnakes if > distro default)
RUN set -eux; \
  apt-get update; \
  apt-get install -y software-properties-common; \
  add-apt-repository ppa:deadsnakes/ppa -y; \
  apt-get update; \
  apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev; \
  rm -f /usr/bin/python /usr/bin/python3; \
  ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3; \
  ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python; \
  python --version; \
  rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (pinned, fallback to latest if specific version not found)
RUN set -eux; \
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o /tmp/awscliv2.zip || \
    (echo "[WARN] Specific AWS CLI version ${AWSCLI_VERSION} not found, using latest" && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip); \
  unzip -q /tmp/awscliv2.zip -d /tmp; \
  /tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update; \
  aws --version || true; \
  rm -rf /tmp/aws /tmp/awscliv2.zip

# Google Cloud SDK
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
RUN echo "Y" | gcloud components install beta
RUN echo "Y" | gcloud components install gke-gcloud-auth-plugin

# Update kubectl
RUN set -eux; \
  curl -fsSL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl; \
  chmod +x /usr/local/bin/kubectl; \
  kubectl version --client --output=yaml || true

# yq v4
RUN set -eux; \
  curl -fsSL https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq; \
  chmod +x /usr/local/bin/yq; yq --version

# Argo CD CLI
RUN set -eux; \
  curl -fsSL https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/bin/argocd; \
  chmod +x /usr/bin/argocd; argocd version --client || true

# img (container builder)
RUN set -eux; \
  curl -fsSL https://github.com/genuinetools/img/releases/download/${IMG_VERSION}/img-linux-amd64 -o /usr/bin/img; \
  chmod +x /usr/bin/img; /usr/bin/img --version || true

# eksctl
RUN set -eux; \
  curl -fsSL https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz | tar xz -C /tmp; \
  mv /tmp/eksctl /usr/bin/eksctl; chmod +x /usr/bin/eksctl; eksctl version || true

# aws-iam-authenticator
RUN set -eux; \
  curl -fsSL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 -o /usr/bin/aws-iam-authenticator; \
  chmod +x /usr/bin/aws-iam-authenticator; aws-iam-authenticator version || true

# Azure CLI (latest) & kubelogin
RUN set -eux; \
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null; \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list; \
  apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli; \
  curl -fsSL https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip -o /tmp/kubelogin.zip; \
  unzip /tmp/kubelogin.zip -d /tmp; mv /tmp/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin; chmod +x /usr/local/bin/kubelogin; kubelogin --version || true; \
  rm -rf /var/lib/apt/lists/* /tmp/kubelogin.zip /tmp/bin

# GitHub CLI
RUN set -eux; \
  curl -fsSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz | tar xz -C /tmp; \
  mv /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/bin/gh; chmod +x /usr/bin/gh; gh --version || true; \
  rm -rf /tmp/gh_${GH_VERSION}_linux_amd64

# SSH known hosts & config
RUN set -eux; mkdir -p /root/.ssh; ssh-keyscan github.com >> /root/.ssh/known_hosts; \
  printf 'Host github.com\n  Hostname github.com\n  IdentityFile ~/.ssh/id_rsa\n' > /root/.ssh/config; chmod 600 /root/.ssh/config

# Locale
RUN set -eux; locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Show versions summary (non-fatal)
RUN set -eux; \
  echo "== Tool Versions =="; \
  python --version || true; \
  kubectl version --client --short || true; \
  eksctl version || true; \
  argocd version --client || true; \
  yq --version || true; \
  gh --version || true; \
  aws-iam-authenticator version || true; \
  aws --version || true; \
  kubelogin --version || true