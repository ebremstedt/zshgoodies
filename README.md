# zshgoodies

Shell functions I keep out of my zshrc, one file per topic.

| File | What |
|---|---|
| `bump.zsh` | `bump`, `bump-candidate`, `bump-release`, `bump-minor`, `bump-major`: edit the version in `pyproject.toml` |
| `launch.zsh` | `launch <mode> [message]`: bump the version, one commit "`<message>; <version>`", tag, one atomic push. `launchf` picks the mode with fzf |
| `clone.zsh` | `clone <github-url\|org/repo>`: clone into `~/github/<owner>/<repo>` and cd there, via the `github-<owner>` ssh host when `~/.ssh/config` has one |
| `oc.zsh` | `oclogin <cluster>`: `oc login --web` to a cluster from `OC_CLUSTERS`. `ocl` picks the cluster with fzf. `proj [project]`: switch oc project, with tab-completion |
| `kube.zsh` | `kex <pod>`: bash into a pod. `zex <pod> [path]`: zsh into a pod |
| `servers.zsh` | one ssh command per entry in `SSH_SERVERS`, e.g. `mini`. `sv` picks a server with fzf |
| `accio.zsh` | `accio <secret> [namespace]`: print a Kubernetes secret decoded. `acc` picks the secret with fzf |
| `note.zsh` | `note [project] [topic] [[ext]]`: dated note in `~/Documents/notes`, symlinked under its project, opened in Sublime |
| `shortcuts.zsh` | short aliases. `zshrc` opens this folder and `~/.zshrc` in VS Code, `reload` re-sources the zshrc |
| `init.zsh` | sources the local file, then every other `*.zsh` here |
| `local.example.zsh` | template for the local file, placeholders only |

## Local values

Addresses and hosts are not in this repo. They live in
`~/.config/zshgoodies/local.zsh` (override with `ZSHGOODIES_LOCAL`), which
`init.zsh` sources first. Copy `local.example.zsh` there and fill it in; a
filled-in `local.zsh` inside the repo is ignored by git either way.

## Install

```sh
git clone git@github.com:ebremstedt/zshgoodies.git ~/github/ebremstedt/zshgoodies
echo 'source "$HOME/github/ebremstedt/zshgoodies/init.zsh"' >> ~/.zshrc
```

Put the `source` line after oh-my-zsh (or after `compinit`), so the tab-completion
for `proj` can register.

Needs git and ruff. `launchf` also needs fzf. Works on macOS and Linux.

## launch

```
launch                      print the full usage
launch patch [message]      2.0.136   -> 2.0.137
launch candidate [message]  2.0.136   -> 2.0.137rc1 (2.0.136 is tagged),  2.1.0rc1 -> 2.1.0rc2
                            2.1.0     -> 2.1.0rc1   (set by hand, not tagged yet)
launch release [message]    2.1.0rc3  -> 2.1.0     (strip rc suffix)
launch minor [message]      2.0.136   -> 2.1.0
launch major [message]      2.0.136   -> 3.0.0
launchf [message]           pick a mode with fzf
```

In order: `ruff format .`, list pending work (untracked files too) and ask
"What changed:" if no message was given, bump the version, make one commit
named `<message>; <new version>` (just `<new version>` on a clean tree), tag
it, and push branch and tag in one atomic `git push`. On a clean tree
`launch patch` works as is; nothing has to be edited first.

```
launch patch "SourceSftp: fetch over SFTP"   -> commit "SourceSftp: fetch over SFTP; 3.1.5", tag 3.1.5
launch patch                                 -> commit "3.1.5", tag 3.1.5
```

`candidate` on a version that is already tagged makes a candidate for the next
patch, so 3.1.4 gives 3.1.5rc1. For a minor or major candidate, set the version
by hand first: with `version = "3.2.0"` untagged, `launch candidate` gives
3.2.0rc1, and `launch release` later gives 3.2.0.

Nothing is committed or pushed when the mode is unknown, there is no
`pyproject.toml`, the version is a candidate but the mode is not `candidate`
or `release`, `ruff format` fails, or the new tag already exists.
