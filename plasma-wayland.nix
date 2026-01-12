{ config, pkgs, ... }:

{
  # Enable X11 with SDDM display manager
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # Enable SDDM display manager (X11 only)
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = false;
    };
    defaultSession = "plasmax11";
  };

  # Enable KDE Plasma Desktop
  services.desktopManager.plasma6.enable = true;

  # Fcitx5 + Rime input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-configtool
      ];
      waylandFrontend = false;  # Using X11
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      # Monospace fonts (Menlo alternatives)
      meslo-lgs-nf          # Meslo Nerd Font (Menlo derivative)
      jetbrains-mono        # Modern programming font
      fira-code             # Popular with ligatures
      source-code-pro       # Adobe's monospace

      # UI fonts
      inter                 # Modern UI font
      roboto                # Google's UI font
      noto-fonts            # Comprehensive coverage
      noto-fonts-cjk-sans   # CJK support
      noto-fonts-color-emoji  # Emoji support

      # Microsoft fonts compatibility
      corefonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "MesloLGS Nerd Font" "JetBrains Mono" ];
        sansSerif = [ "Inter" "Roboto" "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
      # Better font rendering
      subpixel.rgba = "rgb";
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
    };
  };

  # Plasma/X11 packages
  environment.systemPackages = with pkgs; [
    xclip
    xsel
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.ark
    kdePackages.spectacle
    kdePackages.gwenview
    kdePackages.okular
    vlc
  ];

  # Home-manager configuration for Plasma
  home-manager.users.admin = { pkgs, ... }: {
    # Plasma-specific home-manager settings can go here
  };
}
