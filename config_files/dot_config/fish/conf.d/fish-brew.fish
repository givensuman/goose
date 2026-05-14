# Common Homebrew installation locations
set -l brew_locations \
    /opt/homebrew/bin \
    /usr/local/bin \
    /usr/bin \
    /bin \
    /opt/homebrew/sbin \
    /usr/local/sbin \
    /usr/sbin \
    /sbin \
    "/home/linuxbrew/.linuxbrew/bin" \
    "/home/linuxbrew/.linuxbrew" \
    "~/.linuxbrew/bin" \
    "~/.linuxbrew/sbin"

# Add brew to PATH if not already present
if set -q brew_location
    fish_add_path $brew_location
else
    for brew_location in $brew_locations
        if contains $brew_location $PATH
            continue
        end

        if test -f $brew_location/brew
            fish_add_path $brew_location
            break
        end
    end
end

if not command -q brew
    echo "brew is not installed but you're"
    echo "sourcing the fish plugin for it"
    return 1
end

# Aliases
alias bleaves _fish_brew_bleaves # Display brew leaves with dependencies and casks
alias bl bleaves # Run custom `bleaves` function.
alias bi 'brew install' # Install a formula.
alias ba 'brew autoremove' # Uninstall unnecessary formulae.
alias bcfg 'brew config' # Show Homebrew and system configuration info useful for debugging.
alias bci 'brew info --cask' # Display information about the given cask.
alias bcin 'brew install --cask' # Install the given cask.
alias bcl 'brew list --cask' # List installed casks.
alias bcn 'brew cleanup' # Run cleanup.
alias bco 'brew outdated --cask' # Report all outdated casks.
alias bcr 'brew reinstall --cask' # Reinstall the given cask.
alias bcubc 'brew upgrade --cask && brew cleanup' # Upgrade outdated casks, then run cleanup.
alias bcubo 'brew update && brew outdated --cask' # Update Homebrew data, then list outdated casks.
alias bcup 'brew upgrade --cask' # Upgrade all outdated casks.
alias bdr 'brew doctor' # Check your system for potential problems.
alias bfu 'brew upgrade --formula' # Upgrade only formulae (not casks).
alias bi 'brew install' # Install a formula.
alias bl 'brew list' # List all installed formulae.
alias bo 'brew outdated' # List installed formulae that have an updated version available.
alias brewp 'brew pin' # Pin a specified formula so that it's not upgraded.
alias brews 'brew list -1' # List installed formulae or the installed files for a given formula.
alias brewsp 'brew list --pinned' # List pinned formulae, or show the version of a given formula.
alias bs 'brew search' # Perform a substring search of cask tokens and formula names for text.
alias bsl 'brew services list' # List all running services.
alias bso 'brew services stop' # Stop the service and unregister it from launching at login (or boot).
alias bsoffa 'brew services stop --all' # Stop all started services.
alias bson 'brew services start' # Start the service and register it to launch at login (or boot).
alias bsona 'bson --all' # Start all stopped services.
alias bsr 'brew services run' # Run the service without registering to launch at login (or boot).
alias bsra 'bsr --all' # Run all stopped services.
alias bu 'brew update' # Update brew and all installed formulae.
alias bubo 'brew update && brew outdated' # Update Homebrew data, then list outdated formulae and casks.
alias bubu 'bubo && bup' # Do the last two operations above.
alias bugbc 'brew upgrade --greedy && brew cleanup' # Upgrade outdated formulae and casks (greedy), then run cleanup.
alias bup 'brew upgrade' # Upgrade outdated, unpinned brews.
alias buz 'brew uninstall --zap' # Remove all files associated with a cask.

# Initialize Homebrew shell environment
eval (brew shellenv)

function _fish_brew_install --on-event fish-brew_install
    set -l brew_location (command -v brew | string replace -r '/bin/brew$' '')

    if not contains $brew_location $PATH
        fish_add_path $brew_location
    end
end

function _fish_brew_uninstall --on-event fish-brew_uninstall
    functions --erase _fish_brew_bleaves
    functions --erase bleaves
    functions --erase \
        bl \
        bi \
        br \
        bar \
        ba \
        bcfg \
        bci \
        bcin \
        bcl \
        bcn \
        bco \
        bcrin \
        bcubc \
        bcubo \
        bcup \
        bdr \
        bfu \
        bo \
        brewp \
        brews \
        brewsp \
        bs \
        bsl \
        bsoff \
        bsoffa \
        bson \
        bsona \
        bsr \
        bsra \
        bu \
        bubo \
        bubu \
        bugbc \
        bup \
        buz
    set --erase brew_location
    set --erase brew_locations
end

function _fish_brew_update --on-event fish-brew_update
    _fish_brew_uninstall
    _fish_brew_install
end
