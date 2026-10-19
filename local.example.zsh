# Machine-local values that must not be checked in. Copy this file to
# ~/.config/zshgoodies/local.zsh (or wherever ZSHGOODIES_LOCAL points) and fill
# it in. init.zsh sources it before the other files.

# oc.zsh: cluster name -> API server, used by oclogin and ocl.
typeset -gA OC_CLUSTERS=(
  prod  https://api.example.com:6443
  test  https://api.test.example.com:6443
  dev   https://api.dev.example.com:6443
)

# servers.zsh: command name -> user@host. Each name becomes an ssh command;
# SSH_SERVERS_KEY (optional) is passed as -i.
typeset -gA SSH_SERVERS=(
  mini user@mini.example.com
  big  user@big.example.com
)
SSH_SERVERS_KEY=~/.ssh/id_rsa

# note.zsh: where notes go. Optional, default ~/Documents/notes.
NOTES_DIR=~/Documents/notes
