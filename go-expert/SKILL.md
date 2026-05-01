---
name: go-expert
description: Review Go backends and related `buf` and `sqlc` tooling for correctness, security, idiomatic design, performance, and contract alignment.
---

# Go Expert

Use this skill for Go backend reviews, especially when API contracts, generated code, and database access patterns matter.

## Operating Rules

- Start with correctness, security, and data integrity before style or micro-optimizations.
- Prefer simple, idiomatic Go over clever abstractions.
- Treat raw SQL in business logic, ignored errors, goroutines without explicit lifecycle ownership, and weak context propagation as serious findings.
- When repository house rules are stricter than generic Go advice, follow the repository rule and call out the tradeoff.
- Prefer repository-specific evidence over generic Go advice.

## Review Priorities

1. Correctness and security.
2. Simplicity and idiomatic Go design.
3. Contract alignment across `.proto`, generated code, and handlers.
4. Database safety and `sqlc` usage.
5. Maintainability, tests, and performance.

## Inspect

- Go source files, handlers, services, storage layers, `.proto` files, `buf.*`, `sqlc.*`, migrations, tests, lint or CI config, and logging or auth paths.

## Tools

- Use `gopls` for Go documentation, symbol information, signatures, and package API details before falling back to web docs.
- Use `govulncheck ./...` when dependency or reachable vulnerability risk is in scope.
- Use `gosec ./...` for Go security scanning, especially around file permissions, subprocesses, crypto, tainted inputs, and hardcoded secrets.

## Standards

- Prefer the standard library unless another dependency clearly earns its cost.
- Keep packages and functions focused, readable, and easy to trace.
- APIs should be defined in `.proto` or other contract sources, then consumed through generated types rather than hand-rolled duplicates.
- Use well-known protobuf types appropriately and evaluate schema changes with `buf lint` and `buf breaking` expectations in mind.
- Keep SQL in `sqlc` query files. Inline SQL in application logic is a finding.
- Verify transactions, locking, and query shape for atomicity and performance.
- Pass `context.Context` through IO-bound and long-running work. Check errors and wrap them with useful context.
- Use goroutines deliberately, guard shared state, and flag race risks.
- Require structured logging, no secret leakage, and clear auth or authorization boundaries.
- Expect meaningful tests, `gofmt`, `golangci-lint`, and useful doc comments on exported APIs.

## Non-Negotiables

- Default to the standard library. Prefer `net/http` over third-party routers unless the repo has already standardized elsewhere or there is a clear technical reason.
- Keep naming predictable: short lowercase package names, `-er` for single-method interfaces when it fits, no `Get` prefix on getters, and preserve acronym casing such as `userID` and `HTTPServer`.
- Use `log/slog` for structured logging and never log secrets, tokens, or sensitive personal data.
- All exported packages, types, functions, and methods should have doc comments. Internal comments should explain why, not restate what the code does.
- Prefer table-driven tests when they improve clarity, use `t.Helper()` in shared test helpers, and run `go test -race ./...` when concurrency is in scope.
- Read `references/go-conventions.md` when you need the full house style for dependencies, API design, errors, concurrency, testing, docs, and linting expectations.

## Workflow

1. Map the request path from transport to storage and back.
2. Compare the implementation against the standards above.
3. Separate correctness bugs from idiomatic improvements and testing gaps.
4. Deliver the review inline, or write `reviews/go-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, missing validation, and a short action plan.
- If no material issues are found, say so explicitly.
