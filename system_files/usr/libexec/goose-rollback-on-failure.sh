#!/usr/bin/env bash
set -euo pipefail

BOOT_OK="/var/lib/goose-boot-ok"
BOOT_FAILED="/var/lib/goose-boot-failed"

log() {
  printf 'goose-rollback-on-failure: %s\n' "$*" >&2
}

has_previous_deployment() {
  if ! command -v bootc >/dev/null 2>&1; then
    log "bootc not available; skipping rollback"
    return 1
  fi

  local status
  if ! status="$(bootc status --json 2>/dev/null)"; then
    log "failed to query bootc status; skipping rollback"
    return 1
  fi

  python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    rollback = data.get('status', {}).get('rollback')
    sys.exit(0 if rollback else 1)
except Exception:
    sys.exit(1)
" <<<"$status"
}

rollback_and_reboot() {
  if ! has_previous_deployment; then
    log "no previous deployment available; continuing boot"
    return 0
  fi

  log "rolling back to previous deployment"
  if ! bootc rollback; then
    log "bootc rollback failed; continuing boot"
    return 0
  fi

  touch "$BOOT_OK"
  log "rebooting into previous deployment"
  systemctl reboot
}

main() {
  if [[ -f "$BOOT_FAILED" ]]; then
    log "failure marker present"
    rm -f "$BOOT_FAILED"
    rollback_and_reboot
    return 0
  fi

  if [[ ! -f "$BOOT_OK" ]]; then
    log "boot OK marker missing"
    rollback_and_reboot
    return 0
  fi

  rm -f "$BOOT_OK"
  log "boot OK marker cleared; continuing boot"
}

main "$@"
