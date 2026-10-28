FROM scratch AS ctx

COPY build_files /build_files
COPY system_files /system_files

FROM ghcr.io/ublue-os/base-main:latest

# base-main symlinks /opt to /var/opt; Chromium applications need an immutable /opt.
RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh

RUN bootc container lint
