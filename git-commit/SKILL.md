---
name: git-commit
description: Git commit, push, and PR merge workflow for LibOps repositories. Use when Codex is asked to create, amend, push, or merge commits or PRs, especially when using a GHAT-provided identity or credentials, selecting release bump markers such as [minor], avoiding Co-authored-by trailers, preserving repository Git configuration and existing remotes, or preparing GitHub commit messages.
---

# Git Commit

## Commit Rules

- Stage only intentional changes. Preserve unrelated dirty files and untracked local notes.
- For a new feature, include `[minor]` in the commit subject so release automation performs a minor bump.
  - Example: `[minor] Add assistant dev-mode support`
- Keep commit messages focused:
  - First line: overview/subject.
  - Optional second paragraph: at most one concise summary paragraph.
  - Optional `More Info` header with a short breakdown when more detail is useful.
- Do not include `Tests` or `Validation` sections, transcripts, or checklists in a GitHub commit message or squash merge message. Let CI run tests, then check CI status.
- Do not include `Co-authored-by:` trailers unless the user explicitly asks for them.
- Treat persistent Git identity and remote configuration as user-owned state. Never write `user.name` or `user.email` with `git config` at local, global, or system scope. Never edit `.git/config` directly.
- Do not alter the commit author or committer by default. Use the existing Git identity unless the user explicitly provides a GHAT or asks for a specific identity. If Git reports that identity is missing, stop and ask the user to configure it; do not configure it for them.
- Supply an explicitly requested identity only for the individual commit command. Keep the resolved name and email in shell variables; never splice API-returned text into shell source. Set `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, and `GIT_COMMITTER_EMAIL` from those quoted variables in that command's environment. Use `--reset-author` when amending. These are transient commit metadata and do not write `user.*` configuration.
- When the user provides a GHAT, resolve the GitHub identity from that token and use that identity for both author and committer:
  - Query the token owner with `GH_TOKEN="$GHAT" gh api user`, or call `https://api.github.com/user` with `Authorization: Bearer <GHAT>`. Never run `gh auth login` or switch the persistent `gh` account.
  - Resolve the commit name from the returned `name` field. If `name` is empty, ask the user what name to use.
  - Resolve the commit email from the returned `email` field or from `GET /user/emails` if the token has email scope. If no email is available, use the GitHub noreply email derived from the token owner as `<id>+<login>@users.noreply.github.com`.
  - If the token owner response does not include both `id` and `login`, ask the user what email to use.
- Do not rely on ambient `GIT_AUTHOR_*` or `GIT_COMMITTER_*` environment variables when overriding identity. Explicitly set all four variables for that command.
- Never overwrite, add, remove, or rename a persistent Git remote to authenticate with a GHAT. Do not run `git remote add`, `git remote remove`, `git remote rename`, `git remote set-url`, `git branch --set-upstream-to`, `git push -u`, or `git push --set-upstream`; do not change a remote's `pushurl`; and do not store a GHAT in any Git config or credential helper.
- Name branches with a plain feature branch name that follows Git branch naming rules, such as `assistant-dev-mode-runner` or `ingress-alias-cleanup`.
- Keep any requested branch name in a shell variable, validate it with `git check-ref-format --branch "$branch"`, and pass it only through quoted expansions. Never splice a branch name into shell source.
- Use `--no-track` when creating or recreating a local branch from a remote-tracking branch so Git does not persist `branch.*.remote` or `branch.*.merge` entries.
- Never prefix branches with `codex/`.
- Treat the following as staging exclusions. Do not commit them, and do not write them to a repository or global Git configuration or edit a user-owned ignore file:

```
*.md
!README.md

__pycache__

.claude
.codex

.env

.vscode/
.idea/
*.swp
*.swo
*~

.DS_Store
Thumbs.db

.scratch/
docker-compose.override.yaml

go.work
go.work.sum
coverpage.out

.terraform
terraform.tfstate*
.terraform.tfstate.lock.info
```

## Repository Config Guard

- Resolve `scripts/with-preserved-git-config.sh` relative to this `SKILL.md` and use it for every command that can commit, amend, switch or create branches, merge, or push. The guard acquires Git's repository-config lock, snapshots `.git/config` contents and permission metadata, runs the command, and atomically restores the snapshot on success, failure, or interruption if anything changed.
- If another Git config writer already holds the lock, the guard fails before running the command. This prevents the recovery path from overwriting a concurrent user change.
- Treat the guard as recovery protection, not permission to change configuration. Do not intentionally run a config-writing command inside it.
- Wrap a single command directly:

```bash
config_guard='<git-commit skill directory>/scripts/with-preserved-git-config.sh'
"$config_guard" git commit -m '[minor] Add feature summary'
```

- Wrap a related multi-command sequence in one guarded shell when practical:

```bash
"$config_guard" bash -c '
  set -euo pipefail
  git fetch origin main
  git switch feature-branch
'
```

- After the guarded workflow, confirm that the guard completed successfully. If it reports that it could not restore `.git/config`, stop immediately and tell the user; do not continue with more Git operations.

## Commit Command

Use this pattern for new commits when no GHAT or explicit identity override is provided:

```bash
"$config_guard" git commit -m '[minor] Add feature summary'
```

Use this pattern for new commits when a GHAT identity has been resolved:

