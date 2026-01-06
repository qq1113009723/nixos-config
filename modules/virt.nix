{
  config, pkgs, lib,...
}:{
  options = {
    systemSettings.virtualisation = {
      enable = lib.mkEnableOption "Enable virtualisation service";
    };
  };
  
  config = lib.mkIf config.systemSettings.virtualisation.enable {

    environment.systemPackages = with pkgs; [
      libvirt
      virt-manager
      qemu
      uefi-run
      virt-viewer
      swtpm
      bottles

    ];

    virtualisation.libvirtd = {
      enable = true;
    # 启用 virtiofsd 支持，这会自动处理 qemu 依赖
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
}