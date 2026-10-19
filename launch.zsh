# launch: bump the version in pyproject.toml, commit, tag and push. Needs bump.zsh.

# launch <patch|candidate|release|minor|major>   (no argument: print the modes)
# launchf                                         (pick the mode with fzf, like acc)
_launch_modes() {
  cat <<'EOF'
patch      bump            2.0.136   -> 2.0.137
candidate  bump-candidate  2.1.0     -> 2.1.0rc1,  2.1.0rc1 -> 2.1.0rc2
release    bump-release    2.1.0rc3  -> 2.1.0  (strip rc suffix)
minor      bump-minor      2.0.136   -> 2.1.0
major      bump-major      2.0.136   -> 3.0.0
EOF
}
# format, stage, commit and push everything pending (same steps as the p alias)
_launch_push() {
  ruff format . && echo "✓ Ran ruff format" && git add . && echo "✓ Files staged" \
    && git status && git commit -m "gall" && git push
}
launch() {
  local mode="$1"
  if [[ -z "$mode" ]]; then
    echo "usage: launch <mode>   (launchf picks one with fzf)"
    _launch_modes
    return 1
  fi
  local cmd
  case "$mode" in
    patch)     cmd=bump           ;;
    candidate) cmd=bump-candidate ;;
    release)   cmd=bump-release   ;;
    minor)     cmd=bump-minor     ;;
    major)     cmd=bump-major     ;;
    *)         echo "launch: unknown mode '$mode'"
               _launch_modes
               return 1          ;;
  esac
  _launch_push || return 1
  "$cmd" || return 1
  _launch_push || return 1
  tag="$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')"
  git tag "$tag" && echo "tagged $tag"
  git push --tags && echo "pushed $tag to remote"
}
launchf() {
  local mode
  mode=$(_launch_modes | fzf --prompt="Mode: " | awk '{print $1}')
  [[ -n "$mode" ]] && launch "$mode"
}
