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
    dms = {
      url = "github:AvengeMedia/DankMaterialShell"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:Aylur/ags";  
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
 
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: 
  let
    lib = nixpkgs.lib;
    configDir = ./modules;
    hostname = "nixos";
    username = "naraiu";
    system = "x86_64-linux";
    stateVersion = "25.11";
    proxyDefault = "http://192.168.106.171:7890";
    generatedModules = lib.map (file: "${configDir}/${file}") 
      (lib.filter (file: lib.hasSuffix ".nix" file) 
        (lib.attrNames (builtins.readDir configDir)));
  in
  rec {
    nixosConfigurations = let 
      specialArgs = {inherit inputs system hostname stateVersion proxyDefault;};
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
      extraSpecialArgs = {inherit inputs unfreePkgs system username stateVersion proxyDefault;};
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
