{
  config,
  lib,
  ...
}: {

  options = {
    boot.silent.enable = lib.mkEnableOption ''
      
    '';
  };

  config = lib.mkIf config.boot.silent.enable {
    boot.plymouth.enable = true;
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [
  	  "quiet"
  	  "udev.log_level=3"
    ];
  };

  config = lib.mkIf config.zramSwap.enable {
    zramSwap.algorithm = "lz4";
  };

  config = lib.mkIf config.programs.gamescope.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
      };
    };
  };

  config = lib.mkIf config.programs.steam.enable {
    programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  config = lib.mkIf config.programs.gamemode.enable {
      programs.gamemode.enableRenice = true;
  };

  config = lib.mkIf config.services.ananicy.enable  {
    services.ananicy.package = pkgs.ananicy-cpp;
    services.ananicy.rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  options = {
    system.optimizations.enable = lib.mkEnableOption ''
      set the same sysctl settings as are set on SteamOS
    '';
  };

  config = lib.mkIf config.system.optimizations.enable {
    # last cheched with https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamos-customizations-jupiter-20240219.1-2-any.pkg.tar.zst
    boot.kernel.sysctl = {
      # 20-shed.conf
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they're killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };

    services.ananicy.enable = true;

    services.irqbalance.enable = true;
    services.dbus.implementation = "broker";

    zramSwap.enable = true;

    nix.settings.auto-optimise-store = true;

    boot.silent.enable = true;
  };

}
