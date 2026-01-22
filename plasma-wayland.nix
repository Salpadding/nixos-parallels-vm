{ config, pkgs, ... }:

{
  # Enable X11 with SDDM display manager
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  # Enable SDDM display manager with Wayland
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    defaultSession = "plasma";
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
      waylandFrontend = true;  # Using Wayland
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
    # Configure KWin to use Fcitx 5 as virtual keyboard (Wayland input method)
    xdg.configFile."kwinrc" = {
      text = ''
        [Wayland]
        InputMethod[$e]=/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop
      '';
      force = true;
    };

    # Fcitx5 input method configuration - add Rime
    xdg.configFile."fcitx5/profile" = {
      text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=rime

        [Groups/0/Items/0]
        Name=keyboard-us
        Layout=

        [Groups/0/Items/1]
        Name=rime
        Layout=

        [GroupOrder]
        0=Default
      '';
      force = true;
    };

    # Rime configuration - use Simplified Chinese
    xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
      text = ''
        patch:
          schema_list:
            - schema: luna_pinyin_simp
          menu/page_size: 9
      '';
    };

    # Luna Pinyin Simp schema settings
    xdg.dataFile."fcitx5/rime/luna_pinyin_simp.custom.yaml" = {
      text = ''
        patch:
          switches:
            - name: ascii_mode
              reset: 0
              states: [ 中文, 西文 ]
            - name: full_shape
              states: [ 半角, 全角 ]
            - name: ascii_punct
              states: [ 。，, ．， ]
      '';
    };
  };
}
