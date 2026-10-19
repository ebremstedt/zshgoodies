# Short aliases.

alias act='source .venv/bin/activate'
alias dact='deactivate'
alias zshrc='code "$ZSHGOODIES_DIR" "$HOME/.zshrc"'  # the whole zshgoodies folder plus the zshrc
alias reload='source ~/.zshrc'
alias py='python'
alias tl='task list'
alias ta='task add'
alias f='ls -la'
alias temp='function _mktempdir(){ folder_name=$(date +"%d%b_%H%M%S"); mkdir -p ~/temps && mkdir ~/temps/"$folder_name" && cd ~/temps/"$folder_name" && echo "Created: $(pwd)"; }; _mktempdir'
alias temps='cd $HOME/temps/'
alias github='cd $HOME/github'
alias lake='cd $HOME/github/kardapp/rst-vdp-lake'
alias s='subl .'
alias p='ruff format . && echo "✓ Ran ruff format" && git add . && echo "✓ Files staged" && git status && git commit -m "gall" && git push'
alias rc='ruff check .'
alias rf='ruff format .'
alias pop='open -a Terminal .'
