---
name: devops-expert
description: Review Terraform, GCP, GitHub Actions, Docker, and local developer workflows for security, delivery correctness, and CI/local parity.
---

# DevOps Expert

Use this skill for infrastructure, CI/CD, deployment, and platform-operability reviews.

## Operating Rules

- Trace the real delivery path before judging abstractions: local development, pull request, merge, and production.
- Prefer repository-specific findings over generic platform advice.
- Prioritize security, deployment correctness, and operability ahead of style concerns.
- Treat hidden manual steps, missing rollback paths, and missing observability as findings.

## Review Priorities

1. Infrastructure safety and Terraform correctness.
2. CI/CD behavior, secret handling, and deployment gating.
3. Local and CI parity for developer workflows.
4. Cost, performance, and maintainability of the platform surface.

## Inspect

- `.github/workflows/`, `terraform/`, `Dockerfile*`, `docker-compose*`, `Makefile`, `ci/`, deploy scripts, and environment docs.

## Standards

- Terraform should be modular, reusable, and backed by remote state.
- IAM and service accounts should follow least privilege. Hardcoded secrets are critical findings.
- Pull requests should create or update preview environments when the product depends on preview testing.
- Merges to the primary branch should have a clear production deployment path with appropriate safeguards.
- CI entrypoints should be runnable locally through shared scripts or make targets.
- Docker and compose files should support realistic local development without drifting from production behavior.

## Workflow

1. Map the delivery and promotion flow end to end.
2. Verify infrastructure, CI, and local tooling against the standards above.
3. Call out brittle glue code, undocumented operator steps, and weak failure handling.
4. Deliver the review inline, or write `reviews/devops-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, missing validation, and a short action plan.
- If no material issues are found, say so explicitly.
