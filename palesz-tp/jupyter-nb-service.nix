{ lib, pkgs, config, nixpkgs, ... }:
with lib;                      
let
  cfg = config.services.jupyterNotebookSvc;
  defaultCondaEnvName = "jupyter-notebooks";
in {
  options.services.jupyterNotebookSvc = {
    enable = mkEnableOption "Jupyter Notebook Service";
    notebookDir = mkOption {
      type = types.str;
      default = "/";
    };
    user = mkOption {
      type = types.str;
      default = "root";
    };
    condaEnvironmentName = mkOption {
      type = types.str;
      default = "${defaultCondaEnvName}";
    };
    condaEnvironmentFile = mkOption {
      type = types.str;
      default = builtins.toFile "environment.yml" ''
        name: ${defaultCondaEnvName}
        channels:
          - defaults
          - conda-forge
        dependencies:
          - jupyterlab
          - nodejs
          - ipympl
          - pip
          - pip:
            - aws
            - pandas
            - matplotlib
      '';
    };
    jupyterBuildScript = mkOption {
      type = types.str;
      default = ''
        jupyter labextension install '@jupyter-widgets/jupyterlab-manager' jupyter-matplotlib --minimize=False
      '';
    };
  };

  # How to set up a conda-shell on nix-os: http://www.jaakkoluttinen.fi/blog/conda-on-nixos/
  # or just install nixpkgs.conda-shell
  # https://unix.stackexchange.com/questions/523454/nixos-use-services-on-non-nixos-os-eventually-with-only-user-rights
  # https://nixos.wiki/wiki/NixOS:extend_NixOS
  # https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files
  config = lib.mkIf cfg.enable {
      systemd.services.jupyterNotebookSvc = let
        jupyterStartScript = builtins.toFile "jupyter-svc-start.sh" ''
            set -xe
            $HOME/.nix-profile/bin/conda-shell <<EOF
              set -xe
              conda init bash
              conda_env_file="/tmp/`basename ${cfg.condaEnvironmentFile}`"
              rm \$conda_env_file || echo "Noop"
              ln -s ${cfg.condaEnvironmentFile} \$conda_env_file
              . $HOME/.bashrc
              (conda config --set offline true && conda env update -n ${cfg.condaEnvironmentName} -f \$conda_env_file --prune) || (conda config --set offline false && conda env update -n ${cfg.condaEnvironmentName} -f \$conda_env_file --prune)
              conda config --set offline false
              conda activate ${cfg.condaEnvironmentName}
              ${cfg.jupyterBuildScript}
              jupyter lab --ip=* --NotebookApp.token= --NotebookApp.password= --NotebookApp.notebook_dir=${cfg.notebookDir}
            EOF
        '';
      in {
        description = "JupyterLab as service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Restart = "always";
          RestartSec = "120min";
          TimeoutStartSec = "15min";
          User = "${cfg.user}";
          ExecStart = "/bin/sh ${jupyterStartScript}";
        };
      };
  };
}

