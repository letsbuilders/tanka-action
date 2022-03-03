FROM debian:buster-slim

LABEL org.opencontainers.image.source="https://github.com/letsbuilders/tanka-action"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq curl unzip git

# jsonnet bunlder
RUN curl -Lo /usr/local/bin/jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.4.0/jb-linux-amd64 \
    && chmod +x /usr/local/bin/jb \
    && jb --version

# kubectl
RUN curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client=true

# tanka
RUN curl -Lo /usr/local/bin/tk https://github.com/grafana/tanka/releases/download/v0.14.0/tk-linux-amd64 \
    && chmod +x /usr/local/bin/tk \
    && tk --version

# helm
RUN curl -Lo helm-linux-amd64.tar.gz https://get.helm.sh/helm-v3.5.2-linux-amd64.tar.gz \
    && tar zxvf helm-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-linux-amd64.tar.gz \
    && helm version

# kustomize
RUN curl -Lo kustomize-linux-amd64.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.2/kustomize_v4.5.2_linux_amd64.tar.gz\
   && tar zxvf kustomize-linux-amd64.tar.gz \
   && mv kustomize /usr/local/bin/kustomize \
   && chmod +x /usr/local/bin/kustomize \
   && rm -rf kustomize-linux-amd64.tar.gz \
   && kustomize version

# aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && aws --version

COPY entrypoints /entrypoints

ENTRYPOINT ["/usr/local/bin/tk"]
