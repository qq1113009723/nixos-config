{
  description = "NixOS configuration with Noctalia";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs,home-manager, ... }: 
  let
    lib = nixpkgs.lib;
    configDir = ./modules;
    hostname = "nixos";
    username = "naraiu";
    system = "x86_64-linux";
    generatedModules = lib.map (file: "${configDir}/${file}") 
      (lib.filter (file: lib.hasSuffix ".nix" file) 
        (lib.attrNames (builtins.readDir configDir)));
  in
  rec {
    nixosConfigurations = let 
      specialArgs = {inherit inputs system hostname;};
    in{
      ${hostname} = lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules = [
          ./configuration.nix
        ] ++ generatedModules; 
      };
    };

    homeConfigurations = let 
      
      pkgs = nixpkgs.legacyPackages.${system};
      unfreePkgs = import inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; };

      homeConfigDir = ./home/modules;
      extraSpecialArgs = {inherit inputs unfreePkgs system username;};

      generatedHomeModules = lib.map (file: "${homeConfigDir}/${file}") 
        (lib.filter (file: lib.hasSuffix ".nix" file) 
          (lib.attrNames (builtins.readDir homeConfigDir)));


    in {
        ${username} = home-manager.lib.homeManagerConfiguration{
          inherit pkgs;
          inherit extraSpecialArgs;
          modules = [
            ./home/default.nix
          ] ++ generatedHomeModules;
        };
    };

  };
}
