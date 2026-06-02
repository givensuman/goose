FROM scratch AS ctx
COPY /build_files /build_files

ARG BASE_IMAGE_TAG=43
FROM ghcr.io/ublue-os/base-main:${BASE_IMAGE_TAG} AS goose
COPY /system_files /

# Build, cleanup, lint.
RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    for script in /ctx/build_files/*.sh; do \
      bash "$script"; \
    done
