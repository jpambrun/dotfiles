# Global agent guidance

Follow YAGNI principles, and one-liner solutions.

## Sentry

- `sentry-cli` defaults to the `newvue` organization and `empowersuite` project. Use `sentry-cli issues list` to inspect relevant Sentry issues when diagnosing errors or regressions.

## Version control

- The user uses GitLab.
- If asked to create or manage a merge request, prefer the `glab` CLI.
- When replying to merge request comments, reply to each comment thread individually instead of posting a single combined comment.
- When proposing a new branch name, prefer the `jpambrun/...` prefix unless the user asks otherwise.

## GitButler awareness

When working in a git repository, especially for git-related requests, first check the current branch.

- If the current branch is `gitbutler/workspace`, assume the user is using GitButler alongside git.
- In that case, avoid advice that casually treats `gitbutler/workspace` like a normal feature branch.
- Prefer checking or managing GitButler state with `but` instead of relying only on raw git commands when it helps.