```bash
env \
  GIT_AUTHOR_NAME="$resolved_name" \
  GIT_AUTHOR_EMAIL="$resolved_email" \
  GIT_COMMITTER_NAME="$resolved_name" \
  GIT_COMMITTER_EMAIL="$resolved_email" \
  "$config_guard" git commit \
    -m '[minor] Add feature summary'
```

Use this pattern when amending without a GHAT or explicit identity override:

```bash
"$config_guard" git commit --amend --no-edit
```

Use this pattern when amending with a resolved GHAT identity:

```bash
env \
  GIT_AUTHOR_NAME="$resolved_name" \
  GIT_AUTHOR_EMAIL="$resolved_email" \
  GIT_COMMITTER_NAME="$resolved_name" \
  GIT_COMMITTER_EMAIL="$resolved_email" \
  "$config_guard" git commit --amend --no-edit --reset-author
```

After committing, verify the last commit:

```bash
git log -1 --format='author %an <%ae>%ncommitter %cn <%ce>%n%B'
```

The output must show the expected identity. If a GHAT identity was used, author and committer must both match the resolved name and email. The message must not contain `Co-authored-by:`.

## Push Authentication with GHAT

- Use only one-off in-memory Git config for GHAT-authenticated pushes. Keep the existing remotes and `.git/config` unchanged.
- Do not place a GHAT in a remote URL, commit message, branch name, log output, or persistent credential helper.
- Do not run `gh auth setup-git`; it can persist authentication configuration.
- Do not use `set -x` or print the computed authorization header.
- Derive a token-free HTTPS push URL from the repository slug, for example `https://github.com/OWNER/REPO.git`.
- Before pushing, check for any effective `url.*.insteadOf` or `url.*.pushInsteadOf` setting. If one exists, stop and ask the user to remove or explicitly approve it; do not risk redirecting the push URL.
- Push directly to the token-free HTTPS URL. Do not synthesize a named remote, even with `GIT_CONFIG_COUNT`, because its name could collide with an existing remote and inherit that remote's `pushurl`.
- Disable interactive prompts and persistent credential helpers for the push. Supply only the empty helper reset and authorization header through in-memory `GIT_CONFIG_COUNT` values so nothing is written to `.git/config`:

```bash
if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo 'Refusing invalid branch name.' >&2
  exit 1
fi
if git config --get-regexp '^url\..*\.(insteadof|pushinsteadof)$' >/dev/null; then
  echo 'Refusing GHAT push while a Git URL rewrite is active.' >&2
  exit 1
fi
auth_header="$(printf 'x-access-token:%s' "$GHAT" | base64 | tr -d '\n')"
env \
  GIT_TERMINAL_PROMPT=0 \
  GIT_CONFIG_COUNT=3 \
  GIT_CONFIG_KEY_0=credential.helper \
  GIT_CONFIG_VALUE_0= \
  GIT_CONFIG_KEY_1=http.extraHeader \
  GIT_CONFIG_VALUE_1= \
  GIT_CONFIG_KEY_2=http.https://github.com/.extraheader \
  GIT_CONFIG_VALUE_2="AUTHORIZATION: basic ${auth_header}" \
  "$config_guard" git push 'https://github.com/OWNER/REPO.git' "HEAD:${branch}"
unset auth_header
```

- If the repository already has an SSH `origin`, still use a token-free HTTPS URL for the GHAT push path. Fetching can continue to use existing remotes.

## PR Merge

- Check CI status before merging. Do not encode test results in the commit message.
- If the final commit on `main` must preserve a GHAT-resolved committer, avoid `gh pr merge --squash`, GitHub UI squash merge, and other GitHub-created merge commits; GitHub will set the committer to GitHub and may add co-author trailers.
- Prefer a direct fast-forward update when the PR branch has a single clean commit with the expected identity. Fetch explicit remote-tracking destinations, verify ancestry, and push that verified ref to `main`; do not reset or move the user's local `main`:

```bash
if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo 'Refusing invalid branch name.' >&2
  exit 1
fi
"$config_guard" git fetch origin \
  '+refs/heads/main:refs/remotes/origin/main' \
  "+refs/heads/${branch}:refs/remotes/origin/${branch}"
if ! git merge-base --is-ancestor origin/main "origin/${branch}"; then
  echo 'Refusing a non-fast-forward main update.' >&2
  exit 1
fi
if git config --get-regexp '^url\..*\.(insteadof|pushinsteadof)$' >/dev/null; then
  echo 'Refusing GHAT push while a Git URL rewrite is active.' >&2
  exit 1
fi
auth_header="$(printf 'x-access-token:%s' "$GHAT" | base64 | tr -d '\n')"
env \
  GIT_TERMINAL_PROMPT=0 \
  GIT_CONFIG_COUNT=3 \
  GIT_CONFIG_KEY_0=credential.helper \
  GIT_CONFIG_VALUE_0= \
  GIT_CONFIG_KEY_1=http.extraHeader \
  GIT_CONFIG_VALUE_1= \
  GIT_CONFIG_KEY_2=http.https://github.com/.extraheader \
  GIT_CONFIG_VALUE_2="AUTHORIZATION: basic ${auth_header}" \
  "$config_guard" git push 'https://github.com/OWNER/REPO.git' \
    "refs/remotes/origin/${branch}:refs/heads/main"
unset auth_header
```

- For a multi-commit PR requiring a single commit, squash locally after CI passes, create the commit with the appropriate command pattern above, push `main`, then close or delete the PR branch as appropriate.
