# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with import <nixpkgs> {};

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./jupyter-nb-service.nix
      ./bitwarden-backup-module.nix
      <home-manager/nixos>
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.android_sdk.accept_license = true;

  networking.hostName = "palesz-tp"; # Define your hostname.
  networking.networkmanager.enable = false;

  # Since currently this machine is wired, let's disable the wireless access
  # no need for it
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.networks = {
    palesz = {
      psk = builtins.replaceStrings ["\n"] [""] "${builtins.readFile ./secrets/wpa-palesz-psk}";
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Wireguard configuration
  networking.nat.enable = false;
  networking.nat.externalInterface = "enp0s25";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = [
      22 # ssh
      32400 # plex
      445 139 # samba
      3389 # xrdp
      58080 # http server
      58443 # https server
      # 58090 58091 58092 # video broadcast
    ];
    allowedUDPPorts = [
      # 58600 # wireguard
      137 138 # samba
    ];

    /*
    # The firewall restart fails, since the wireguard interface is only started
    # after the firewall restart.
    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.100.0.0./24 -o eth0 -j MASQUERADE
    '';
    */
  };

  networking.wireguard.enable = false;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 58600;
      privateKeyFile = ./secrets/wireguard-keys/palesz-tp.private;

      peers = [
        {
          # palesz-pixel3a
          publicKey = "0PTDsBWQLzQ5sZkWzOlwQeevPLOAMLe9Ji2l8TnwvFI=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          # palesz-amzn-laptop
          publicKey = "RXwMCBkBbgG6F9OUCudEsIq/6GoPY1j13AAVly6JsXg=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim nano wpa_supplicant firefox restic git
    fahviewer fahcontrol bitwarden-cli wireguard
    wireguard-tools config.services.samba.package
    tailscale home-manager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  security.acme.acceptTerms = true;
  security.acme.email = "palesz@gmail.com";

  services.nginx = {
    enable = true;
    virtualHosts."palesz.synology.me" = {
      enableACME = true;
      forceSSL = true;
      default = true;
      serverAliases = [ "palesz.synology.me" ];
      listen = [
        { addr = "0.0.0.0"; port = 58080; }
        { addr = "0.0.0.0"; port = 58443; ssl = true; }
      ];
      root = "/data/www/";
      locations = {
        "/" = {
          index = "index.html";
        };
      };
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # xrdp access
  services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.defaultWindowManager = "${pkgs.i3}/bin/i3";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

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

  services.logind.lidSwitch = "ignore"; # in general
  services.logind.lidSwitchDocked = "ignore"; # when an extra monitor is plugged in
  services.logind.lidSwitchExternalPower = "ignore"; # when on external power

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.palesz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" /* "adbusers" */ ]; # Enable ‘sudo’ for the user. "networkmanager" ]
    openssh.authorizedKeys.keys = [
    ];
    shell = pkgs.fish;
  };

  # programs.adb.enable = true; # Android development - https://nixos.wiki/wiki/Android

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

    nixpkgs.config.permittedInsecurePackages = [
      "adobe-reader-9.5.5-1"
    ];

    home.packages = with pkgs; [
      adobe-reader
      brave
      bitwarden-cli
      lm_sensors
      tmux
      tree
      htop
      iotop
      sysstat
      youtube-dl
      nmap
      mc
      gimp
      # conda
      irssi
      exiftool
      pandoc
      clojure
      boot # babashka
      leiningen
      inetutils
      vlc
      nomacs
      slack
      ffmpeg
      # Android development - https://nixos.wiki/wiki/Android
      # android-studio
      # adb-sync
      qbittorrent
      qpdfview
      hexchat
      libreoffice
      # python with a custom package list
      (
        let
          my-python-packages = ps: with ps; [
            pandas
            matplotlib
            requests
            geopandas
            cartopy
            seaborn
            pip
          ];
          python-with-my-packages = pkgs.python38.withPackages my-python-packages;
        in
          python-with-my-packages
      )
      pipenv
      unzip
    ];

    programs.feh.enable = true;

    programs.fish.enable = true;
    programs.zsh.enable = true;

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
      # example configuration: https://gitlab.com/rycee/configurations/blob/d6dcf6480e29588fd473bd5906cd226b49944019/user/emacs.nix
      source = ./emacs;
      recursive = true;
    };

    home.file.".git-credentials" = {
      source = ./secrets/.git-credentials;
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
      userName = "palesz";
      userEmail = "palesz@gmail.com";
      extraConfig = {
        credential.helper = "store";
      };
    };
  };

  # services.foldingathome.enable = false;

  # https://www.tailscale.com/kb/1063/install-nixos
  # admin console: https://login2.tailscale.io/admin
  services.tailscale.enable = true;

  services.restic.backups = {
    localBackup = {
      paths = [
        "/home/palesz"
        "/data"
        "/etc/nixos"
      ];
      repository = "/syno/archive/restic_repo";
      passwordFile = toString ./secrets/restic-password;
      user = "root";
      extraBackupArgs = [
        "--exclude-if-present=.restic_skip"
        "--exclude" "/home/palesz/.conda"
        "--exclude" "/home/palesz/Downloads"
        "--exclude" "/home/palesz/snap"
        "--exclude" "/home/palesz/.cache"
        "--exclude" "/home/palesz/.npm"
        "--exclude" "/home/palesz/.config"
        "--exclude" "/home/palesz/.nix-profile"
      ];
      timerConfig = {
        OnCalendar = "00:00:00";
        # OnCalendar = "*:0/3:00"; # just for testing
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

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Enable cron service, https://nixos.wiki/wiki/Cron
  services.cron = {
    enable = true;
    systemCronJobs = [
      # "*/5 * * * *      root    date >> /tmp/cron.log"
    ];
  };

  services.jupyterNotebookSvc = {
    enable = false;
    user = "palesz";
    notebookDir = "/";
  };

  services.bitwarden.backups = {
    palesz = {
      user = "root";
      email = "palesz@gmail.com";
      passwordFile = ./secrets/bitwarden-palesz;
      outputFile = "/syno/homes/palesz/bitwarden/export.json";
    };
    monica = {
      user = "root";
      email = "monica.ana@gmail.com";
      passwordFile = ./secrets/bitwarden-monica;
      outputFile = "/syno/homes/monica/bitwarden/export.json";
    };
  };

  # you have to add the user with smbpasswd -a [username]
  # otherwise you won't be able to login with the user to
  # the samba share
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      server role = standalone
      load printers = no
      printcap name = /dev/null
      log level = 2
    '';
    shares = {
      palesz = {
	      comment = "home folder";
        path = "/home/palesz";
        public = "no";
        writable = "yes";
	      printable = "no";
        "create mask" = "0644";
        "force user" = "palesz";
        "force group" = "users";
      };
      data = {
	      comment = "data folder";
        path = "/data";
        public = "no";
        writable = "yes";
	      printable = "no";
        "create mask" = "0644";
        "force user" = "palesz";
        "force group" = "users";
      };
    };
  };

#   systemd.services.jupyterNotebookSvc = {
#     description = "JupyterLab as service";
#     wantedBy = [ "multi-user.target" ];
#     after = [ "network.target" ];
#     serviceConfig = {
#       Restart = "always";
#       RestartSec = "120min";
#       TimeoutStartSec = "15min";
#       User = "palesz";
#       ExecStart = "/bin/sh /data/projects/start-jupy.sh";
#     };
#   };

}

