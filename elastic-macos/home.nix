{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnsupportedSystem = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "palesz";
  home.homeDirectory = "/Users/palesz";

  home.packages = with pkgs; [
    htop nethogs iotop
    tmux tmuxPlugins.resurrect
    tree
    rsync
    git
    maven3
    gradle
    mc
    colordiff
    groovy
    restic
    # relational databases (for the cli)
    postgresql
    mysql
    clojure
    (
      let
        my-python-packages = ps: with ps; [
          matplotlib
          requests
          pip
        ];
        python-with-my-packages = pkgs.python38.withPackages my-python-packages;
      in
        python-with-my-packages
    )
    # load bash env setup into fish easily with `fenv`
    fishPlugins.foreign-env
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      emacs-daemon = "emacs -f server-start >/dev/null 2>/dev/null &; disown $pid";
      e = "emacsclient";
    };
    shellInit = ''
      ${builtins.readFile ../fish/shellInit.fish}

      set NIX_LINK $HOME/.nix-profile

      set EDITOR emacsclient
      set JAVA8_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_281.jdk/Contents/Home
      set JAVA11_HOME /Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
      set JAVA12_HOME /Library/Java/JavaVirtualMachines/adoptopenjdk-12.jdk/Contents/Home
      set JAVA13_HOME /Library/Java/JavaVirtualMachines/adoptopenjdk-13.jdk/Contents/Home
      set JAVA14_HOME /Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
      set JAVA15_HOME /Library/Java/JavaVirtualMachines/adoptopenjdk-15.jdk/Contents/Home
      set JAVA_HOME $JAVA15_HOME
      set RUNTIME_JAVA_HOME $JAVA15_HOME

    '';
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
      slime
      adoc-mode
      # https://github.com/dakrone/es-mode
      es-mode
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
      atomic-chrome
      git-gutter
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

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.cpu
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
  };

  home.file.".emacs.d" = {
    source = ../emacs;
    recursive = true;
  };

  home.file.".zshrc" = {
    source = ./.zshrc;
  };

  home.file."bin" = {
    source = ./bin;
    recursive = true;
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

