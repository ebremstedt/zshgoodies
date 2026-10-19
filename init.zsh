# Source every *.zsh file next to this one, in name order. One line in ~/.zshrc:
#   source "$HOME/github/ebremstedt/zshgoodies/init.zsh"
#
# Machine-local values (addresses, hosts) live outside the repo in
# ZSHGOODIES_LOCAL, default ~/.config/zshgoodies/local.zsh, sourced first so
# the files here can use them. See local.example.zsh for what to put there.
local _zshgoodies_dir="${0:A:h}"
export ZSHGOODIES_DIR="$_zshgoodies_dir"
export ZSHGOODIES_LOCAL="${ZSHGOODIES_LOCAL:-$HOME/.config/zshgoodies/local.zsh}"
[[ -f "$ZSHGOODIES_LOCAL" ]] && source "$ZSHGOODIES_LOCAL"
for _f in "$_zshgoodies_dir"/*.zsh; do
  case "${_f:t}" in init.zsh|local.example.zsh|*.local.zsh) continue ;; esac
  source "$_f"
done
unset _f _zshgoodies_dir
