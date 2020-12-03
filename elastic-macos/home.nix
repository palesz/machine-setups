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
    htop nethogs iotop
    tmux
    tree
    rsync
    git
    maven3
    gradle
    mc
    colordiff
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      e = "emacs >/dev/null 2>/dev/null &; disown $pid";
    };
    shellInit = builtins.readFile ../fish/shellInit.fish;
  };
  
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      use-package
      evil
      magit
      markdown-mode
      beacon
      nix-mode
      cider
      adoc-mode
      es-mode # https://github.com/dakrone/es-mode
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
      projectile
      helm
      helm-lsp
      helm-projectile
      treemacs
      flycheck
      company
      hydra
      lsp-java
      lsp-ui
      lsp-mode
      lsp-treemacs
      dap-mode
      yasnippet
      which-key
      visual-regexp
      visual-regexp-steroids
      org-download
      mixed-pitch
    ];
  };
  
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline ];
    settings = {
      background = "dark";
      number = true;
      relativenumber = true;
    };
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

