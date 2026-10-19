# Version bump helpers for a pyproject.toml. Used by launch.zsh.

# write the new version into pyproject.toml; -i.bak works with both BSD (macOS) and GNU sed
_set_version() {
  sed -i.bak "s/version = \"$1\"/version = \"$2\"/" pyproject.toml && rm -f pyproject.toml.bak
}
bump() {
  version=$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')
  new_version="${version%.*}.$((${version##*.} + 1))"
  _set_version "$version" "$new_version"
  echo "bumped $version -> $new_version"
}

bump-candidate() {
  version=$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')
  if [[ "$version" =~ rc[0-9]+$ ]]; then
    new_version="${version%rc*}rc$((${version##*rc} + 1))"
  else
    new_version="${version}rc1"
  fi
  _set_version "$version" "$new_version"
  echo "bumped $version -> $new_version"
}

bump-release() {
  version=$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')
  if [[ "$version" =~ rc[0-9]+$ ]]; then
    new_version="${version%rc*}"
    _set_version "$version" "$new_version"
    echo "promoted $version -> $new_version"
  else
    echo "no rc suffix on $version; nothing to promote"; return 1
  fi
}

bump-minor() {
  version=$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')
  major="${version%%.*}"; rest="${version#*.}"; minor="${rest%%.*}"
  new_version="${major}.$((minor + 1)).0"
  _set_version "$version" "$new_version"
  echo "bumped $version -> $new_version"
}

bump-major() {
  version=$(grep -m1 "^version" pyproject.toml | awk -F'"' '{print $2}')
  new_version="$((${version%%.*} + 1)).0.0"
  _set_version "$version" "$new_version"
  echo "bumped $version -> $new_version"
}
