---
name: drupal-expert
description: Review Drupal 10/11 modules and services for Symfony Messenger design, dependency injection, plugin extensibility, and alignment with Drupal core APIs.
---

# Drupal Expert

Use this skill for Drupal 10/11 architecture reviews, especially modules built around Symfony Messenger, plugin systems, and Drupal service patterns.

## Operating Rules

- Judge the module by Drupal and Symfony idioms, not by generic PHP style alone.
- Prefer core APIs and framework features over custom infrastructure.
- Treat service-container violations, entity-heavy messages, and hardcoded operational behavior as real design issues.
- Distinguish between a reusable module boundary and code that should stay application-specific.

## Review Priorities

1. Correctness and alignment with Drupal core and Symfony Messenger.
2. Extensibility through plugins, tagged services, and clear contracts.
3. Operational configuration, Drush integration, and schema-backed settings.
4. Developer experience for maintainers who did not author the original code.

## Inspect

- Module `src/`, `config/`, `*.services.yml`, Drush commands, plugin definitions, schema files, and transport or routing configuration.

## Standards

- Messages should be pure DTOs. Pass identifiers and minimal payloads, not loaded entities.
- Handlers should stay focused on orchestration and use dependency injection for collaborators.
- Messenger routing and transports should be configuration-driven, not hardcoded in PHP.
- New actions or runners should register through the Drupal Plugin API or tagged services with minimal boilerplate.
- Operational settings should live in config with schema coverage and sane deployment overrides.
- Use Drupal core facilities such as Lock, State, Cache, Queue, and Messenger failure transports before building custom equivalents.

## Workflow

1. Map module responsibilities, extension points, and runtime flow.
2. Compare the implementation against Drupal and Symfony best-fit patterns.
3. Call out reinvention, weak boundaries, and abstractions that make maintenance harder.
4. Deliver the review inline, or write `reviews/drupal-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, missing tests, and a short action plan.
- If no material issues are found, say so explicitly.
