---
name: security-review
description: Review code, configuration, infrastructure, CI, dependencies, and application behavior for concrete security risks. Use when the user asks for a security review, adversarial review, threat modeling pass, vulnerability assessment, secrets/auth review, supply-chain review, or when changes touch authentication, authorization, input handling, file/process/network access, cryptography, logging of sensitive data, Docker, GitHub Actions, Terraform, Vault, or dependency updates.
---

# Security Review

Use this skill for cross-stack security review. Focus on exploitable findings, realistic attack paths, data exposure, and defense gaps. Avoid generic hardening advice unless it is tied to evidence in the codebase.

## Operating Rules

- Lead with correctness and exploitability, not style.
- Prefer repository evidence over checklist speculation.
- Trace trust boundaries: user input, external services, filesystem, subprocesses, network calls, secrets, identity, and privileged APIs.
- Treat missing authorization, secret exposure, injection, SSRF, path traversal, unsafe deserialization, weak crypto, and CI supply-chain risks as high priority.
- Distinguish confirmed findings from residual risk and tool noise.
- Do not recommend broad rewrites when a targeted control fixes the issue.

## Review Priorities

1. Authentication, authorization, tenant isolation, and privilege boundaries.
2. Input validation and injection risks: SQL, command, template, LDAP, path traversal, SSRF, XSS, and unsafe redirects.
3. Secret lifecycle: storage, logging, environment exposure, CI masking, rotation, and least privilege.
4. File, process, and network access: permissions, archive extraction, subprocess arguments, URL allowlists, and egress paths.
5. Dependency and supply-chain risk: vulnerable packages, unpinned actions/images, unsafe scripts, generated code provenance, and lockfile drift.
6. Cryptography and token handling: random generation, hashing, signing, verification, expiration, replay, and key management.
7. Observability safety: logs, traces, metrics, errors, and debug endpoints must not leak sensitive data.

## Tools

- Run `govulncheck ./...` for Go projects when reachable dependency vulnerability risk is in scope.
- Run `gosec ./...` for Go security scanning, especially for subprocesses, file permissions, crypto, hardcoded secrets, and tainted inputs.
- Use `gopls` for Go documentation, signatures, symbol references, and package API details before falling back to web docs.
- Use ecosystem-native scanners when available and already configured, such as `composer audit`, `npm audit`, `pnpm audit`, `pip-audit`, `bundler-audit`, `cargo audit`, `trivy`, `grype`, `semgrep`, or existing repo security jobs.
- Treat scanner output as leads. Verify reachability, configuration, and exploitability before reporting a finding.

## Workflow

1. Identify changed files and security-relevant entry points.
2. Map the data and privilege flow from attacker-controlled input to sensitive operations.
3. Inspect existing controls: validation, authorization, escaping, parameterization, sandboxing, rate limiting, and audit logging.
4. Run targeted scanners where the repo has the runtime or tooling to support them.
5. Report only material issues, ordered by severity, with concrete remediation.

## Findings

Each finding should include:

- Severity and title.
- Impact: what an attacker can do or what data/control is exposed.
- Evidence: file and line references, data flow, config, or scanner result.
- Fix: the smallest practical code or configuration change.
- Validation: test, scanner command, or manual check that would prove the fix.

## Non-Findings

- Do not report theoretical issues without a credible path.
- Do not flag accepted repo patterns unless they create a specific security failure.
- Do not paste long scanner output. Summarize the relevant result and cite the command.
- If no material issues are found, say that clearly and list any unverified residual risks.
