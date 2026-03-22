# Chezmoi Scripts Documentation

## Overview

This directory contains automated scripts that run during `chezmoi apply` to set up and maintain your development environment. All scripts follow consistent patterns for logging, error handling, and tool detection.

## Script Execution Order

### Phase 1: One-Time Initialization (run_once_*)
Scripts in this phase execute only once when the file or its content changes.

1. **run_once_after_00-build-bat-cache.sh** - Builds bat syntax cache
2. **run_once_after_00-install-mise-tools.sh** - Installs mise-managed tools
3. **run_once_after_01-install-fish-plugins.sh** - Rebuilds Fish completions
4. **run_once_after_02-setup-git-hooks.sh** - Configures git hooks directory
5. **run_once_after_03-validate-environment.sh** - Validates environment setup

### Phase 2: Conditional Updates (run_onchange_*)
Scripts in this phase execute when their trigger file changes (e.g., .mise.toml).

6. **run_onchange_after_upgrade-mise.sh** - Upgrades tools when .mise.toml changes

### Phase 3: Maintenance (run_always_*)
Scripts in this phase execute every time `chezmoi apply` runs.

7. **run_always_after_00-verify-mise-tools.sh** - Verifies mise tools are accessible
8. **run_always_after_01-sync-neovim.sh** - Syncs Neovim plugins
9. **run_always_after_02-verify-shell-config.sh** - Validates shell config integrity
10. **run_always_after_03-cleanup-stale-links.sh** - Removes broken symlinks

## What Each Script Does

### Install Mise Tools (`run_once_after_00-install-mise-tools.sh`)

Installs tools defined in your mise configuration. 

**Features:**
- Checks if mise is installed before proceeding
- Verifies mise config exists (.mise.toml or .tool-versions)
- Logs all operations for debugging
- Fails with exit code 1 if installation fails (halts Chezmoi apply)

**When it runs:** Once, on first apply or when script content changes

### Install Fish Plugins (`run_once_after_01-install-fish-plugins.sh`)

Rebuilds Fish shell completions database after Chezmoi applies changes.

**Features:**
- Checks if Fish is installed
- Updates the completions database to make new functions available
- Gracefully skips if fish_update_completions is unavailable

**When it runs:** Once, on first apply or when script content changes

### Setup Git Hooks (`run_once_after_02-setup-git-hooks.sh`)

Creates a standard directory for repository-specific git hooks and configures global git settings.

**Features:**
- Creates ~/.config/git/hooks directory
- Configures global git core.hooksPath for custom hooks
- Allows you to store shared hooks in version control

**When it runs:** Once, on first apply or when script content changes

### Validate Environment (`run_once_after_03-validate-environment.sh`)

Checks that critical tools and directories are properly configured.

**Features:**
- Verifies critical tools: bash, git, curl
- Checks optional tools: fish, mise, nvim, bat, lazygit, yazi
- Validates ~/.config and ~/.local directories exist
- Reports findings but doesn't fail (warnings only)

**When it runs:** Once, on first apply or when script content changes

### Verify Mise Tools (`run_always_after_00-verify-mise-tools.sh`)

After every apply, confirms that mise-installed tools are in PATH and accessible.

**Features:**
- Gets list of installed tools from mise
- Checks each tool is available in PATH
- Logs findings for debugging

**When it runs:** Every `chezmoi apply` execution

### Sync Neovim (`run_always_after_01-sync-neovim.sh`)

Runs lazy.nvim plugin manager to ensure all plugins are installed/updated.

**Features:**
- Checks if Neovim is installed
- Verifies config directory exists
- Runs lazy.nvim sync in headless mode with 60-second timeout
- Non-fatal if sync has issues (allows apply to continue)

**When it runs:** Every `chezmoi apply` execution

### Verify Shell Config (`run_always_after_02-verify-shell-config.sh`)

Validates Fish and Bash configuration files are in place and creates missing directories.

**Features:**
- Checks Fish config directory and main config file
- Creates Fish functions directory if missing
- Validates directory structure

