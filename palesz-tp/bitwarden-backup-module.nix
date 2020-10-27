{ config, pkgs, lib, ... }:
with lib;

{
  options.services.bitwarden.backups = mkOption {
    description = ''Periodic backups from Bitwarden.'';
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        user = mkOption {
          type = types.str;
          description = ''The user to run the backup script with.'';
          default = "root";
        };
        email = mkOption {
          type = types.str;
          description = ''The Bitwarden e-mail address (account).'';
        };
        passwordFile = mkOption {
	        type = types.path;
	        description = ''The file that stores the password for the Bitwarden account.'';
        };
        outputFile = mkOption {
          type = types.str;
          description = ''The location where the Bitwarden output should be saved to.'';
        };
        format = mkOption {
          type = types.str;
          description = ''The format of the Bitwarden output. json or csv'';
        default = "json";
        };
      };
    }));
    default = {};
  };

  config = {
    systemd.services = mapAttrs' (name: backup:
      let
        exportScript = builtins.toFile "bitwarden-export-script.sh" ''
        #!/bin/sh
        set -e

        # set the path to the cli and the APPDATA_DIR
        bw=$1
	      email="$2"
	      passwordFile="$3"
        outputFile="$4"
        format=$5

        export BITWARDENCLI_APPDATA_DIR="$HOME/.config/bitwarden-export-script/$email"

        # login if required
        the_password=`cat $passwordFile`
        $bw --nointeraction login --check || $bw --nointeraction login $email "$the_password"
        # unlock if required
        $bw --nointeraction unlock --check || export BW_SESSION=`$bw --nointeraction unlock "$the_password" --raw`

        # create the output directory
        mkdir -p `dirname $outputFile`

        # supposedly the export will use our login from the specified BITWARDENCLI_APPDATA_DIR
        $bw --nointeraction export "$the_password" --output $outputFile --format $format

        $bw lock

        echo "Bitwarden successfully exported for $email to $outputFile in $format format."
        '';

      in nameValuePair "bitwarden-backups-${name}" {
        # creates a systemd service configuration for exporting that exports the passwords of the user
        # from bitwarden on a regular basis
        description = "Bitwarden password export service for ${backup.email}";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.bitwarden-cli ];
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          User = "${backup.user}";
          ExecStart = "/bin/sh ${exportScript} ${pkgs.bitwarden-cli.out}/bin/bw '${backup.email}' '${backup.passwordFile}' '${backup.outputFile}' '${backup.format}'";
        };
      }
    ) config.services.bitwarden.backups;
    systemd.timers = mapAttrs' (name: backup: nameValuePair "bitwarden-backups-${name}" {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # https://www.freedesktop.org/software/systemd/man/systemd.time.html
        # OnCalendar = "*:0/2:00";
        OnCalendar = "00:00:00";
      };
    }) config.services.bitwarden.backups;
  };
}

