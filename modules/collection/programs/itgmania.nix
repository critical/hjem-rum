{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) mapAttrs mapAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) attrsOf nullOr oneOf bool float int str submodule;

  ini = pkgs.formats.ini {};

  cfg = config.rum.programs.itgmania;

  profile = submodule {
    options = {
      displayName = mkOption {
        type = nullOr str;
        default = null;
        description = "Display name for the profile";
      };

      modifiers = mkOption {
        type = attrsOf (nullOr (oneOf [str int bool float]));
        default = {};
        description = "Profile gameplay modifier preferences";
      };
    };
  };
in {
  options.rum.programs.itgmania = {
    enable = mkEnableOption "itgmania";
    package = mkPackageOption pkgs "itgmania" {nullable = true;};

    profiles = mkOption {
      type = attrsOf profile;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    files = mapAttrs' (id: profile:
      nameValuePair ".itgmania/Save/LocalProfiles/${id}/Simply Love UserPrefs.ini" {
        source = ini.generate "Simply Love UserPrefs.ini" {
          "Simply Love" = profile.modifiers;
        };
      })
    cfg.profiles;
  };
}
