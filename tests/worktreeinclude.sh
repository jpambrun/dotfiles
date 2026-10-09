#!/bin/bash
set -euo pipefail

source_dir=$(cd -- "$(dirname -- "$0")/.." && pwd)
temporary=$(mktemp -d)
temporary=$(cd "$temporary" && pwd -P)
trap 'rm -rf -- "$temporary"' EXIT

# Keep the test independent of the caller's repositories and Git configuration.
while IFS= read -r variable; do
    unset "$variable"
done < <(git rev-parse --local-env-vars)
export HOME="$temporary/home"
export XDG_CONFIG_HOME="$HOME/.config"
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
export GIT_CONFIG_COUNT=0
unset GIT_CONFIG_PARAMETERS
mkdir -p "$HOME/.config/git/hooks"
install -m 755 "$source_dir/dot_config/git/hooks/executable_post-checkout" \
    "$HOME/.config/git/hooks/post-checkout"
git config --global core.hooksPath '~/.config/git/hooks'
git config --global user.name 'Hook test'
git config --global user.email 'hook-test@example.invalid'
git config --global commit.gpgSign false

main="$temporary/main repo"
linked="$temporary/linked worktree"
git init -q "$main"
cd "$main"
cat > .worktreeinclude <<'PATTERNS'
# Root files and nested env files
.env
.env.*
!.env.excluded
apps/*/.env
config with spaces/*.env
odd/*
shared/
tracked.env
PATTERNS
printf '.env*\napps/*/.env\n' > .gitignore
printf 'tracked\n' > tracked.env
git add .gitignore .worktreeinclude tracked.env
git commit -qm 'Initial files'
mkdir -p 'apps/web' 'config with spaces' odd shared
files=(.env .env.local 'apps/web/.env' 'config with spaces/local config.env' \
    'odd/back\slash' $'odd/line\nbreak' $'odd/tab\tname' 'odd/-leading' shared/settings)
for file in "${files[@]}"; do
    printf 'main content: %s\n' "$file" > "$file"
done
printf 'excluded\n' > .env.excluded
printf 'unmatched\n' > unrelated

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_link() {
    [[ -L "$linked/$1" ]] || fail "missing link: $1"
    [[ "$(readlink "$linked/$1")" == "$main/$1" ]] || fail "wrong target: $1"
}
run_hook() {
    (cd "$1" && "$HOME/.config/git/hooks/post-checkout" HEAD HEAD 1)
}

# Snapshot everything outside Git's metadata, including names and file contents.
mkdir "$temporary/main snapshot"
cp -R "$main/." "$temporary/main snapshot/"
git worktree add -q --detach "$linked"
for file in "${files[@]}"; do assert_link "$file"; done
[[ ! -e "$linked/.env.excluded" ]] || fail 'negated pattern was included'
[[ ! -e "$linked/unrelated" ]] || fail 'unmatched file was included'
[[ -f "$linked/tracked.env" && ! -L "$linked/tracked.env" ]] || fail 'tracked file was linked'

# Repeat via an actual checkout with existing files, directories, dangling links,
# and parent symlinks. None may be replaced or followed.
rm "$linked/.env" "$linked/.env.local" "$linked/apps/web/.env"
printf 'keep me\n' > "$linked/.env"
mkdir "$linked/.env.local"
ln -s missing-target "$linked/apps/web/.env"
rm "$linked/shared/settings"
rmdir "$linked/shared"
ln -s "$main/shared" "$linked/shared"
printf 'new shared file\n' > "$main/shared/new"
cp "$main/shared/new" "$temporary/main snapshot/shared/new"
git -C "$linked" checkout -q --detach HEAD
[[ "$(cat "$linked/.env")" == 'keep me' && ! -L "$linked/.env" ]] || fail 'existing file changed'
[[ -d "$linked/.env.local" && ! -L "$linked/.env.local" ]] || fail 'existing directory changed'
[[ "$(readlink "$linked/apps/web/.env")" == missing-target ]] || fail 'existing symlink changed'
[[ "$(readlink "$linked/shared")" == "$main/shared" ]] || fail 'parent symlink changed'

[[ -z "$(run_hook "$main" 2>&1)" ]] || fail 'main worktree hook was not silent'
diff -r --exclude=.git "$temporary/main snapshot" "$main"

# Missing and empty pattern files must do nothing, silently.
mv "$main/.worktreeinclude" "$temporary/patterns"
[[ -z "$(run_hook "$linked" 2>&1)" ]] || fail 'missing patterns were not silent'
: > "$main/.worktreeinclude"
[[ -z "$(run_hook "$linked" 2>&1)" ]] || fail 'empty patterns were not silent'
printf 'no-such-file\n' > "$main/.worktreeinclude"
[[ -z "$(run_hook "$linked" 2>&1)" ]] || fail 'unmatched patterns were not silent'
mv "$temporary/patterns" "$main/.worktreeinclude"
diff -r --exclude=.git "$temporary/main snapshot" "$main"

printf 'PASS: worktree links, patterns, preserved destinations, and unchanged main worktree\n'
