{ config, pkgs, lib, ... }:

let

  myEmacs = (pkgs.emacsPackagesFor pkgs.emacs).withPackages (epkgs: with epkgs; [ 
    vterm
    use-package
  ]);

  myRetroarch = pkgs.retroarch.override { cores= with pkgs.libretro; [
    mgba
    citra
    mupen64plus
  ];};

  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";

  unstable = import <nixos-unstable> {};

  unfree = import <nixos> {
    config.allowUnfree = true;
    overlays = [
      (final: prev: { 
        #blender = prev.blender.override { cudaSupport = true; };
      })
    ];
  };

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

in 
{

  # ===== Base Settings ===== #
  # ----- Imports ----- #
  imports =
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # ----- Bootloader ----- #
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.efi.efiSysMountPoint = "/mnt/boot/efi";

  # ----- Power Management ----- #
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # ----- Kernel Version ----- #
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ----- Networking ----- #
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # ----- Bluetooth ----- #
  hardware.bluetooth.enable = true;

  # ----- Locale ----- #
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # ----- GPU Passthrough ----- #
   #boot.kernelParams = ["intel_iommu=on"];
   #boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
   #boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
   #boot.extraModprobeConfig = "options vfio-pci ids=10de:2520,10de:228e";

  # ----- iGPU Virtualization ----- #
    #virtualisation.kvmgt.enable = true;
    #virtualisation.kvmgt.vgpus = {
    #  "i915-GVTg_V5_4" = {
    #    uuid = [ "a297db4a-f4c2-11e6-90f6-d3b88d6c9525" ];
    #  };
    #};
  # ===== GUI ===== #

  # ----- X11 ----- #
  services.xserver.enable = true;


  # ----- Install nvidia drivers ----- #
  boot.blacklistedKernelModules = ["nouveau"];
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = ["nvidia"]; 
  hardware.nvidia.prime = {
  offload.enable = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.opengl.enable = true;

  #specialisation = {
  #  external-display.configuration = {
  #    system.nixos.tags = [ "external-display" ];
  #    hardware.nvidia.prime.offload.enable = lib.mkForce false;
  #    hardware.nvidia.powerManagement.enable = lib.mkForce false;
  #  };
  #}; 

  # ----- Desktop Environment ----- #
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.light.enable = true;
  programs.sway = {
    enable = true;
    extraOptions = ["--unsupported-gpu"];
    extraPackages = with pkgs; [
      font-awesome
      xwayland
      waybar
      wofi
      foot
      pulsemixer
    ];
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # ===== Sound ===== #
  sound.enable = true;
  #hardware.pulseaudio.enable = true;
   security.polkit.enable = true;
   security.rtkit.enable = true;
   services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     jack.enable = true;
   };

  # ===== Users/Packages ===== #

  # ----- Package Config ----- #
  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
      ];
    };
  };

  # ----- Users ----- #
  users.users.faris = {
    isNormalUser = true;
    description = "Faris";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "video"];
    packages = with pkgs; [
	myRetroarch
        keepassxc
  	unstable.ani-cli
	ungoogled-chromium
	unfree.blender
	gimp
	myEmacs

    ];
  };


  home-manager.users.faris = {
    home.stateVersion = "22.11";
  };

  # ----- System Packages ----- #
  environment.systemPackages = with pkgs; [
    powertop
    qjackctl
    qpwgraph
    nvidia-offload
    unfree.nvtop
    pciutils
    libreoffice
    git
    vim 
    librewolf
    htop
    neofetch
    virt-manager
    mullvad-vpn
    #btrfs-heatmap
  ];

  # ----- Emacs ----- #


  # ===== Other ===== #

  # ----- Virtualization ----- #
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.verbatimConfig = ''user = "faris"'';
    };
  };

 # ----- VPN ----- #
 services.mullvad-vpn.enable = true;
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.xserver.libinput.enable = true;

  system.stateVersion = "22.05";
}
