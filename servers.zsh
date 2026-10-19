# One command per entry in the SSH_SERVERS map from the local file: an entry
# `mini user@host` gives a `mini` command that runs `ssh [-i $SSH_SERVERS_KEY]
# user@host`, extra arguments passed through. `sv` picks a server with fzf.
# Hosts, users and the key path never live in this repo (see local.example.zsh).

if (( ${#SSH_SERVERS} )); then
  for _name in ${(k)SSH_SERVERS}; do
    functions[$_name]="ssh ${SSH_SERVERS_KEY:+-i ${(q)SSH_SERVERS_KEY}} ${(q)SSH_SERVERS[$_name]} \"\$@\""
  done
  unset _name
fi

sv() {
  if (( ${#SSH_SERVERS} == 0 )); then
    echo "sv: SSH_SERVERS is not set; define it in ${ZSHGOODIES_LOCAL:-~/.config/zshgoodies/local.zsh}" >&2
    return 1
  fi
  local name
  name=$(print -l -- ${(ko)SSH_SERVERS} | fzf --prompt="Server: ")
  [[ -n "$name" ]] && "$name"
}
