{
  pkgs ? import <nixpkgs> {}
  # This allows us to provide a command to run via `--argstr run COMMAND`.
  # run ? "zsh"
}:

# we need the next line, so the writeScript is available below
with import <nixpkgs> {};
let
  customFishShellInit = writeText "config.fish" ''
    # set the SHELL to zsh
    export SHELL='${pkgs.fish}/bin/fish'

    export JAVA11_HOME='/home/palesz/.java/jdk-11.0.8+10'
    export JAVA14_HOME='/home/palesz/.java/jdk-14.0.2+12'
    export JAVA_HOME=$JAVA14_HOME
    export IDEA_JDK=$JAVA_HOME

    alias esv='~/es-versions.sh'

    # helper functions
    function qlg -a task
      ./gradlew :x-pack:plugin:{sql,ql,eql}:{$task}
    end

    function pp -a BRANCH
      set -q BRANCH; or set BRANCH (git branch --show-current)
      git push $USER $argv $BRANCH:$BRANCH
    end

    function pf
      pp --force
    end

    function ghb -a REMOTE -a BRANCH
      set -q REMOTE[1]; or set REMOTE origin
      set -q BRANCH[1]; or set BRANCH (git branch --show-current)
      set URL (git remote get-url $REMOTE | sed 's/^[^@]\+@//g' | sed 's/\.git$//g' | sed 's/github.com:/github.com\//g')
      open "https://$URL/tree/$BRANCH"
    end

    # the pr alias will first check if there are uncommited changes
    # if there are, it'll not try to push the pr
    function pr -a REMOTE_BRANCH
      set -q REMOTE_BRANCH[1]; or set REMOTE_BRANCH master
      set URL (git remote get-url origin | sed 's/^[^@]\+@//g' | sed 's/\.git$//g' | sed 's/github.com:/github.com\//g')
      if test -z (git status --porcelain)
        open "https://$URL/compare/$REMOTE_BRANCH...$USER:"(git branch --show-current)"?expand=1"
      else
        git status
        echo "git status shows uncommitted changes."
      end
    end

    # make sure that the `java` I want is used by default and it is on the path
    # echo "Path before change: $PATH"
    export PATH="$JAVA_HOME/bin:$PATH"
  '';
  bashExecutableWithFHSDefaultPath = pkgs.writeTextFile {
    name = "bash-with-fhs-default-path";
    text = ''
      #! ${pkgs.bashInteractive}/bin/bash

      . /etc/profile
      # DEFAULT_FHS_PATH='/usr/sbin:/usr/bin:/sbin:/bin'
      # export PATH="$PATH:$DEFAULT_FHS_PATH"

      ${pkgs.bashInteractive}/bin/bash "$@"
    '';
    executable = true;
  };
  # https://nixos.wiki/wiki/Wrappers_vs._Dotfiles
  # https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
  bashRcPkg = pkgs.runCommand "bashWithFHSDefaultPath" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
      mkdir -p $out
      ln -s ${pkgs.bashInteractive}/* $out
      rm $out/bin
      mkdir $out/bin
      ln -s ${pkgs.bashInteractive}/bin/* $out/bin
      mv $out/bin/bash $out/bin/bash-original
      # makeWrapper ${pkgs.bashInteractive}/bin/bash $out/bin/bash --set-default PATH '/usr/sbin:/usr/bin:/sbin:/bin'
      cp ${bashExecutableWithFHSDefaultPath} $out/bin/bash
      chmod +x $out/bin/bash
    '';
  bashRcHiPrio = lib.hiPrio bashRcPkg;
in
with pkgs; (buildFHSUserEnv {
  name = "es-dev-fhs-shell";
  targetPkgs = pkgs: with pkgs; [
    coreutils
    bashInteractive
    bashRcHiPrio
    jetbrains.idea-community
    openssl
    zlib
    gcc
    glibc
    ncurses
  ];
  multiPkgs = pkgs: with pkgs; [  ];
  /*
  runScript = "bash";
  profile = ''
    export JAVA11_HOME='/home/palesz/.java/jdk-11.0.8+10'
    export JAVA14_HOME='/home/palesz/.java/jdk-14.0.2+12'
    export JAVA_HOME=$JAVA14_HOME

    # make sure that the `java` I want is used by default and it is on the path
    # echo "Path before change: $PATH"
    export PATH="$JAVA_HOME/bin:$PATH"
  '';*/
  runScript = writeScript "runScript" ''
    #! ${stdenv.shell}

    source /etc/profile

    ${pkgs.fish}/bin/fish --init-command='source "${customFishShellInit}"'
  '';
}).env

/*
learnings:
- the Gradle Daemon survives between nix-shell sessions. Make sure that you kill the gradle daemon (ps -ef | grep gradle) in case you changed the path or the configuration
- for me idea was running a previous version of the shell, and it kept starting up a daemon with the previous path in the background that the new shell utilized. This caused a bunch of headscratches.
*/

