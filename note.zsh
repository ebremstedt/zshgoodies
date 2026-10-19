# note [project] [topic] [[ext]]: create a dated note in ~/Documents/notes, symlink it under projects/<project>/ and open it in Sublime.

function note() {
  # Optional trailing [ext] picks the file type, e.g. `note myapp auth [sql]`
  local ext="md"
  if [[ $# -gt 0 && "${@[-1]}" == \[*\] ]]; then
    ext="${@[-1]}"
    ext="${ext#\[}"
    ext="${ext%\]}"
    ext="${ext#.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    [[ -z "$ext" ]] && ext="md"
    set -- "${@[1,-2]}"
  fi

  if [ -z "$1" ]; then
    echo "Usage: note [project] [topic] [[ext]]"
    echo "  Creates:  YYYYMMDD_project_topic.md in ~/Documents/notes"
    echo "  Symlinks: into ~/Documents/notes/projects/project/"
    echo "  Example:  note myapp auth → 20260414_myapp_auth.md"
    echo "  Example:  note myapp auth [sql] → 20260414_myapp_auth.sql"
    return
  fi

  local project="$1"
  local topic="${2:-untitled}"
  local project_slug=$(echo "$project" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
  local topic_slug=$(echo "$topic" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
  local project_upper=$(echo "$project" | tr '[:lower:]' '[:upper:]')
  local date_tag=$(date +"%Y%m%d")

  local notes_dir="${NOTES_DIR:-$HOME/Documents/notes}"
  local project_dir="$notes_dir/projects/$project_slug"
  local filename="${date_tag}_${project_slug}_${topic_slug}.${ext}"

  mkdir -p "$notes_dir" "$project_dir"
  if [[ -e "$notes_dir/$filename" ]]; then
    echo "Exists:  $notes_dir/$filename"
  else
    printf "[[%s]]\n[[%s]]\n[[%s]]\n" "$project_upper" "$topic" "$date_tag" > "$notes_dir/$filename"
    echo "Created: $notes_dir/$filename"
  fi
  # Relative symlink into the project folder, so it survives the notes folder moving
  ln -sf "../../$filename" "$project_dir/$filename"
  echo "Linked:  $project_dir/$filename"
  # Pass the folder too so Sublime shows it in the sidebar with the new file open
  open -a "Sublime Text" "$notes_dir" "$notes_dir/$filename"
}
alias note='noglob note'  # so [sql] isn't treated as a glob pattern
