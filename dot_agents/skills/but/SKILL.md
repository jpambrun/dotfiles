---
name: but
version: 0.22.0
description: "Use GitButler CLI for GitButler workspaces: inspect changes, commit, push, update, and make small history edits."
author: GitButler Team
---

# GitButler CLI

Use `but` for version-control writes in a GitButler workspace. Do not use Git write commands (`git add`, `git commit`, `git push`, `git checkout`, `git merge`, `git rebase`, `git stash`, or `git cherry-pick`). Read-only Git commands are fine.

Use the smallest inspection command that answers the question:

```bash
but diff       # uncommitted files and hunk IDs
but status     # branches, commits, conflicts
but status -fv # file and hunk IDs in existing commits
but show <id>  # one known branch or commit
```

Do not run status by habit. Do not verify a successful mutation unless the next step needs its output.

## IDs

Copy IDs from `but` output exactly. Pass them as positional, space-separated arguments.

- A hunk ID is `<file-id>:<hunk-id>`, such as `qs:5`. It is not a line range.
- `zz` means all uncommitted changes.
- `but diff` accepts zero or one target, never several.
- If an ID fails after a history edit, inspect again. Do not guess.

## Common work

Commit selected files or hunks:

```bash
but diff
but commit -b <branch> -m "<message>" <id> <id>
```

`-b` creates the branch when necessary. Omit IDs to commit all uncommitted changes. When the target matters, always specify `-b`, `--above`, or `--below`.

Update from the workspace target:

```bash
but pull
```

Use `but pull --check` only when a preview is needed. If it creates commit conflicts, resolve them oldest first:

```bash
but resolve <commit-id>
# edit files and remove conflict markers
but resolve finish
```

Push one branch:

```bash
but push <branch>
```

Always name the branch. Bare `but push` pushes every branch in a non-interactive shell.

Create a pull request:

```bash
but pr new <branch-id> -m "<title>"
```

This pushes first. For a stack, use `but pr`, not `gh pr create`.

## Small history edits

```bash
but amend -t <commit-or-branch> <file-or-hunk-id>
but uncommit <commit-id>
but squash <source-commit> -t <target-commit> -m "<message>"
but move <commit-id> --below <commit-id>
but discard <id>
```

`but status` lists commits newest first. `--below` moves a commit earlier in history and `--above` moves it later.

To stack a branch on another branch:

```bash
but move <child-branch> --above <parent-branch>
```

To unstack it:

```bash
but move <branch> --unstack
```

## When something fails

Read the error, then use the command it suggests. Otherwise inspect with `but status` or `<command> --help`. Do not work around errors with raw Git commands.

One exception: resolve an uncommitted file conflict by editing it, then run:

```bash
git add -- <path>
```

For uncommon syntax, read `references/reference.md`.
