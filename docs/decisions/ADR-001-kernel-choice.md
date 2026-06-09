# ADR 001: CachyOS Kernel

## Status
Accepted

## Context
The default Fedora kernel is optimized for broad hardware compatibility and stability. For a reference architecture demonstrating systems engineering capability, we wanted a kernel that shows:
- Understanding of kernel configuration and tuning
- Ability to swap kernels in an immutable OS context
- Performance optimization awareness

## Decision
Use the CachyOS kernel (`kernel-cachyos`) instead of the stock Fedora kernel.

## Rationale
- AutoFDO/PGO optimizations for common CPU microarchitectures
- BORE CPU scheduler for better desktop interactivity
- Multi-generational LRU for improved memory management
- Active community and regular updates aligned with mainline
- Available as a drop-in RPM replacement for stock Fedora kernel

## Consequences
### Positive
- Performance improvements, particularly for developer workloads
- Demonstrates advanced kernel management skills
- No functional difference in boot/update process

### Negative
- Adds external repository dependency
- Kernel updates lag mainline by days (CachyOS packaging time)
- Potential compatibility issues with very new hardware
