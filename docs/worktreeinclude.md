# Worktree includes

The global `post-checkout` hook links matching untracked files from the main
worktree into linked worktrees. It runs after `git worktree add` and checkouts in
linked worktrees. Existing destination files, directories, and symlinks are
preserved. Paths beneath existing symlinked directories are skipped.

Create `.worktreeinclude` in a repository's main worktree:

```gitignore
.env
.env.local
.env.*.local
apps/*/.env
apps/*/.env.local
```

Patterns use Git's ignore syntax, including comments, directory patterns, and
`!` negation. The hook uses `git ls-files --others --ignored --exclude-from`
with only `.worktreeinclude` as the pattern source, so matching files can be
either normally ignored or untracked. Tracked files are excluded. There is no
output when running in the main worktree, without `.worktreeinclude`, or without
matches. Symlinks point to absolute paths in the main worktree, so edits through
them change the original files.

## Install

From this chezmoi source directory:

```sh
chezmoi apply "$HOME/.config/git" "$HOME/.gitconfig"
```

Chezmoi creates the hooks directory, installs the hook as executable, and sets
`core.hooksPath` through the managed Git config. Bash and Git with support for
`rev-parse --path-format=absolute` and `worktree list --porcelain -z` are required.
Repository-local `core.hooksPath` settings take precedence over this global setting.

Equivalent manual installation from the source directory:

```sh
mkdir -p "$HOME/.config/git/hooks"
install -m 755 dot_config/git/hooks/executable_post-checkout \
  "$HOME/.config/git/hooks/post-checkout"
git config --global core.hooksPath '~/.config/git/hooks'
```

## Test

```sh
bash tests/worktreeinclude.sh
```

The test installs the hook in a temporary home and creates temporary repositories.
It checks automatic linking on worktree creation, nested paths, spaces and other
unusual filename characters, Git pattern negation, preservation of existing
destinations, and silent no-op cases. It also checks that the main worktree's
files and contents remain unchanged. Temporary files are removed on exit.
