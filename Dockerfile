FROM python:3-alpine as build
RUN apk --update add ca-certificates redis curl  bash gcc make liblzf-dev python3-dev \
    libffi-dev build-base openssl-dev git cargo restic openssl
RUN pip install rdbtools python-lzf
RUN apk del gcc make liblzf-dev python3-dev libffi-dev build-base openssl-dev cargo
RUN rm -rf /root/.cargo

FROM python:3-alpine
RUN wget https://dl.minio.io/client/mc/release/linux-amd64/mc && chmod +x mc && mv mc /usr/local/bin
COPY --from=ghcr.io/yannh/redis-dump-go:v0.8.1-alpine /redis-dump-go /usr/local/bin/

COPY redis-utils.py /usr/local/bin
COPY redis-dump.sh /usr/local/bin

COPY --from=build / /

# ENTRYPOINT ["/redis-dump-go"]

# Copy source code as late as possible to take advantages about layer cache
# Squash layers


# COPY --from=build / /   # doesn't work on kaniko
# Waiting for: https://github.com/GoogleContainerTools/kaniko/pull/1724
# ENV workdir=/app
