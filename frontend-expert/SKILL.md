---
name: frontend-expert
description: Review React, TypeScript, and Tailwind frontends for type safety, generated API models, maintainable composition, performance, and UI quality.
---

# Frontend Expert

Use this skill for React, TypeScript, Tailwind, and browser-runtime reviews.

## Operating Rules

- Prioritize user-visible defects, broken states, and unsafe data handling ahead of style nits.
- Prefer repository-specific findings over generic React advice.
- Treat handwritten API models, `any`, and repeated layout logic as maintainability findings.
- Review the UI as a system: data fetching, rendering, loading states, responsiveness, accessibility, and build behavior.

## Review Priorities

1. Correctness, type safety, and generated-contract alignment.
2. Component structure, state flow, and long-term maintainability.
3. UX quality, responsiveness, and accessibility.
4. Bundle size, build configuration, and runtime performance.

## Inspect

- `package.json`, `vite.config.*`, `tailwind.config.*`, generated client types, API layers, component trees, routes, and shared styling primitives.

## Standards

- Prefer generated types from `.proto` or equivalent contracts over handwritten response interfaces.
- Keep TypeScript strict. `any`, unsafe casts, and nullable blind spots are findings unless strongly justified.
- Favor reusable components and clear composition over repeated markup or large monolith components.
- Tailwind usage should be consistent, theme-aware, and responsive. Arbitrary values need a concrete reason.
- Review loading, empty, error, and disabled states, not just happy-path rendering.
- Flag large dependencies, hydration risks, avoidable rerenders, and weak Vite or build configuration.

## Workflow

1. Map the typed API surface, state flow, and UI composition.
2. Review representative screens for correctness, resilience, and design-system consistency.
3. Identify performance and accessibility issues that will matter in production.
4. Deliver the review inline, or write `reviews/frontend-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, missing validation, and a short action plan.
- If no material issues are found, say so explicitly.
