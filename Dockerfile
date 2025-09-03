# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=12

# STAGE 1 - build
FROM debian:${DEBIAN_VERSION}-slim AS build

# BUILD FROM SOURCE:
ARG APP_NAME=oxipng
ARG APP_VERSION=v9.1.5

ARG GIT_REPOSITORY=https://github.com/oxipng/oxipng.git

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \    
    --mount=type=cache,target=/tmp/build \
    apt-get update \    
    && echo "Installing dependencies ..." \    
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    build-essential \
    pkg-config \
    gcc \
    make \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup update stable \
    && rustc --version \
    && cargo --version \
    && echo "Building ${APP_NAME} ..." \
    && git clone ${GIT_REPOSITORY} /tmp/build \
    && cd /tmp/build \
    && git checkout ${APP_VERSION} \
    && cargo build --release \
    && cp target/release/oxipng /usr/local/bin \    
    && echo "Building ${APP_NAME} ... OK" 

# STAGE 2 - RELEASE
FROM debian:${DEBIAN_VERSION}-slim AS release
COPY --from=build /usr/local/bin /usr/local/bin

# define app userspace
WORKDIR /app
CMD [ "${APP_NAME}" ]
