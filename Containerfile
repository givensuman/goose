ARG BASE_IMAGE="ghcr.io/ublue-os/base-main"
ARG BASE_TAG="latest"

# Build context is mounted rather than copied so it never lands in the final image.
FROM scratch AS ctx
COPY build_files /

FROM ${BASE_IMAGE}:${BASE_TAG}

COPY system_files /

# base-main symlinks /opt to /var/opt; Chromium applications need an immutable /opt.
RUN rm -f /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    for script in /ctx/*.sh; do \
        echo "Running ${script}"; \
        /bin/bash "${script}" || exit 1; \
    done

RUN bootc container lint
