---
name: islandora-operator
description: Review Islandora deployment and migration setups for Docker or s6 process design, environment-driven configuration, production readiness, and operational simplicity.
---

# Islandora Operator

Use this skill for operational reviews of Islandora deployments, especially Docker, s6, migration, and production runbook concerns.

## Operating Rules

- Judge the system as an operator would: deployment, rollback, debugging, and steady-state maintenance.
- Treat undocumented environment toggles, hidden defaults, and brittle container coupling as findings.
- Prefer explicit configuration surfaces over code changes for operational behavior.
- Evaluate both the hybrid path and the simplified path if the project supports both.

## Review Priorities

1. Production operability and failure handling.
2. Migration clarity from the legacy stack.
3. Configuration quality and environment-driven control.
4. Resource footprint and container simplification.

## Inspect

- `docker-compose*`, Dockerfiles, build or image definitions, s6 service configuration, environment schemas, deployment docs, and migration guides.

## Standards

- Hybrid and simplified execution paths should both be understandable, testable, and clearly documented.
- Routing, transport selection, worker counts, and resource limits should be configurable without code edits.
- Simplified mode should remove unnecessary JVM-era services cleanly and document what replaces them.
- Version requirements and compatibility constraints should be explicit.
- Migration guides should be stepwise, production-oriented, and honest about cutover risk.

## Workflow

1. Map the supported deployment modes and their operator touchpoints.
2. Review configuration surfaces, process supervision, and failure recovery paths.
3. Compare the claimed simplification against the actual container and resource footprint.
4. Deliver the review inline, or write `reviews/operator-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, migration gaps, and a short action plan.
- If no material issues are found, say so explicitly.
