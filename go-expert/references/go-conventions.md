# Go Conventions Reference

Use this reference when you need the repo's explicit Go house rules rather than a lightweight review rubric.

These rules are intentionally more specific than generic "idiomatic Go" guidance. If a repo decision conflicts with a generic default, prefer the rule in this file and explain the tradeoff.

## Core Principles

- Favor simple, readable code over clever abstractions.
- Prefer idiomatic Go and standard library solutions first.
- Keep functions focused and split helpers only when behavior repeats meaningfully.

## Naming

- Packages should be short, lowercase, and usually single-purpose.
- Single-method interfaces may use `-er` names such as `Reader` or `Writer`.
- Omit `Get` from getters.
- Preserve common acronym casing such as `userID` and `HTTPServer`.

## Dependencies and HTTP

- Default to the standard library. New external dependencies need a concrete justification.
- Prefer `net/http` for middleware and routing. Do not introduce `mux`, `chi`, `gin`, or similar routers without a strong reason.
- Document dependency tradeoffs when adding non-standard-library packages.

## API Design

- Follow RESTful conventions where they fit the product.
- Use appropriate HTTP methods and status codes.
- Keep response shapes consistent.
- Version APIs when making breaking changes.

## Errors

- Always check and handle errors explicitly.
- Return errors instead of panicking except during truly exceptional startup failures.
- Wrap errors with context using `fmt.Errorf("context: %w", err)`.
- Do not ignore errors with `_` unless the reason is obvious and defensible.

## Concurrency

- Use goroutines deliberately, not by default.
- Every long-lived goroutine should have explicit lifecycle ownership: who starts it, who cancels it, who waits for it, and where its errors go.
- Prefer channels for coordination when they make ownership clearer.
- Avoid shared mutable state unless protected by synchronization primitives.
- Use `context.Context` for cancellation and timeouts.
- Run `go test -race ./...` when concurrency or shared state changes are involved.
- Close channels from the writer side when completion needs to be signaled.

## Security

- Validate and sanitize user input.
- Never log or expose passwords, tokens, API keys, or sensitive personal data.
- Use parameterized queries and generated database access through `sqlc`.
- Check authentication and authorization boundaries explicitly.
- Apply least privilege to infrastructure and service credentials.

## Logging

- Use `log/slog` for structured logging.
- Choose levels intentionally: `Debug`, `Info`, `Warn`, and `Error`.
- Include useful request or domain context such as request IDs and entity identifiers.
- Never log secrets.

## Testing

- Write unit tests for new behavior and bug fixes.
- Prefer table-driven tests when they improve readability and coverage.
- Test exported behavior rather than private implementation details unless needed.
- Use `t.Helper()` in shared helpers.
- Mock external systems when unit tests do not need the real integration.
- Use fixtures and integration tests where boundary behavior matters.
- Prefer meaningful coverage over vanity metrics.

## Documentation

- Every exported package, type, function, and method should have a doc comment.
- Comments should explain why, constraints, or business context rather than narrating obvious code.

## Tooling

- Run `gofmt`.
- Run `golangci-lint` and fix lint failures before merge.
- Keep linting and tests in CI.
