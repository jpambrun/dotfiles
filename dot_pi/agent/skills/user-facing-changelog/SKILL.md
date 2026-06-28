---
name: user-facing-changelog
version: 1.0.0
description: "Create or update a user-facing Confluence changelog from recent commits. Use when asked to write/expand a changelog, inspect recent commits, add Jira links/context, or show which deployments currently sit on each version tag."
author: jpambrun
---

# User-Facing Changelog Skill

Use this skill when the user asks to create, update, or expand a user-facing changelog from git history, especially when publishing to Confluence with `cfl` and enriching entries with Jira via `jtk`.

Default Confluence changelog page: `516685826` (<https://newvue-ai.atlassian.net/wiki/spaces/ES/pages/516685826/Changelog>). Unless the user explicitly gives a different page, update this page.

## Target Output

Prefer this table shape unless the user requests otherwise:

| Commit | Current deployment | Jira link | Title | User-facing description |
|---|---|---|---|---|

Rules:
- `Commit`: short commit hash from `git log`.
- `Current deployment`: deployment name(s) whose Terraform `version_tag` is exactly this commit; otherwise `—`.
- `Jira link`: Markdown Jira links for ticket keys found in the commit title; otherwise `—`.
- `Title`: commit subject exactly enough to be recognizable.
- `User-facing description`: concise, customer-readable description of the behavior change.
- If a commit has no meaningful user-facing impact, write exactly: `Misc bug fix or improvement.`
- Include AI/user AI changes when present; do not bury them under generic wording.

## Workflow

1. **Inspect current state**
   - Check the current repo branch before git-related work.
   - Fetch the existing Confluence page first. Use page `516685826` by default unless the user explicitly gives a different page:
     ```bash
     cfl page view 516685826 --content-only > /tmp/changelog_page.md
     ```
   - If the page already has content, preserve/continue from where it left off unless the user explicitly asks to regenerate or expand. Avoid duplicate commit rows.

2. **Collect commits**
   - Use the requested count, defaulting to the user's stated number:
     ```bash
     git log -<N> --pretty=format:'%h%x09%s' > /tmp/commits.tsv
     ```
   - Use `git show --stat --name-status <hash>` or `git log --stat --name-status` to understand ambiguous commits.
   - Open detailed diffs only when the subject/stat is not enough to produce a user-facing description.

3. **Fetch Jira context with `jtk`**
   - Extract Jira keys from commit titles.
   - Normalize typo/case variants like `Ww-5164` or `WW-3974` to the matching `VW-5164` / `VW-3974` when Jira lookup confirms that is the real key.
   - Batch query Jira when possible:
     ```bash
     jtk issues search --jql "key in (VW-123,VW-456)" --fields Key,Summary,Status,Description --max 100 --fulltext
     ```
   - If a key is missing from search results, try `jtk issues get <KEY> --fields Summary,Status,Description --fulltext` and, for `WW-*`, try the matching `VW-*`.
   - Use Jira Summary/Description to refine the user-facing description, but keep wording concise and non-technical.

4. **Map deployments from infra**
   - Read deployment `version_tag` values from:
     ```text
     $HOME/work/infra/envs/*/*/terraform.tfvars
     ```
   - A practical parser:
     ```bash
     python3 - <<'PY'
     from pathlib import Path
     import re, collections
     root = Path.home() / 'work/infra/envs'
     by = collections.defaultdict(list)
     for f in sorted(root.glob('*/*/terraform.tfvars')):
         text = f.read_text(errors='ignore')
         m = re.search(r'^\s*version_tag\s*=\s*"([0-9a-fA-F]+)"', text, re.M)
         if not m:
             continue
         env, deployment = f.parts[-3], f.parts[-2]
         # dev/dev updates outside Terraform; omit it from the changelog deployment column.
         if env == 'dev' and deployment == 'dev':
             continue
         by[m.group(1)].append(f'{env}/{deployment}')
     for tag, deployments in sorted(by.items()):
         print(tag, ', '.join(deployments))
     PY
     ```
   - If a `version_tag` matches a commit in the changelog window, put the deployment name(s) in that row.
   - If a `version_tag` is outside the changelog window, add a small section after the main table:
     ```markdown
     ### Deployment version tags outside this <N>-commit window

     | Version tag | Current deployments |
     |---|---|
     ```
   - Omit `dev/dev` from deployment reporting because it is updated outside Terraform.

5. **Write the page with `cfl`**
   - Generate a Markdown file and publish it:
     ```bash
     cfl page edit 516685826 --file /tmp/changelog.md
     ```
   - Verify the page after editing:
     ```bash
     cfl page view <page-id> --content-only | head
     ```

## Description Guidance

User-facing descriptions should answer: "What changes for a user/admin/integration/customer?"

Good examples:
- `Adds a user-level permission controlling whether hide-exam actions are visible and available in worklists.`
- `Next Appointment worklist columns now update automatically after department configuration changes.`
- `Fixes duplicate Sectra launches, prevents extra close events during study switches, and records Sectra viewer events in the audit log.`
- `Date and timestamp filters now respect selected calendar dates instead of being off by one day.`

Use `Misc bug fix or improvement.` for:
- Storybook-only refactors
- CI/review-app/build tooling changes
- dependency/audit bumps
- QA automation-only commits
- test-only/typecheck-only changes
- internal logging/diagnostic-only commits unless they directly change user behavior

## Jira Link Generation

For each commit title:
- Extract all keys matching `VW-123`, `WW-123`, or case variants.
- Prefer confirmed `VW-*` links when the commit says `WW-*` but Jira only has the corresponding `VW-*`.
- Multiple keys should be comma-separated links.
- Link format:
  ```markdown
  [VW-123](https://newvue-ai.atlassian.net/browse/VW-123)
  ```

## Safety and Quality Notes

- Do not invent Jira context; use commit diff/stat and `jtk` output.
- Keep changelog wording user-facing and concise; avoid implementation jargon unless it is the product term users know.
- Preserve existing page content unless the user asks to expand/regenerate. When expanding from 50 to 100 commits, regenerating the table is acceptable if it preserves the existing rows and adds the older ones.
- If Confluence conversion escapes underscores or formats the Markdown table, that is acceptable after verifying the content is present.
- No code tests are required when only generating a changelog page.
