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
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.android_sdk.accept_license = true;

  networking.hostName = "palesz-tp";
  networking.networkmanager.enable = false;

  networking.wireless = {
    enable = true;
    interfaces = [ "wlp3s0" ];
    networks = {
      "palesz" = {
        psk = builtins.replaceStrings ["\n"] [""] "${builtins.readFile ./secrets/wpa-palesz-psk}";
      };
      "palesz-5G" = {
        psk = builtins.replaceStrings ["\n"] [""] "${builtins.readFile ./secrets/wpa-palesz-psk}";
      };
    };
  };

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
      # 32400 # plex
      445 139 # samba
      # 3389 # xrdp
      # 58080 # http server
      # 18080 # http server
      # 58443 # https server
      8080 # miniflux
      22000 # syncthing tcp
    ];
    allowedUDPPorts = [
      # 58600 # wireguard
      137 138 # samba
      22000 # syncthing quic
      21027 # syncthing discovery port
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
          # pixel3a
          publicKey = "0PTDsBWQLzQ5sZkWzOlwQeevPLOAMLe9Ji2l8TnwvFI=";
          allowedIPs = [ "10.100.0.2/32" ];
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
    tailscale home-manager thinkfan exa mergerfs mergerfs-tools
    bpytop ffmpeg parted usbutils sshfs rclone rclone-browser
  ];

  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  security.acme.acceptTerms = true;
  security.acme.email = "palesz@gmail.com";

  services.nginx = {
    enable = true;
    virtualHosts."palesz.synology.me" = {
      enableACME = false;
      forceSSL = false;
      default = true;
      serverAliases = [ "palesz.synology.me" ];
      listen = [
        { addr = "0.0.0.0"; port = 58080; }
        # { addr = "0.0.0.0"; port = 58443; ssl = true; }
      ];
      root = "/data/www/";
      locations = {
        "/" = {
          index = "index.html";
        };
      };
    };
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:8080";
      BASE_URL = "http:///";
    };
  };

  services.rss-bridge = {
    enable = true;
  };

  # torrent section
  services.jackett.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # enable bluetooth support
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  nixpkgs.config.pulseaudio = true;

  # bluetooth
  # https://nixos.wiki/wiki/Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # xrdp access
  services.xrdp.enable = false;
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
    extraGroups = [ "wheel" "docker" "audio" ]; # Enable ‘sudo’ for the user. "networkmanager" ]
    openssh.authorizedKeys.keys = [];
    shell = pkgs.fish;
  };

  home-manager.users.palesz = {pkgs, ...}: {

    nixpkgs.config.allowUnfree = true;

    nixpkgs.config.packageOverrides = pkgs: {
      emacs = pkgs.emacs.override {
        imagemagick = pkgs.imagemagick;
      };
    };

    nixpkgs.config.permittedInsecurePackages = [
      "adobe-reader-9.5.5-1"
    ];

    services.syncthing.enable = true;

    home.packages = with pkgs; [
      adobe-reader scribus pdftk inkscape
      brave
      bitwarden-cli
      lm_sensors
      tmux
      tree
      htop iotop iftop nethogs ethtool speedtest-cli wireshark iperf3
      hdparm
      arandr
      gotty
      sysstat
      youtube-dl
      nmap
      mc krusader mucommander
      gimp
      irssi
      exiftool
      pandoc
      clojure boot leiningen # babashka
      inetutils
      vlc smplayer mplayer
      nomacs
      ffmpeg
      qbittorrent
      qpdf qpdfview okular
      hexchat
      obs-studio
      hardlink rdfind
      
      # rust development
      rustup rust-analyzer
      # rustfmt rustup cargo rust-analyzer

      # vscode
      vscode
      
      libreoffice
      pavucontrol # audio control
      datamash gnumeric
      # python with a custom package list
      (
        let
          my-python-packages = ps: with ps; [
            pandas # needs libstdc++, so cannot install with pip
            requests
            pip
            setuptools
            wheel
          ];
          python-with-my-packages = pkgs.python37.withPackages my-python-packages;
        in
          python-with-my-packages
      )
      zip unzip
      wine
    ];

    programs.go.enable = true;

    # fast image browser
    programs.feh.enable = true;

    programs.fish = {
      enable = true;
      shellInit = ''
        ${builtins.readFile ../fish/shellInit.fish}
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
        # mixed-pitch
        atomic-chrome
        git-gutter
      ];
    };

    home.file.".emacs.d" = {
      # example configuration: https://gitlab.com/rycee/configurations/blob/d6dcf6480e29588fd473bd5906cd226b49944019/user/emacs.nix
      source = ../emacs;
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
  };

  # https://www.tailscale.com/kb/1063/install-nixos
  # admin console: https://login2.tailscale.io/admin
  services.tailscale.enable = true;

  services.restic.backups = {
    localBackup = {
      paths = [
        "/home/palesz"
        "/data"
        "/etc/nixos"
        "/var/lib"
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

  # restic prune setup
  systemd.services."restic-prune" = {
    description = "Service that prunes the restic repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.restic ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      User = "palesz";
      ExecStart = "/bin/sh restic prune --repo /mnt/syno-smb/archive/restic_repo/ --max-repack-size 100g --password-file /etc/nixos/secrets/restic-password";
    };
  };
  systemd.timers."restic-prune" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "0/2:47:00";
    };
  };

  # saving the Mikrotik router configuration
  systemd.services."mikrotik-export" = {
    description = "Export the current Mikrotik configuration as a backup";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.openssh ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      User = "palesz";
      ExecStart = "/bin/sh /home/palesz/Mikrotik/mikrotik-config-export.sh";
    };
  };
  systemd.timers."mikrotik-export" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 05:00:00";
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
    enable = false;
    openFirewall = true;
  };

  services.jellyfin = {
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
      outputFile = "/home/palesz/bitwarden/palesz/export.json";
    };
    monica = {
      user = "root";
      email = "monica.ana@gmail.com";
      passwordFile = ./secrets/bitwarden-monica;
      outputFile = "/home/palesz/bitwarden/monica/export.json";
    };
  };

  services.printing = {
    enable = true;
    drivers = [ canon-cups-ufr2 carps-cups cups-bjnp gutenprint ];
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
      syno = {
        comment = "syno";
        path = "/syno";
        public = "no";
        writable = "yes";
        printable = "no";
        "create mask" = "0644";
        "force user" = "palesz";
        "force group" = "users";
      };
    };
  };

}

