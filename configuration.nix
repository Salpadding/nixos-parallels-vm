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
  ] ++ lib.optionals isHyprland [
    ./hyprland.nix
  ] ++ lib.optionals isPlasmaWayland [
    ./plasma-wayland.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Mount /dev/sdb1 to /mnt/data
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/860da4dd-00ad-4dab-bfca-4d6b07d81ce4";
    fsType = "ext4";
  };

  # Hostname
  networking.hostName = "nixos-vm";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqWGcDJIN/HoT8pa3KeqSJ4gN88MulphjOi68ZTXCFh C5390852@H7DWCK9Y5C"
    ];
  };

  # Home Manager configuration for admin
  home-manager.users.admin = { pkgs, ... }: {
    home.stateVersion = "25.11";

    # Link nvim config from dotfiles/nvim
    xdg.configFile."nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };

    # Link tmux config from dotfiles/tmux
    xdg.configFile."tmux" = {
      source = ./dotfiles/tmux;
      recursive = true;
    };

    # Link vimrc from dotfiles/vim
    home.file.".vimrc".source = ./dotfiles/vim/vimrc;

    programs.bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        gs = "git status";
      };
    };

    programs.git = {
      enable = true;
      settings.user = {
        name = "admin";
        email = "admin@nixos-vm";
      };
    };

    home.enableNixpkgsReleaseCheck = false;
  };

  # Essential packages (common to all desktop environments)
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
    tmux
    ripgrep
    fd
    jq
    neovim
    bash
    ruby
    nodejs
    gnumake
    claude-code
    lazygit
    telegram-desktop
    # Terminal compatibility (terminfo for modern terminals)
    kitty.terminfo
    ghostty.terminfo
  ] ++ lib.optionals isHyprland [
    # Hyprland / Wayland essentials
    kitty              # Terminal emulator
    waybar             # Status bar
    wofi               # Application launcher
    mako               # Notification daemon
    wl-clipboard       # Clipboard utilities (wl-copy, wl-paste)
    grim               # Screenshot utility
    slurp              # Region selection for screenshots
    swww               # Wallpaper daemon
    brightnessctl      # Brightness control
    networkmanagerapplet  # Network manager tray applet
  ];

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

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Create /opt and /opt/npm directories with 777 permissions
  systemd.tmpfiles.rules = [
    "d /opt 0777 root root -"
    "d /opt/npm 0777 root root -"
  ];

  # Configure npm global directory
  environment.variables = {
    NPM_CONFIG_PREFIX = "/opt/npm";
  };

  # Add /opt/npm/bin to PATH
  environment.shellInit = ''
    export PATH="/opt/npm/bin:$PATH"
  '';

  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (needed for Parallels tools)
  nixpkgs.config.allowUnfree = true;

  # Parallels Tools configuration
  hardware.parallels.enable = true;

  # Hyprland (Wayland compositor) - only when gui = hyprland
  programs.hyprland = lib.mkIf isHyprland {
    enable = true;
    xwayland.enable = true;
  };

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

  # XDG portal for Hyprland (screen sharing, file dialogs, etc.) - only when gui = hyprland
  xdg.portal = lib.mkIf isHyprland {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable OpenGL
  hardware.graphics.enable = true;

  system.stateVersion = "25.11";
}
