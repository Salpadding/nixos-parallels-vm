{ config, lib, pkgs, ... }:

let
  settings = builtins.fromJSON (builtins.readFile ./nixos-settings.json);
  gui = settings.gui or "hyprland";
  isHyprland = gui == "hyprland";
  isPlasmaWayland = gui == "plasma-wayland";
in
{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./home-admin.nix
    ./packages.nix
    ./services.nix
    ./development.nix
  ] ++ lib.optionals isHyprland [
    ./hyprland.nix
  ] ++ lib.optionals isPlasmaWayland [
    ./plasma-wayland.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Mount /dev/sdb1 to /mnt/data (optional - won't block boot if unavailable)
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/860da4dd-00ad-4dab-bfca-4d6b07d81ce4";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=5s" ];
  };

  # Hostname
  networking.hostName = "nixos-vm";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Asia/Shanghai";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";  # 24-hour format
  };

  # Parallels Tools configuration
  hardware.parallels.enable = true;

  # Hyprland (Wayland compositor) - only when gui = hyprland
  programs.hyprland = lib.mkIf isHyprland {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal for Hyprland (screen sharing, file dialogs, etc.) - only when gui = hyprland
  xdg.portal = lib.mkIf isHyprland {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable OpenGL
  hardware.graphics.enable = true;

  system.stateVersion = "25.11";
}
