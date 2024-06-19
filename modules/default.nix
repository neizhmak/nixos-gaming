{
  inputs,
  self,
  ...
}: {
  flake.nixosModules = let
    inherit (inputs.nixpkgs.lib) filter attrNames;
  in {

    tweaks = import ./tweaks.nix;

    default = throw ''
      The usage of default module is deprecated as multiple modules are provided by nix-gaming. Please use
      the exact name of the module you would like to use. Available modules are:

      ${builtins.concatStringsSep "\n" (filter (name: name != "default") (attrNames inputs.self.nixosModules))}
    '';
  };
}
