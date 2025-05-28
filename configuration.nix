{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;  

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Touchpad Support
  services.libinput.enable = true;

  # Time Zone
  time.timeZone = "US/Eastern";

  # Audio
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Users/Packages
  users.users.faris = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = [
      pkgs.librewolf
      pkgs.libreoffice
      (pkgs.callPackage ./neovim.nix {})
    ];
  };

  environment.systemPackages = with pkgs; [
    vim 
    git
  ];

  services.mullvad-vpn.enable = true;

  services.udev.packages = [ pkgs.android-udev-rules ];

  services.logind.lidSwitch = "suspend";

  system.stateVersion = "24.05"; # DO NOT CHANGE

}

