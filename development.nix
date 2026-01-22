{ config, lib, pkgs, ... }:

{
  # Configure npm/pnpm global directory and bundle cache
  environment.variables = {
    NPM_CONFIG_PREFIX = "/mnt/psf/nvmecased/nix-opt/npm";
    PNPM_HOME = "/mnt/psf/nvmecased/nix-opt/pnpm";
    BUNDLE_PATH = "/mnt/psf/nvmecased/package-cache/bundle";
    EXTERNAL_HOME = "/mnt/psf/nvmecased/external-home";
  };

  # Add npm/pnpm bin to PATH
  environment.shellInit = ''
    export PATH="$PNPM_HOME:/mnt/psf/nvmecased/nix-opt/npm/bin:$PATH"
  '';

  # Enable Nix Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (needed for Parallels tools)
  nixpkgs.config.allowUnfree = true;

  # Enable nix-ld for running unpatched dynamic binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
      glib
      icu
    ];
  };
}
