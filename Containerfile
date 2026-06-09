FROM scratch AS ctx
COPY /build_files /build_files
COPY /system_files /system_files

FROM quay.io/fedora/fedora-bootc:stable AS goose

COPY --from=ctx /build_files /build_files
COPY --from=ctx /system_files /

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    for script in /ctx/build_files/*.sh; do \
      bash "$script"; \
    done
