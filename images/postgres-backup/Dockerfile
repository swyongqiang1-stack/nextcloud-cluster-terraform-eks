FROM postgres:17

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       gzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://awscli.amazonaws.com/v2/install.sh \
    | bash -s -- --system

RUN pg_dump --version \
    && aws --version \
    && gzip --version