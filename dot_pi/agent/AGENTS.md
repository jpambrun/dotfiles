# Global agent guidance

Follow YAGNI principles, and one-liner solutions.

## Shell preference

The user primarily uses Nushell (`nu`).
- When giving commands to the user, write them in Nushell syntax.
- When running commands yourself, prefer Nushell-compatible syntax where practical.

## Version control

- The user uses GitLab.
- If asked to create or manage a merge request, prefer the `glab` CLI.
- When proposing a new branch name, prefer the `jpambrun/...` prefix unless the user asks otherwise.

## GitButler awareness

When working in a git repository, especially for git-related requests, first check the current branch.

- If the current branch is `gitbutler/workspace`, assume the user is using GitButler alongside git.
- In that case, avoid advice that casually treats `gitbutler/workspace` like a normal feature branch.
- Prefer checking or managing GitButler state with `but` instead of relying only on raw git commands when it helps.

