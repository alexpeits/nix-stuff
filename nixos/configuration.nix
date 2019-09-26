# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

tpacpi-bat = pkgs.tpacpi-bat.overrideAttrs (old: {
  version = "master";
  src = pkgs.fetchFromGitHub {
    owner = "teleshoes";
    repo = "tpacpi-bat";
    rev = "4959b520256cbeb04842f0927e75a63a5ca5030e";
    sha256 = "1w9wzdwy7iladklzwzv8yj1xd9x7q8gi3032db5n54d2q1n3qldn";
  };
});

emacs = (pkgs.emacs.overrideAttrs (old: {
  src = pkgs.fetchgit {
    url = "https://github.com/emacs-mirror/emacs.git";
    rev = "ef0fc0bed1c97a1c803fa83bee438ca9cfd238b0";
    sha256 = "0jv9vh9hrx9svdy0jz6zyz3ylmw7sbf0xbk7i80yxbbia2j8k9j2";
    fetchSubmodules = false;
  };
  patches = [];
  version = "27";
  name = "emacs-27";
})).override { srcRepo = true; };

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    { name = "root";
      device = "/dev/sda2";
      preLVM = true;
    }
  ];

  nix.binaryCaches = [
    "https://cache.nixos.org/"
    "https://alexpeits.cachix.org"
  ];

  nix.binaryCachePublicKeys = [
    "alexpeits.cachix.org-1:O5CoFuKPb8twVOp1OrfSOPfgaEo5X5xlIqGg6dMEgB4="
  ];
  
  networking.networkmanager.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/London";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    pkgs.wget
    pkgs.vim
    pkgs.git
    pkgs.google-chrome
    pkgs.spotify
    pkgs.ag
    pkgs.rofi
    pkgs.xscreensaver
    pkgs.gnome3.gnome-terminal
    pkgs.cachix
    tpacpi-bat
    # emacs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  services.devmon.enable = true;
  # security.setuidPrograms = ["udevil"];

  services.gnome3.gnome-terminal-server.enable = true;

  services.xserver = {
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    enable = true;
    displayManager = {
      gdm.enable = true;
      sddm.enable = lib.mkForce false;
    };
    desktopManager = {
      default = "xfce";
      plasma5.enable = lib.mkForce false;
      xfce = {
        enable = true;
        noDesktop = false;
        enableXfwm = false;
        extraSessionCommands = ''
          (sleep 6 && xset r rate 500 45) &
          setxkbmap -option caps:escape
          xscreensaver -nosplash &
        '';
      };
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [
          haskellPackages.xmonad
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
        ];
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "disk" "networkmanager"];
    group = "users";
    home = "/home/alex";
    isNormalUser = true;
    uid = 1000;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
