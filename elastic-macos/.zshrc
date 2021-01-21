source /nix/var/nix/profiles/default/etc/profile.d/nix.sh

export NIX_DEFAULT_PROFILE=/nix/var/nix/profiles/default
export NIX_PATH=$NIX_DEFAULT_PROFILE/bin
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export NIX_PROFILE=/Users/palesz/.nix-profile
export PATH=$NIX_PROFILE/bin:$NIX_PROFILE/sbin:$NIX_PATH:$PATH:$HOME/bin

export EDITOR=emacsclient

export JAVA8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_281.jdk/Contents/Home
export JAVA11_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
export JAVA14_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
export JAVA15_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-15.jdk/Contents/Home
export JAVA_HOME=$JAVA15_HOME
export RUNTIME_JAVA_HOME=$JAVA11_HOME

# Use fish instead of zsh
if [[ ! -o norcs ]]; then
    if [[ -o interactive ]]; then
        exec fish
    fi
fi

