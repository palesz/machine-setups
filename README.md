# machine-setups
Stores (the Nix/NixOS) configuration of all the machines I work with or on

In order to apply the given configuration for a machine:
1. Start with an existing NixOS install or bring up a vanilla [install](https://nixos.org/manual/nixos/stable/index.html#sec-installation). Note: make sure to have `git` as a system package to begin with
1. check out the repository onto the machine 
1. clear out the existing `etc/nixos/` directory
1. `ln -s $REPO/$MACHINE/configuration.nix /etc/nixos/configuration.nix` so the configuration.nix from this repository is used
1. `sudo nixos-rebuild switch` to use the new configuration
1. Enjoy
