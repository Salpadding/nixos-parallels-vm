{ config, lib, pkgs, ... }:

let
  settings = builtins.fromJSON (builtins.readFile ./nixos-settings.json);
  gui = settings.gui or "hyprland";
  isHyprland = gui == "hyprland";
in
{
  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Firewall - allow SSH
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Display manager for Wayland (greetd with tuigreet) - only when gui = hyprland
  services.greetd = lib.mkIf isHyprland {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
}
