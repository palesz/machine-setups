
# automatically start the nix-shell in case we find
# shell.nix anywhere in the parent directories during cwd()
# function start-nix-shell --on-variable PWD
#   if test -z "$IN_NIX_SHELL"
#     set d "$PWD"
#     while test "$d" != "/"
#       if test -e "$d/shell.nix"
#         echo "Starting Nix shell defined in $d/shell.nix"
#         nix-shell "$d/shell.nix"
#         return
#       end
#       set d (dirname $d)
#     end
#   end
# end

function isn
  if test -z "$IN_NIX_SHELL"
    echo "no"
  else
    echo "yes"
  end
end

# Serve the current directory on the HTTP port 8000 automatically
function serve
  python -m http.server 8000
end

# C-x C-e will open the $VISUAL or $EDITOR to edit the command line
bind \cx\ce edit_command_buffer
