# syntax=docker/dockerfile:1

# Build from source via Nix flake (no vendored binaries in git).
FROM nixos/nix:2.28.2 AS builder
WORKDIR /src
COPY . .
RUN nix --extra-experimental-features "nix-command flakes" build .#conceptbase \
    && cp -a result /install

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      libgmp10 \
      libreadline8 \
      libncursesw6 \
      libtinfo6 \
      libstdc++6 \
      libgcc-s1 \
      zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /opt/conceptbase
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /opt/conceptbase/cbserver /opt/conceptbase/bin/CBserver \
    /usr/local/bin/docker-entrypoint.sh

ENV CB_HOME=/opt/conceptbase
ENV PATH=/opt/conceptbase:/opt/conceptbase/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/conceptbase/linux64/lib

VOLUME ["/var/lib/conceptbase/data"]
EXPOSE 4001
WORKDIR /var/lib/conceptbase/data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
