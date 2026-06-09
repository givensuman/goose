# ADR 003: fedora-bootc as Base Image

## Status
Accepted

## Context
The previous iteration used `ghcr.io/ublue-os/base-main` as its base image. For the reference architecture, we needed a base that:
- Is officially maintained by the distribution vendor
- Has no downstream dependency
- Supports bootc natively
- Provides a minimal starting point for customization

## Decision
Use `quay.io/fedora/fedora-bootc:stable` as the base image.

## Rationale
- **Official Fedora**: Maintained by the Fedora project, not a third party
- **bootc-native**: The image is purpose-built as a bootable container base
- **Minimal**: Contains only the bare essentials — no desktop, no bloat
- **Stable tracking**: `:stable` tag follows Fedora stable releases
- **No vendor lock-in**: Users can fork without permission from a downstream project

## Consequences
### Positive
- Full control over every layer in the image
- No dependency on downstream distribution decisions
- Demonstrates understanding of bootc at the upstream level
- Smaller base image means smaller final image

### Negative
- Must reimplement functionality that ublue provided (kernel management, update services, media automount)
- No ublue community integrations or patches
- Must track Fedora bootc changes directly
