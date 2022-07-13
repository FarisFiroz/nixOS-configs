{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
   time.timeZone = "US/Eastern";


  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   #console = {
   #  font = "Lat2-Terminus16";
   #  keyMap = "us";
   #  useXkbConfig = true; # use xkbOptions in tty.
   #};

  # Enable the X11 windowing system.
   services.xserver.enable = true;

  # Enable Pantheon DE
  services.xserver.desktopManager.pantheon.enable = true;
  services.pantheon.apps.enable = false;
  
  # Configure keymap in X11
   services.xserver.layout = "us";
   #services.xserver.xkbOptions = {
   #  "eurosign:e";
   #  "caps:escape" # map caps to escape.
   #};


  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.shado = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
	alacritty
	librewolf
	fish
     ];
   };
  
  # Enable nonfree packages
  nixpkgs.config.allowUnfree = true;

  # Install nvidia drivers
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;

  # List packages installed in system profile. To search, run: $ nix search wget
   environment.systemPackages = with pkgs; [
     vim
   ];


  system.stateVersion = "22.05";

}
  # Unused:

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
