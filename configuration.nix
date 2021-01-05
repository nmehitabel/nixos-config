# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  # General Housekeeping

  services.journald.extraConfig = "SystemMaxUse=500M";

  # Collect nix store garbage and optimise daily.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.optimise.automatic = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno2.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  networking.hostName = "nixP330t";
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      (neovim.override {
        viAlias = true;
        vimAlias = true;
        configure = {
          customRC = ''
            set shiftwidth=2
            set softtabstop=2
            set number
            set expandtab
            set background=dark
          '';
          packages.myVimPackage = with pkgs.vimPlugins; {
            start = [
              vim-startify  airline             sensible
              polyglot      ale                 fugitive
            ];
            opt = [ ];
          };
        };
      })
      ark
      autorandr
      binutils
      cargo
      dbus
      direnv
      docker
      docker-compose
      dpkg
      exa
      fd
      file
      firefox
      fzf
      git
      gitAndTools.hub
      gnome-themes-standard
      gnupg
      gnumake
      google-chrome
      gzip
      inetutils
      iperf
      iptables
      iotop
      jdk11
      jq
      keepassxc
      kdiff3
      killall
      ksystemlog
      libnotify
      libpng
      libxml2
      lsof
      ncat
      neovim
      nix-direnv
      okular
      openssl
      parted
      perl
      plasma-workspace
      python37
      qdirstat
      ranger
      ripgrep
      rustc
      shutter
      slack
      spectacle
      sudo
      terminator
      tree
      unzip
      which      
      wget
      vim
      visualvm
      unstable.alacritty
      unstable.jetbrains.idea-community
      tailscale
      unstable.vscode
      xclip
      xsel
      xsv
      ytop
      zip
      zsh
    ];

  # nix options for derivations to persist garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-emoji
    source-code-pro
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };
  programs.ssh.startAgent = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

 
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.enable = true;
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = false;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "4096";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "10240";
    }
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gcasey = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/gcasey";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  };
 
  users.groups."gcasey" = { gid = 1000; name = "gcasey"; members = [ "gcasey" ]; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

