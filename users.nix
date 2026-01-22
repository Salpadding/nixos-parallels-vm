{ config, lib, pkgs, ... }:

{
  # User account - admin
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqWGcDJIN/HoT8pa3KeqSJ4gN88MulphjOi68ZTXCFh C5390852@H7DWCK9Y5C"
    ];
  };

  # User account - claude
  users.users.claude = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "video" ];
    initialPassword = "claude";
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;
}
