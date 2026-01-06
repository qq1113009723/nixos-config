{
  config, pkgs, lib,...
}:{
  options = {
    systemSettings.vmware = {
      guest = {
        enable = lib.mkEnableOption "Enable VMware guest additions";
      };
    };
  };

  config = lib.mkIf config.systemSettings.vmware.guest.enable {
    virtualisation.vmware.guest.enable = true;
    environment.systemPackages = with pkgs; [
      open-vm-tools
    ];
  };
}