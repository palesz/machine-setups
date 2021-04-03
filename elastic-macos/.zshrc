source ~/.nix-profile/etc/profile.d/nix.sh

# Use fish instead of zsh
if [[ ! -o norcs ]]; then
    if [[ -o interactive ]]; then
        exec fish
    fi
fi

