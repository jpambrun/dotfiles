# Global agent guidance

## Version control

- The user uses GitLab.
- If asked to create or manage a merge request, prefer the `glab` CLI.
- When proposing a new branch name, prefer the `jpambrun/...` prefix unless the user asks otherwise.

## GitButler awareness

When working in a git repository, especially for git-related requests, first check the current branch.

- If the current branch is `gitbutler/workspace`, assume the user is using GitButler alongside git.
- In that case, avoid advice that casually treats `gitbutler/workspace` like a normal feature branch.
- Prefer checking or managing GitButler state with `but` instead of relying only on raw git commands when it helps.
- Prefer explanations and commands that are safe with GitButler's workspace model.
- Be careful with operations that may disrupt GitButler state, including branch switching, rebasing, resetting, force-pushing, deleting branches, or rewriting history.
- Before suggesting a potentially disruptive git command in this situation, briefly mention the GitButler context and consider whether there is a safer `but`-based workflow first. Ask for confirmation if the operation could interfere with the user's workflow.
- If proposing a new GitButler virtual branch, stack branch, or regular git branch, default to the `jpambrun/...` prefix.
- If a git task depends on branch context, inspect both git state and, when relevant, GitButler state first instead of assuming a standard git branch workflow.

## Jira / JTK

- Use the `$jtk-jira` skill for Jira searches, ticket creation, updates, assignment, workflow transitions, comments, and issue links.
- `VW` is for product/application code work in the EmpowerSuite repository.
- `IN` is for infrastructure and Terraform work in the Infra repository.
- Do not create `IN` issues for EmpowerSuite application code changes just because the symptom involves AWS, ECS, CloudWatch, deployment, or NATS. Use `VW` unless the requested work changes infrastructure/Terraform or belongs in the Infra repository.
