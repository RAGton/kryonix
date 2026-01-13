{ lib, pkgs, ... }:
{
  config = lib.mkIf (!pkgs.stdenv.isDarwin) {
    home.packages = [ pkgs.mangohud ];

    # Preset simples (sem cores hardcoded) para monitorar FPS/frametime e uso de GPU/CPU.
    xdg.configFile."MangoHud/MangoHud.conf" = {
      force = true;
      text = ''
      legacy_layout=0
      horizontal
      fps
      frametime
      frame_timing=1

      gpu_stats
      gpu_temp
      gpu_core_clock
      gpu_mem_clock
      vram

      cpu_stats
      cpu_temp
      ram

      # Útil para troubleshooting de runtime/driver
      vulkan_driver
      engine_version
      '';
    };
  };
}
