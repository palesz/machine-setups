# machine-setups
Stores (the Nix/NixOS) configuration of all the machines I work with or on

In order to apply the given configuration for a machine:
1. check out the repository onto the machine 
2. clear out the existing `etc/nixos/` directory
3. `ln -s $REPO/$MACHINE/configuration.nix /etc/nixos/configuration.nix` so the configuration.nix from this repository is used
4. `sudo nixos-rebuild switch` to use the new configuration
5. Enjoy