**When it runs:** Every `chezmoi apply` execution

### Cleanup Stale Links (`run_always_after_03-cleanup-stale-links.sh`)

Removes broken symlinks from ~/.config and ~/.local/share that may accumulate over time.

**Features:**
- Finds broken symlinks (dangling links)
- Removes them safely
- Reports count of stale links removed

**When it runs:** Every `chezmoi apply` execution

## Logging

All scripts output to stderr (file descriptor 2) with consistent prefixes for easy filtering:

```
[chezmoi/script-name] INFO: Informational messages
[chezmoi/script-name] WARN: Warnings (non-fatal issues)
[chezmoi/script-name] ERROR: Errors that cause script failure
```

Example log output:
```
[chezmoi/install-mise-tools] INFO: Installing tools from mise configuration...
[chezmoi/install-mise-tools] INFO: Tools installed successfully
```

## Error Handling

All scripts follow these safety practices:

- `set -euox pipefail` - Exit on error, undefined variables, pipe failures
- Missing tools are detected and skipped gracefully
- Non-critical failures are logged as warnings and don't stop execution
- Critical failures (marked with `exit 1`) will halt Chezmoi apply and show which script failed

## Design Patterns

All scripts follow consistent patterns:

```bash
#!/bin/bash
set -euox pipefail

readonly SCRIPT_NAME="script-name"
readonly LOG_PREFIX="[chezmoi/${SCRIPT_NAME}]"

log_info() {
  echo "${LOG_PREFIX} INFO: $*" >&2
}

log_warn() {
  echo "${LOG_PREFIX} WARN: $*" >&2
}

# Tool existence check
if ! command -v tool_name &> /dev/null; then
  log_info "tool_name not found, skipping"
  exit 0
fi

# Main logic...
```

## Customization

### Adding a New Script

To add a new Chezmoi script:

1. Create a file with the appropriate hook type prefix:
   - `run_once_*.sh.tmpl` - Run once when file changes
   - `run_onchange_*.sh.tmpl` - Run when specified file changes
   - `run_always_*.sh.tmpl` - Run every apply

2. Use numeric suffixes (00, 01, 02, etc.) to control execution order within each phase

3. Follow the logging and error handling patterns shown above

4. Add documentation to this README

5. Commit with a clear message: `feat: add <description> script`

### Modifying Existing Scripts

Edit the `.sh.tmpl` files directly. Changes take effect on next `chezmoi apply`.

## Testing Scripts Manually

Run a specific script manually for debugging:
```bash
bash /var/home/given/Dev/goose/home/run_once_after_01-install-fish-plugins.sh.tmpl
```

Check script syntax without executing:
```bash
bash -n /var/home/given/Dev/goose/home/run_once_after_01-install-fish-plugins.sh.tmpl
```

## Running Chezmoi

Apply all changes and run scripts:
```bash
chezmoi apply
```

Preview changes before applying:
```bash
chezmoi apply --dry-run
```

Show what Chezmoi will do:
```bash
chezmoi diff
```

## Troubleshooting

### A script is failing
1. Run `chezmoi apply -v` for verbose output
2. Run the individual script manually to see full error output
3. Check the script exists at the path shown in the error
4. Verify syntax: `bash -n /path/to/script.sh.tmpl`

### Scripts aren't running at all
1. Verify files are in the `home/` directory of your chezmoi source
2. Verify filenames follow Chezmoi naming conventions
3. Check file permissions: `ls -la home/run_*.sh.tmpl`
4. Run `chezmoi init --verbose` to debug template processing

### Git hooks directory not working
1. Verify ~/.config/git/hooks was created: `ls -la ~/.config/git/hooks`
2. Verify git config was set: `git config --global core.hooksPath`
3. Check if git version supports hooksPath (added in Git 2.9)

## More Information

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi Scripts](https://www.chezmoi.io/reference/special-files-and-directories/scripts/)
- [Mise Package Manager](https://mise.jdx.dev/)
- [Fish Shell](https://fishshell.com/)
