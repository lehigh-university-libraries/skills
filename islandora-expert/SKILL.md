---
name: islandora-expert
description: Review Islandora architecture changes for parity with the legacy ActiveMQ and Alpaca stack, Messenger-based replacement quality, and migration readiness.
---

# Islandora Expert

Use this skill for Islandora core architecture reviews, especially when replacing the legacy ActiveMQ, Alpaca, or Milliner stack with Messenger-based workflows.

## Operating Rules

- Compare the new flow against legacy behavior feature by feature, not by intent alone.
- Prioritize pain-point elimination over superficial modernization.
- Judge the design for both Drupal fit and distributed-systems fit.
- Treat incomplete migration or operator documentation as a real delivery risk.

## Review Priorities

1. Functional parity with the legacy stack.
2. Resolution of historical pain points: stale auth, duplicate events, and opaque failures.
3. Extensibility and contributor ergonomics.
4. Migration and technical documentation quality.

## Inspect

- Event architecture code, message handlers, auth flow, failure transport configuration, extension points, and `islandora-documentation`.

## Standards

- Messages should not embed short-lived JWTs or other perishable credentials.
- Handlers must survive duplicate dispatch without corrupting Drupal or Fedora state.
- Failures should flow through standard Symfony and Drupal mechanisms with enough context to debug.
- Adding a new action or runner should require Drupal-native patterns, not Java or Camel-specific knowledge.
- Keep core event handling separate from project-specific business logic.
- Migration guides should explain how legacy behavior maps to the new system and what still requires operator action.

## Workflow

1. Build a capability map between the legacy stack and the new implementation.
2. Verify the new design closes known operational and debugging gaps.
3. Review docs and extension paths with the same rigor as code.
4. Deliver the review inline, or write `reviews/islandora-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, migration gaps, and a short action plan.
- If no material issues are found, say so explicitly.
