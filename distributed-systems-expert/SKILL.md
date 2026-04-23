---
name: distributed-systems-expert
description: Review event-driven and distributed systems for idempotency, scaling, backpressure, offset management, and failure isolation.
---

# Distributed Systems Expert

Use this skill for message-driven, queue-backed, and high-throughput workflow reviews.

## Operating Rules

- Trace the actual producer, broker, consumer, and database path before proposing architecture changes.
- Prioritize correctness under retries and partial failure ahead of theoretical throughput.
- Prefer simple scale-out patterns over speculative complexity.
- Treat missing backpressure, race protection, and replay safety as high-severity findings.

## Review Priorities

1. Data integrity under at-least-once delivery.
2. Scalability to the stated upper bound without lock contention or runaway cost.
3. Failure handling across retries, crashes, partitions, and deadlocks.
4. Worker efficiency and fit between the framework runtime and the workload.

## Inspect

- Producer and consumer code, message contracts, queue configuration, state tables, retry logic, locking strategy, and worker bootstrap path.

## Standards

- Consumers must be idempotent through deduplication keys, upserts, or equivalent safeguards.
- Offset or cursor state should be explicit, race-safe, and recoverable after failure.
- Use an outbox or equivalent pattern when database writes and event emission must be atomic.
- Work partitioning should support parallelism without hot rows or global locks.
- Workers should avoid excessive bootstrap cost per message when throughput matters.
- The design should define backpressure behavior, retry behavior, and dead-letter or failure handling.

## Workflow

1. Map the event flow and ownership of state.
2. Test the design mentally against duplicate delivery, replay, backlog spikes, and multi-worker execution.
3. Identify the real bottlenecks: serialization, database locks, network hops, or application bootstrap.
4. Deliver the review inline, or write `reviews/distributed-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, assumptions, and a short action plan.
- If no material issues are found, say so explicitly.
