{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # just to see if intellij will work with this
  # nixpkgs.config.allowUnsupportedSystem = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "palesz";
  home.homeDirectory = "/Users/palesz";

  home.packages = with pkgs; [
    htop
    tmux
    tree
    # git - should use the Apple one
    # adoptopenjdk-hotspot-bin-13
    maven3
    gradle
    # jetbrains.idea-community
    # docker
  ];

    programs.emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        evil
        magit
        markdown-mode
        beacon
        nix-mode
        cider
        adoc-mode
        org-beautify-theme
        org-bullets
        htmlize
        powerline
        ob-restclient
        ob-clojurescript
        ob-go
        ob-http
        ob-sql-mode
        ob-async
        json-mode
        ein
        visual-fill-column
      ];
    };

    home.file.".emacs.d" = {
      source = ../emacs;
      recursive = true;
    };

    home.file.".zshrc" = {
      source = ./.zshrc;
    };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}

