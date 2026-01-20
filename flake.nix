{
  description = "NixOS configuration with Noctalia";
  inputs = {
    chaotic.url = "github:chaotic-cx/nyx";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
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
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.2?submodules=true";
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

    nixpkgs-patched = (import inputs.nixpkgs { inherit system; }).applyPatches {
      name = "nixpkgs-patched";
      src = inputs.nixpkgs;
      patches = [
        #(builtins.fetchurl {
        #  url = "https://asdf1234.patch";
        #  sha256 = "sha256:qwerty123456...";
        #})
      ];
    };

    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
      overlays = [
        inputs.rust-overlay.overlays.default
        inputs.chaotic.overlays.default
      ];
    };


    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
    };

    generatedModules = lib.map (file: "${configDir}/${file}") 
      (lib.filter (file: lib.hasSuffix ".nix" file) 
        (lib.attrNames (builtins.readDir configDir)));
  in
  rec {
    nixosConfigurations = let 
      specialArgs = {inherit inputs pkgs-stable system hostname stateVersion proxyDefault;};
    in{
      ${hostname} = lib.nixosSystem {
        inherit system;
        inherit pkgs;
        inherit specialArgs;
        modules = [
          ./configuration.nix
        ] ++ generatedModules; 
      };
    };

    homeConfigurations = let 
      # pkgs = nixpkgs.legacyPackages.${system};
      #unfreePkgs = import inputs.nixpkgs { inherit system; config = { allowUnfree = true; }; };
      homeConfigDir = ./home/modules;
      extraSpecialArgs = {inherit inputs pkgs pkgs-stable system username stateVersion proxyDefault;};
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
