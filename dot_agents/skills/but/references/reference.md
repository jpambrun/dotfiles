# GitButler CLI reference

Use this only when the main skill does not cover the task. Copy IDs from `but` output. For exact flags, run `but <command> --help`.

## Inspect state

```bash
but status              # branches, stacks, commits, conflicts
but status -fv          # files and hunk IDs in commits
but diff [target]       # uncommitted changes, or one entity
but show <id>           # one branch or commit
```

`but diff` takes at most one target.

## Branches

```bash
but branch                         # list branches
but branch new <name>              # create an independent branch
but branch new <name> -a <branch>  # create a branch on another branch
but apply <branch>                 # add a branch to the workspace
but unapply <branch>               # remove it from the workspace
but branch delete <branch>         # delete a branch
but pick <source> [target]         # copy a commit or branch's changes
```

Prefer `but commit -b <name>` when creating a branch just to commit current changes.

## Commits and history

```bash
but commit -b <branch> -m "<message>" [<id>...]
but commit --empty -b <branch> -m "<message>"
but amend -t <commit-or-branch> <id> [<id>...]
but uncommit <commit-id>
but reword <commit-id> -m "<message>"
but squash <source>... -t <target> -m "<message>"
but move <commit> --above <commit>
but move <commit> --below <commit>
but move <commit> -b <branch>
but discard <id> [<id>...]
```

Commit IDs and branch IDs are different. `but status` shows commits newest first. Use `--above` to make a commit newer and `--below` to make it older.

## Conflicts

For conflicts created by `pull`, `move`, or another history edit:

```bash
but resolve <commit-id>
# edit files and remove conflict markers
but resolve finish
```

Resolve commits oldest first. Use `but resolve status` to inspect a resolution and `but resolve cancel` to abandon the current resolution.

For an uncommitted file conflict, edit the file and run `git add -- <path>`. This is the only normal Git write command allowed here.

## Remote work

```bash
but pull
but pull --check
but push <branch>
but pr new <branch-id> -m "<title>"
but pr new <top-branch-id> -t
but pr set-draft <selector>
but pr set-ready <selector>
but pr auto-merge <selector>
but land <branch>
```

`but pr new` pushes the branch. Use `-t` to create pull requests for a stack. Avoid bare `but push` in automation because it pushes all branches.

## Recovery and maintenance

```bash
but undo
but redo
but oplog
but oplog restore <snapshot>
but clean
```

Use `but undo` for a mistaken GitButler operation. Do not reach for raw Git rewrites.

## Help

```bash
but <command> --help
but help cli-ids
```

If GitButler asks for an agent skill update, follow its command once. If it keeps asking, stop and report the problem.
