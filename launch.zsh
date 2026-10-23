# launch: commit pending work, bump the version in pyproject.toml, tag, push. Needs bump.zsh.
#
# launch <patch|candidate|release|minor|major> [message]
#   One commit, "<message>; <new version>" (just "<new version>" on a clean
#   tree), then one atomic push of the branch and the new tag.
# launchf [message]   pick the mode with fzf
_launch_modes() {
  cat <<'EOF'
patch      2.0.136   -> 2.0.137
candidate  2.0.136   -> 2.0.137rc1 (2.0.136 is tagged),  2.1.0 -> 2.1.0rc1 (hand-edited, not tagged),  2.1.0rc1 -> 2.1.0rc2
release    2.1.0rc3  -> 2.1.0  (strip rc suffix)
minor      2.0.136   -> 2.1.0
major      2.0.136   -> 3.0.0
EOF
}
_launch_usage() {
  cat <<'EOF'
launch: commit pending work, bump the version in pyproject.toml, tag and push.

usage: launch <mode> [message]
       launchf [message]          pick the mode with fzf

modes:
EOF
  _launch_modes | sed 's/^/  /'
  cat <<'EOF'

what happens, in order:
  1. ruff format .
  2. pending work is listed (untracked files too); with no message you are asked "What changed:"
  3. the version is bumped
  4. one commit: "<message>; <new version>", or just "<new version>" on a clean tree
  5. tag <new version>, then one atomic push of the branch and the tag

examples:
  launch patch "SourceSftp: fetch over SFTP"   commit "SourceSftp: fetch over SFTP; 3.1.5", tag 3.1.5
  launch patch                                 clean tree: commit "3.1.5", tag 3.1.5
  launch minor "bulk fetch"                    commit "bulk fetch; 3.2.0", tag 3.2.0
  launch candidate "try sftp"                  3.1.4 is tagged: commit "try sftp; 3.1.5rc1", tag 3.1.5rc1
                                               for 3.2.0rc1 set version = "3.2.0" by hand first

stops before anything is committed or pushed when:
  the mode is unknown, there is no pyproject.toml, the version is a candidate but the
  mode is not candidate/release, ruff format fails, or the new tag already exists.
EOF
}
_launch_version() { grep -m1 '^version = ' pyproject.toml | awk -F'"' '{print $2}'; }
launch() {
  local mode="$1" msg="$2" cmd old new
  if [[ -z "$mode" ]]; then
    _launch_usage; return 1
  fi
  case "$mode" in
    patch)     cmd=bump           ;;
    candidate) cmd=bump-candidate ;;
    release)   cmd=bump-release   ;;
    minor)     cmd=bump-minor     ;;
    major)     cmd=bump-major     ;;
    *) echo "launch: unknown mode '$mode'"; _launch_modes; return 1 ;;
  esac
  [[ -f pyproject.toml ]] || { echo "launch: no pyproject.toml here"; return 1; }

  old="$(_launch_version)"
  if [[ "$old" == *rc* && "$mode" != (candidate|release) ]]; then
    echo "launch: $old is a candidate; use candidate or release"; return 1
  fi

  ruff format . && echo "✓ Ran ruff format" || return 1

  # pending work (untracked files too) is shown and needs a message
  if [[ -n "$(git status --porcelain)" ]]; then
    git status --short
    if [[ -z "$msg" ]]; then
      read "msg?What changed: "
      [[ -n "$msg" ]] || { echo "launch: stopped, nothing committed"; return 1; }
    fi
  fi

  # candidate on a version that is already out: a candidate for the next patch, 3.1.4 -> 3.1.5rc1
  if [[ "$mode" == candidate && "$old" != *rc* ]] && git rev-parse -q --verify "refs/tags/$old" >/dev/null; then
    bump || return 1
  fi
  "$cmd" || return 1
  new="$(_launch_version)"
  if [[ -z "$new" || "$new" == "$old" ]]; then
    echo "launch: version did not change ($old)"; return 1
  fi
  if git rev-parse -q --verify "refs/tags/$new" >/dev/null; then
    echo "launch: tag $new already exists"; _set_version "$new" "$old"; return 1
  fi

  git add -A && git commit -m "${msg:+$msg; }$new" || return 1
  git tag "$new" || return 1
  if git push --atomic -u origin HEAD "$new"; then
    echo "pushed $(git branch --show-current) and tag $new"
  else
    echo "launch: push failed; commit and tag $new are local, retry with:"
    echo "  git push --atomic -u origin HEAD $new"
    return 1
  fi
}
launchf() {
  local mode
  mode=$(_launch_modes | fzf --prompt="Mode: " | awk '{print $1}')
  [[ -n "$mode" ]] && launch "$mode" "$1"
}
