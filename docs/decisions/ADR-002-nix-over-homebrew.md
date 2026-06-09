# ADR 002: Nix over Homebrew

## Status
Accepted

## Context
The previous iteration used Homebrew for user-space package management. For the reference architecture, we needed a package manager that:
- Works well with immutable OS patterns (no /usr/local mutations)
- Demonstrates advanced package management concepts
- Provides reproducible, declarative package specifications

## Decision
Use Nix (via the Determinate Systems `nix-installer`) instead of Homebrew.

## Rationale
- **Declarative**: Nix files are pure expressions enabling fully reproducible environments
- **Atomic**: Nix operations create new store paths and atomically switch — no partial states
- **Immutable-friendly**: /nix/store is read-only at runtime, complementing ostree's design
- **No root required**: User-space Nix installs work without global mutations
- **Signal strength**: Nix knowledge is highly valued in the DevOps/platform engineering space

## Consequences
### Positive
- Stronger demonstration of package management depth
- Better alignment with immutable OS philosophy
- Larger ecosystem of reusable package expressions (nixpkgs)

### Negative
- Larger image size (~200MB for Nix store + dependencies)
- Longer build time (Nix installation + initial evaluation)
- Steeper learning curve for users unfamiliar with Nix
