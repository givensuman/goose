{
  description = "given's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flatpaks.url = "github:gmodena/nix-flatpak";
    stylix.url = "github:nix-community/stylix";
    # spicetify.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flatpaks,
    ...
  } @ inputs: {
    nixosConfigurations.gandalf = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [./nixos/configuration.nix];
    };
  };
}
