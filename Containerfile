ARG BASE_IMAGE="ghcr.io/ublue-os/base-main"
ARG BASE_TAG="latest"

FROM scratch AS ctx
COPY build_files /

# goosex is a Universal Blue image with Nix layering
FROM ${BASE_IMAGE}:${BASE_TAG} AS goosex

COPY system_files/goosex /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    for script in /ctx/goosex/*.sh /ctx/cleanup.sh; do \
        echo "Running ${script}"; \
        /bin/bash "${script}" || exit 1; \
    done

RUN bootc container lint

# goose is goosex with desktop personalization
FROM goosex AS goose

COPY system_files/goose /

# base-main symlinks /opt to /var/opt; Chromium applications need an immutable /opt.
RUN rm -f /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    for script in /ctx/goose/*.sh /ctx/cleanup.sh; do \
        echo "Running ${script}"; \
        /bin/bash "${script}" || exit 1; \
    done

RUN bootc container lint
