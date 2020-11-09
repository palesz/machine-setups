function start-nix-shell --on-variable PWD
  if test -z "$IN_NIX_SHELL"
    set d "$PWD"
    while test "$d" != "/"
      if test -e "$d/shell.nix"
        echo "Starting Nix shell defined in $d/shell.nix"
        nix-shell "$d/shell.nix"
        return
      end
      set d (dirname $d)
    end
  end
end

function isn
  if test -z "$IN_NIX_SHELL"
    echo "no"
  else
    echo "yes"
  end
end
