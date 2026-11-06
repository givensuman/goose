FROM ghcr.io/ublue-os/base-main:latest

COPY build_files /build_files
COPY system_files /

# base-main symlinks /opt to /var/opt; Chromium applications need an immutable /opt.
RUN rm /opt && mkdir /opt

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /bin/bash -c 'for script in /build_files/*; do \
        if [[ -f "$script" ]]; then \
            /bin/bash "$script" || exit 1; \
        fi; \
    done'

RUN bootc container lint
