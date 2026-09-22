FROM postgres:17-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates unzip gzip jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
      https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.36.41.zip \
      -o /tmp/awscli.zip \
    && unzip -q /tmp/awscli.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscli.zip

RUN cd /tmp \
    && curl -fsSLO https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl \
    && curl -fsSLO https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl.sha256 \
    && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
    && install -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl kubectl.sha256

RUN pg_dump --version \
    && aws --version \
    && kubectl version --client \
    && jq --version