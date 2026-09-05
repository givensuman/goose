complete -c flake -f

# Subcommands
complete -c flake -n __fish_use_subcommand -a init -d "Initializes a workspace in the current directory"
complete -c flake -n __fish_use_subcommand -a update -d "Updates the Nix lockfile and reloads the workspace"
complete -c flake -n __fish_use_subcommand -a status -d "Status information for the current workspace"
complete -c flake -n __fish_use_subcommand -a clean -d "Cleans `direnv` cache and runs `nix-collect-garbage`"
complete -c flake -n __fish_use_subcommand -a list -d "List packages used in the current workspace"
