# zshgoodies

Shell functions I keep out of my zshrc, one file per topic.

| File | What |
|---|---|
| `bump.zsh` | `bump`, `bump-candidate`, `bump-release`, `bump-minor`, `bump-major`: edit the version in `pyproject.toml` |
| `launch.zsh` | `launch <mode>`: commit and push, bump, commit and push, tag, push tags. `launchf` picks the mode with fzf |
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
launch            print the modes
launch patch      2.0.136   -> 2.0.137
launch candidate  2.1.0     -> 2.1.0rc1,  2.1.0rc1 -> 2.1.0rc2
launch release    2.1.0rc3  -> 2.1.0     (strip rc suffix)
launch minor      2.0.136   -> 2.1.0
launch major      2.0.136   -> 3.0.0
launchf           pick a mode with fzf
```

Every run commits as "gall" and pushes before and after the bump, then tags
the new version and pushes the tag. An unknown mode stops before anything is
pushed.
