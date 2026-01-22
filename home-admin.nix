{ config, lib, pkgs, ... }:

let
  # JRuby 9.4.12.0 (supports JDK 17)
  pkgs-jruby94 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
    sha256 = "0m0xmk8sjb5gv2pq7s8w7qxf7qggqsd3rxzv3xrqkhfimy2x7bnx";
  }) { inherit (pkgs) system; };
  jruby94 = pkgs-jruby94.jruby.override { jre = pkgs.jdk17; };
in
{
  home-manager.users.admin = { pkgs, config, lib, ... }: {
    home.stateVersion = "25.11";

    # Link nvim config from dotfiles/nvim
    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/psf/apfs/nixos-parallels-vm/dotfiles/nvim";
      force = true;
    };

    # Link tmux config from dotfiles/tmux
    xdg.configFile."tmux" = {
      source = config.lib.file.mkOutOfStoreSymlink "/mnt/psf/apfs/nixos-parallels-vm/dotfiles/tmux";
      force = true;
    };

    # Generate .env.json with Nix store paths for Java/jdtls
    xdg.configFile.".env.json".text = builtins.toJSON {
      java_17_home = "${pkgs.jdk17}/lib/openjdk";
      java_21_home = "${pkgs.jdk21}/lib/openjdk";
      jdtls_home = "${pkgs.jdt-language-server}/share/java/jdtls";
      jdtls_bin = "${pkgs.jdt-language-server}/bin/jdtls";
      java_debug_jar = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.53.1.jar";
      java_test_jars = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server";
      lombok_jar = "${pkgs.lombok}/share/java/lombok.jar";
    };

    # VS Code Java settings with JDK paths
    xdg.configFile."vscode-settings/java.json".text = builtins.toJSON {
      "java.jdt.ls.java.home" = "${pkgs.jdk21}/lib/openjdk";
      "java.configuration.updateBuildConfiguration" = "interactive";
      "java.configuration.maven.userSettings" = "/mnt/psf/nvmecased/nix-opt/mvn/sap-settings.xml";
      "java.import.maven.enabled" = true;
      "java.references.includeDeclarations" = false;
      "java.configuration.runtimes" = [
        {
          name = "JavaSE-17";
          path = "${pkgs.jdk17}/lib/openjdk";
        }
        {
          name = "JavaSE-21";
          path = "${pkgs.jdk21}/lib/openjdk";
          default = true;
        }
      ];
    };

    # Link vimrc from dotfiles/vim
    home.file.".vimrc".source = ./dotfiles/vim/vimrc;

    # Claude Code settings - disable IDE diff views
    home.file.".claude/settings.json".text = builtins.toJSON {
    };

    # VS Code Server - link to external storage
    home.file.".vscode-server".source =
      config.lib.file.mkOutOfStoreSymlink "/mnt/psf/nvmecased/external-home/.vscode-server";

    # Symlinks in ~/opt/links/
    home.file."opt/links/jdk17".source = "${pkgs.jdk17}/lib/openjdk";
    home.file."opt/links/jdk21".source = "${pkgs.jdk21}/lib/openjdk";
    home.file."opt/links/jruby".source = "${pkgs.jruby}/lib";
    home.file."opt/links/jruby.jar".source = "${pkgs.jruby}/lib/jruby.jar";
    home.file."opt/links/jruby94".source = "${jruby94}/lib";
    home.file."opt/links/jruby94.jar".source = "${jruby94}/lib/jruby.jar";
    home.file."opt/links/sap/settings.xml".source =
      config.lib.file.mkOutOfStoreSymlink "/mnt/psf/nvmecased/nix-opt/mvn/sap-settings.xml";
    home.file."opt/links/sap/agent-builder.jar".source =
      config.lib.file.mkOutOfStoreSymlink "/mnt/psf/nvmecased/nix-opt/patched/agent-builder.jar";
    home.file."opt/links/sap/m2/repository".source =
      config.lib.file.mkOutOfStoreSymlink "/mnt/psf/nvmecased/package-cache/m2/repository";

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

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "172.18.0.1" = {
          hostname = "172.18.0.1";
          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
        };
      };
    };

    # Configure Claude Code MCP servers on activation
    home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="/mnt/psf/nvmecased/nix-opt/pnpm:$PATH"
      OBSIDIAN_VAULT="/mnt/psf/nvmecased/external-home/obsidian/default"
      if command -v claude &> /dev/null && [ -d "$OBSIDIAN_VAULT" ]; then
        claude mcp add-json obsidian --scope user \
          "{\"type\":\"stdio\",\"command\":\"pnpm\",\"args\":[\"dlx\",\"@mauricio.wolff/mcp-obsidian@latest\",\"$OBSIDIAN_VAULT\"]}" \
          2>/dev/null || true
      fi
    '';

    home.enableNixpkgsReleaseCheck = false;
  };
}
