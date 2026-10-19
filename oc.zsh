# oclogin <cluster> / ocl: oc login --web to a cluster. The cluster names and
# API addresses come from the OC_CLUSTERS map in the local file (see
# local.example.zsh), never from this repo.

_oc_clusters_ok() {
  if (( ${#OC_CLUSTERS} == 0 )); then
    echo "oc: OC_CLUSTERS is not set; define it in ${ZSHGOODIES_LOCAL:-~/.config/zshgoodies/local.zsh}" >&2
    return 1
  fi
}

oclogin() {
  _oc_clusters_ok || return 1
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "usage: oclogin <cluster>   (ocl picks one with fzf)"
    print -l -- ${(ko)OC_CLUSTERS}
    return 1
  fi
  local server="${OC_CLUSTERS[$name]}"
  if [[ -z "$server" ]]; then
    echo "oclogin: unknown cluster '$name'" >&2
    print -l -- ${(ko)OC_CLUSTERS}
    return 1
  fi
  oc login --web --server="$server"
}

ocl() {
  _oc_clusters_ok || return 1
  local name
  name=$(print -l -- ${(ko)OC_CLUSTERS} | fzf --prompt="Cluster: ")
  [[ -n "$name" ]] && oclogin "$name"
}

# switch oc project; no arg -> usage + fzf picker over your projects
# usage: proj [project]
proj() {
  local usage="Usage: proj [project]   (no argument -> pick from list)"
  if (( $# > 1 )); then
    echo "$usage" >&2
    return 1
  fi
  local p=$1
  if [[ -z "$p" ]]; then
    echo "$usage"
    p=$(oc projects -q | fzf --prompt="Project: ") || return
  fi
  oc project "$p" || { echo "$usage" >&2; return 1; }
}

# tab-completion for proj: needs compinit, so init.zsh must be sourced after oh-my-zsh
_proj() { compadd -- ${(f)"$(oc projects -q 2>/dev/null)"}; }
(( $+functions[compdef] )) && compdef _proj proj
