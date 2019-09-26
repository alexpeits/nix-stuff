{ config, lib, pkgs, ... }:

let emacs = pkgs.emacs.overrideAttrs (old: rec {
  src = fetchGit {
    url = "https://github.com/emacs-mirror/emacs";
  };
});

confDir = /home/demo/nixos-config;

in


{
  imports = [ <nixpkgs/nixos/modules/installer/virtualbox-demo.nix> 
              ./extra.nix
            ];

  # Let demo build as a trusted user.
# nix.trustedUsers = [ "demo" ];

# Mount a VirtualBox shared folder.
# This is configurable in the VirtualBox menu at
# Machine / Settings / Shared Folders.
# fileSystems."/mnt" = {
#   fsType = "vboxsf";
#   device = "nameofdevicetomount";
#   options = [ "rw" ];
# };

# By default, the NixOS VirtualBox demo image includes SDDM and Plasma.
# If you prefer another desktop manager or display manager, you may want
# to disable the default.
# services.xserver.desktopManager.plasma5.enable = lib.mkForce false;
# services.xserver.displayManager.sddm.enable = lib.mkForce false;

# Enable GDM/GNOME by uncommenting above two lines and two lines below.
# services.xserver.displayManager.gdm.enable = true;
# services.xserver.desktopManager.gnome3.enable = true;

services.gnome3.gnome-terminal-server.enable = true;

nixpkgs.config.allowUnfree = true;
# nixpkgs.config.packageOverrides = pkgs: let self = {
#   emacs = pkgs.callPackage /home/demo/nixos-config/emacs {};
# }; in self;

nixpkgs.overlays =  [ (self: super: {
  emacs = pkgs.callPackage /home/demo/nixos-config/emacs { pkgs = super; };
})];



services.xserver = {
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
        xmessage "hey" &
      '';
    };
  };
  windowManager = {
    default = "xmonad";
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages : [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };
  };
};

# programs.bash.interactiveShellInit = ''
#   echo hey
# '';

# Set your time zone.
# time.timeZone = "Europe/Amsterdam";

# List packages installed in system profile. To search, run:
# \$ nix search wget
environment.systemPackages = [
  pkgs.wget 
  pkgs.vim
  pkgs.git
  pkgs.emacs
  pkgs.rofi
  pkgs.gnome3.gnome-terminal
  pkgs.xorg.xmessage
  pkgs.ag
  pkgs.google-chrome
];

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

}
