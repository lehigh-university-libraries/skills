---
name: vault-expert
description: Review HashiCorp Vault policies and integrations for least privilege, auth flow quality, secret lifecycle safety, and auditability.
---

# Vault Expert

Use this skill for reviews of Vault policy files, auth flows, lease handling, and application secret retrieval.

## Operating Rules

- Prioritize exposure risk, over-privilege, and broken rotation behavior over stylistic concerns.
- Treat root-token usage, wildcard capabilities, and secret leakage as critical findings.
- Review the full secret lifecycle: issuance, renewal, revocation, and application failure behavior.
- Prefer repository-specific evidence over generic Vault guidance.

## Review Priorities

1. Least privilege and policy scope.
2. Authentication method quality and token lifecycle handling.
3. Secret path hygiene, versioning, and dynamic-secret opportunities.
4. Auditability and operational resilience.

## Inspect

- Vault policy files, Terraform modules, application config, login scripts, deployment manifests, and any code that reads or renews secrets.

## Standards

- Policies should be scoped per application and environment, with minimal capabilities.
- Avoid `sudo`, `*`, and long-lived administrative tokens except where strictly necessary and well isolated.
- Prefer workload identity, Kubernetes auth, AppRole, OIDC, or cloud-native auth over baked credentials.
- Applications should handle Vault unavailability, lease expiry, and renewal failure deliberately.
- Use KV v2 versioning where appropriate and recommend dynamic secrets when they reduce credential lifetime.
- Audit logging should be enabled or the absence of it should be called out explicitly.

## Workflow

1. Map how identities authenticate and how secrets reach the application.
2. Review policy scope, path naming, TTLs, and renewal behavior.
3. Identify over-privilege, leaked credentials, and integration anti-patterns.
4. Deliver the review inline, or write `reviews/vault-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, missing validation, and a short action plan.
- If no material issues are found, say so explicitly.
