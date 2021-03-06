# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

    nixpkgs.config.allowUnfree = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.systemd-boot.enable = true;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "palesz-nixos"; # Define your hostname.
  # networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;
  networking.enableIPv6 = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano firefox home-manager rxvt_unicode clipmenu
  ];

  # docker is useful to try out other linux distributions
  virtualisation.docker.enable = true;

  fonts.fonts = with pkgs; [
    hermit
    source-code-pro
    terminus_font
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  services.xrdp = {
    enable = true;
    port = 3389;
    defaultWindowManager = "${pkgs.i3}/bin/i3";
  };

  # services.logind.lidSwitch = "ignore"; # in general
  # services.logind.lidSwitchDocker = "ignore"; # when extra monitor is plugged in 
  # services.logind.lidSwitchExternalPower = "ignore"; # when on external power

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 3389 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = false;
  # build packages with the expectation that pulse will be here
  # nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
    # fix the crackling
    configFile = pkgs.runCommand "default.pa" {} ''
      sed 's/module-udev-detect$/module-udev-detect tsched=0/' ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    '';
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
      ];
  };

  # databases used for development and SQL checks
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    enableTCPIP = false; # localhost only via UNIX or localhost TCP
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    bind = "127.0.0.1"; # localhost only
    port = 3306;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.palesz = {
    isNormalUser = true;
    extraGroups = [
      "wheel"  # Enable ‘sudo’ for the user.
      "vboxsf" # Enable the access to the VirtualBox shared folders
      "docker" # Enable docker
      "audio" # just in case
    ];
    shell = pkgs.fish;
  };

  home-manager.users.palesz = {pkgs, ...}: {

    nixpkgs.config.allowUnfree = true;

    # emacs bleeding edge overlay
    # https://github.com/nix-community/emacs-overlay
    # nixpkgs.overlays = [
    #  (import (builtins.fetchTarball {
    #    url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    #  }))
    # ];

    nixpkgs.config.packageOverrides = pkgs: {
      emacs = pkgs.emacs.override {
        imagemagick = pkgs.imagemagick;
      };
    };

    home.packages = with pkgs; [
      chromium
      bitwarden-cli
      lm_sensors
      tmux
      tree
      htop iotop iftop nethogs
      gotty
      inetutils
      usbutils
      pciutils
      xorg.xdpyinfo
      sysstat
      nmap
      mc
      pandoc
      datamash
      graphviz
      nomacs
      slack
      qpdfview
      zip
      unzip
      wget
      curl
      fish
      zsh
      zsh-powerlevel9k
      git
      git-lfs
      clojure leiningen boot
      sqlite sqlitebrowser sqliteInteractive
    ];

    programs.fish = {
      enable = true;
      shellAliases = {
        e = "emacs >/dev/null 2>/dev/null &; disown $pid";
        i = "idea-community >/dev/null 2>/dev/null &; disown $pid";
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
        expand-region
      ];
    };

    home.file.".emacs.d" = {
      source = ../emacs;
      recursive = true;
    };

    home.file."start-ssh-agent.sh" = {
      text = ''
      #!bash

      eval "$(ssh-agent -s)"
      ssh-add ~/.ssh/id_rsa
      '';
      executable = true;
    };

    home.file.".Xresources" = {
      text = ''
      !################
      ! Colors
      !################
      *foreground: white
      *background: black

      !################
      ! URxvt settings
      !################
      URxvt.font: xft: Hermit Light:size=10
      URxvt.scrollbar: false
      '';
    };

    home.file.".config" = {
      source = ./.config;
      recursive = true;
    };

    home.file.".Xresources" = {
      source = ./.Xresources;
    };

    # does not really work for a simple shell.nix
    # it's easier to use a simple shell script (see above) with a shell hook
    # that starts the nix-shell if we are not in a nix-shell already
    programs.direnv = {
      enable = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
      enableNixDirenvIntegration = false;
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
    
    programs.git = {
      enable = true;
      userName = "Andras Palinkas";
      userEmail = "andras.palinkas@elastic.co";
      extraConfig = {
        credential.helper = "store";
        alias.dag = "log --graph --abbrev-commit --decorate --format=format:'%C(blue)%h%C(reset) - %C(cyan)%aD%C(reset) %C(green)(%ar)%C(reset)%C(yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(white)- %an%C(reset)' --all";
        alias.pr = "!f() { git fetch origin pull/$1/head:pr/$1; }; f";
        core.editor = "emacs";
        /*
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true*/
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

