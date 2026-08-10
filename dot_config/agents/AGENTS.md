# Global agent guidance

Follow YAGNI principles, and one-liner solutions.

## Sentry

- `sentry-cli` defaults to the `newvue` organization and `empowersuite` project. Use `sentry-cli issues list` to inspect relevant Sentry issues when diagnosing errors or regressions.

## Version control

- The user uses GitLab.
- If asked to create or manage a merge request, prefer the `glab` CLI.
- When replying to merge request comments, reply to each comment thread individually instead of posting a single combined comment.
- When proposing a new branch name, prefer the `jpambrun/...` prefix unless the user asks otherwise.

## GitButler

For git-related work, first inspect the current branch.

- Use GitButler's `but` CLI only when the current branch is `gitbutler/workspace`.
- Otherwise, use standard Git; do not use GitButler in repositories that are not already using it.
- Never initialize, set up, enable, or configure GitButler, including with `but setup`.
