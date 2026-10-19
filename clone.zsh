# clone <github-url|org/repo>: clone into ~/github/<owner>/<repo> and cd there.
# Uses the ssh host alias github-<owner> from ~/.ssh/config when one exists.

clone() {
  local input="${1:-}"
  if [ -z "$input" ]; then
    echo "usage: clone <github-url|org/repo>" >&2
    return 1
  fi

  local norm="${input%.git}"
  local owner repo dest url host

  owner=$(printf '%s\n' "$norm" | sed -nE 's#.*github(\.com|-[^:/]+)[:/]([^/]+)/([^/]+)$#\2#p')
  repo=$(printf '%s\n' "$norm" | sed -nE 's#.*github(\.com|-[^:/]+)[:/]([^/]+)/([^/]+)$#\3#p')

  if [ -z "$owner" ] || [ -z "$repo" ]; then
    if printf '%s\n' "$norm" | grep -qxE '^[^/@:]+/[^/]+$'; then
      owner="${norm%%/*}"
      repo="${norm#*/}"
    else
      echo "clone: expected github URL or org/repo, got: $input" >&2
      return 1
    fi
  fi

  host="github.com"
  if grep -qE "^[[:space:]]*Host[[:space:]].*\bgithub-${owner}\b" ~/.ssh/config 2>/dev/null; then
    host="github-${owner}"
  fi
  url="git@${host}:${owner}/${repo}.git"

  dest="$HOME/github/$owner/$repo"
  if [ -e "$dest" ]; then
    echo "clone: already exists: $dest" >&2
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  git clone "$url" "$dest" && cd "$dest"
}
