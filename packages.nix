{ config, lib, pkgs, ... }:

let
  settings = builtins.fromJSON (builtins.readFile ./nixos-settings.json);
  gui = settings.gui or "hyprland";
  isHyprland = gui == "hyprland";

  # JRuby 9.4.12.0 (supports JDK 17)
  pkgs-jruby94 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
    sha256 = "0m0xmk8sjb5gv2pq7s8w7qxf7qggqsd3rxzv3xrqkhfimy2x7bnx";
  }) { inherit (pkgs) system; };
  jruby94 = pkgs-jruby94.jruby.override { jre = pkgs.jdk17; };
in
{
  # Essential packages (common to all desktop environments)
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    htop
    curl
    wget
    tmux
    ripgrep
    fd
    jq
    file
    zip
    unzip

    # Editors
    neovim
    vscode

    # Shell
    bash

    # Network tools
    dnsutils  # provides nslookup and dig
    openssl   # provides openssl CLI

    # Programming languages
    ruby
    jruby94   # JRuby 9.4.12.0 with JDK 17
    nodejs
    pnpm
    python3

    # Build tools
    gnumake

    # Git tools
    lazygit

    # Java development
    jdk17
    jdk21
    jdt-language-server
    mvnd

    # Productivity
    obsidian  # Markdown note-taking

    # Chat applications
    telegram-desktop
    (pkgs.buildFHSEnv {
      name = "wechat";
      targetPkgs = pkgs: [ pkgs.wechat-uos ];
      runScript = "wechat-uos --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
      meta.mainProgram = "wechat";
      extraInstallCommands = ''
        mkdir -p $out/share/applications $out/share/icons
        cp -r ${pkgs.wechat-uos}/share/icons/* $out/share/icons/
        cat > $out/share/applications/wechat.desktop << EOF
        [Desktop Entry]
        StartupWMClass=wechat
        Name=微信
        GenericName=WeChat
        Exec=wechat %U
        StartupNotify=true
        Terminal=false
        Icon=com.tencent.wechat
        Type=Application
        Categories=Chat;
        Comment=微信桌面版
        EOF
      '';
    })
    (qq.override {
      commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
    })

    # Terminal compatibility (terminfo for modern terminals)
    kitty.terminfo
    ghostty.terminfo

    # Wayland clipboard utilities (wl-copy, wl-paste)
    wl-clipboard
  ] ++ lib.optionals isHyprland [
    # Hyprland / Wayland essentials
    kitty              # Terminal emulator
    waybar             # Status bar
    wofi               # Application launcher
    mako               # Notification daemon
    grim               # Screenshot utility
    slurp              # Region selection for screenshots
    swww               # Wallpaper daemon
    brightnessctl      # Brightness control
    networkmanagerapplet  # Network manager tray applet
  ];

  # Firefox as default browser
  programs.firefox.enable = true;

  # Set Firefox as default browser
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
