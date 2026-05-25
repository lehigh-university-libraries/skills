---
name: code-review
description: Review code changes and pull requests for code health, correctness, small-change discipline, tests, maintainability, and constructive reviewer feedback.
---

# Code Review

Use this skill for general code reviews, pull request reviews, CL-style reviews, and review-process guidance. Combine it with a domain expert skill when a change needs language, security, frontend, infrastructure, or distributed-systems depth.

## Operating Rules

- Optimize for long-term code health while allowing useful progress. A change should improve the system overall; it does not need to be perfect.
- Do not approve changes that clearly make the system worse except for true emergency recovery work, and name the follow-up debt explicitly.
- Prefer technical facts, repository standards, tests, and production evidence over personal preference.
- Treat style as binding only when it comes from an established style guide, formatter, lint rule, or local consistency requirement. Mark pure polish as `Nit:` or optional.
- Review the code, not the author. Be direct, explain why, and separate required fixes from suggestions.
- If code is hard to understand, ask for clearer code or durable comments in the codebase, not just an explanation in the review thread.

## Review Priorities

1. Correctness, user impact, security, privacy, data integrity, and concurrency safety.
2. Design fit with the existing system, ownership boundaries, and contracts.
3. Simplicity: avoid unnecessary abstraction, speculative generality, and changes that readers cannot understand quickly.
4. Tests that would fail for the bug or behavior being changed.
5. Naming, comments, documentation, style, and consistency.

## Inspect

- Pull request description, linked issue, diff summary, changed source, tests, docs, generated files, migrations, contracts, CI status, and surrounding code needed to understand the change.

## Standards

- Understand every assigned human-written line. Generated files, lockfiles, vendored code, and large data files may be sampled, but say so in the review.
- A review finding should identify concrete impact, evidence, and a fix or decision. Avoid vague preferences.
- Changes should be self-contained and reasonably small. Ask for splitting when a change mixes unrelated behavior, broad refactoring, formatting churn, or review scopes requiring different owners.
- Keep behavior changes, major refactors, and mechanical formatting in separate changes unless the repository convention or risk profile says otherwise.
- Tests belong with the production behavior they validate. Refactor-only changes should still be protected by existing or added tests when behavior preservation matters.
- Comments should usually explain why code exists or why a decision was made. Prefer simplifying unclear code over adding comments that narrate complexity.
- Documentation should change when the patch changes build, deploy, configuration, user behavior, APIs, or operator workflows.
- Escalate or request another reviewer for areas outside your review scope, especially security, privacy, accessibility, internationalization, concurrency, data migrations, and production operations.

## Workflow

1. Map the intent and scope from the description, issue, and diff.
2. Take a broad pass for design fit, ownership, decomposition, and rollback or migration risk.
3. Review the main logic, edge cases, tests, docs, and affected contracts in detail.
4. Distinguish blockers from nits and optional improvements.
5. Deliver the review inline, or write `reviews/code-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix or decision.
- Include file and line references whenever possible.
- Separate required fixes from optional suggestions and nits.
- State reviewed scope, skipped generated files, missing validation, and residual risk.
- If no material issues are found, say so explicitly.

