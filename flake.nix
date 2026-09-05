{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Remote flakes
    hardware.url = "github:NixOS/nixos-hardware/master";
    flatpaks.url = "github:gmodena/nix-flatpak";
    stylix.url = "github:nix-community/stylix";
    catppuccin.url = "github:catppuccin/nix";
    wsl.url = "github:nix-community/NixOS-WSL";
    fish-plugins.url = "github:givensuman/nix-fish-plugins";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Dynamic username for when I legally
      # change my name to Megatron.
      username = "given";

      mkHost = # fn
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                inputs.catppuccin.homeModules.catppuccin
              ];
              home-manager.extraSpecialArgs = { inherit inputs username hostname; };
            }
          ];
        };
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#hostname'
      nixosConfigurations = {
        laptop = mkHost "laptop";
        wsl = mkHost "wsl";
      };
    };
}
