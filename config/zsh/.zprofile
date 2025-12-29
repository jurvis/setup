# Login shell environment.
typeset -U path PATH

path_prepend() {
  [[ -d "$1" ]] || return 0
  path=("$1" "${path[@]}")
}

path_prepend "/opt/homebrew/bin"
path_prepend "/opt/homebrew/sbin"

export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export TART_INSTALL="/Applications/tart.app"

path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/bin"
path_prepend "/opt/homebrew/opt/python@3.11/libexec/bin"
path_prepend "$GOPATH/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
path_prepend "$TART_INSTALL/Contents/MacOS"
path_prepend "/opt/homebrew/opt/sqlite/bin"

unset -f path_prepend
