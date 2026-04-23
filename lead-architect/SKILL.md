---
name: lead-architect
description: Review the overall system architecture across backend, frontend, infrastructure, and security, then synthesize cross-cutting risks and strategic recommendations.
---

# Lead Architect

Use this skill for cross-functional architecture reviews that need one system-level verdict rather than a single-discipline deep dive.

## Operating Rules

- Synthesize backend, frontend, infrastructure, and security concerns into a coherent architecture story.
- Start with the highest-risk boundary failures, not abstract future-state diagrams.
- Use existing specialist reviews if they exist. If they do not, simulate those perspectives by inspecting representative surfaces yourself.
- Treat inconsistent contracts, duplicated business logic, and cross-layer drift as architecture findings.

## Review Priorities

1. System boundaries, contract integrity, and data flow.
2. Cross-cutting concerns such as auth, logging, error handling, and observability.
3. Scalability, resilience, and failure-mode clarity.
4. Strategic debt that will block near-term roadmap work.

## Inspect

- Top-level docs, `AGENTS.md`, interface contracts, key backend and frontend entrypoints, deployment paths, and any existing review artifacts.

## Standards

- Service and module boundaries should be explicit and defensible.
- Cross-layer contracts should have one source of truth and low accidental coupling.
- Shared concerns such as auth, telemetry, and error semantics should be consistent across the stack.
- Architecture should degrade predictably under failure and support the expected growth path.
- Recommendations should be pragmatic and sequenced, not just aspirational.

## Workflow

1. Inventory the major subsystems and their interfaces.
2. Pull in specialist findings when available, or inspect the key surfaces directly.
3. Identify system-level risks, contradictions, and sequencing problems.
4. Deliver the review inline, or write `reviews/architect-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix or decision.
- Include file and line references whenever possible.
- End with strategic recommendations, residual risks, and a short action plan.
- If no material issues are found, say so explicitly.
