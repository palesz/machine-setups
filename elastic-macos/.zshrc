export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export PATH=$NIX_PATH:$PATH:$HOME/bin
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-14.0.2.jdk/Contents/Home
export JAVA14_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home
export RUNTIME_JAVA_HOME=$JAVA14_HOME

# aliases
alias gpc=./gradlew precommit
alias esv=es-versions.sh
alias pp='git push palesz `git branch --show-current`:`git branch --show-current`'
alias pf='git push --force palesz `git branch --show-current`:`git branch --show-current`'

# the pr alias will first check if there are uncommited changes
# if there are, it'll not try to push the pr
alias pr='( [[ -z `git status --porcelain` ]] && open "https://github.com/elastic/elasticsearch/compare/master...palesz:`git branch --show-current`?expand=1" ) || ( git status ; echo "git status shows uncommitted changes." ) '

