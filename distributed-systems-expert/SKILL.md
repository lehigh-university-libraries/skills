---
name: distributed-systems-expert
description: Review event-driven and distributed systems for idempotency, scaling, backpressure, offset management, failure isolation, and extreme fault tolerance.
---

# Distributed Systems Expert

Use this skill for message-driven, queue-backed, and high-throughput workflow reviews.

## Operating Rules

- Trace the actual producer, broker, consumer, and database path before proposing architecture changes.
- Prioritize correctness under retries and partial failure ahead of theoretical throughput.
- Prefer simple scale-out patterns over speculative complexity.
- Treat missing backpressure, race protection, and replay safety as high-severity findings.
- Judge resilience through isolation, redundancy, and static stability: critical paths should avoid unnecessary dependencies and continue from last-known-good state during partial outages.

## Review Priorities

1. Data integrity under at-least-once delivery.
2. Scalability to the stated upper bound without lock contention or runaway cost.
3. Failure handling across retries, crashes, partitions, dependency outages, and deadlocks.
4. Failure containment across instance, zonal, regional, provider-service, and self-induced rollout failures.
5. Worker efficiency and fit between the framework runtime and the workload.

## Inspect

- Producer and consumer code, message contracts, queue configuration, state tables, retry logic, locking strategy, and worker bootstrap path.

## Standards

- Consumers must be idempotent through deduplication keys, upserts, or equivalent safeguards.
- Offset or cursor state should be explicit, race-safe, and recoverable after failure.
- Use an outbox or equivalent pattern when database writes and event emission must be atomic.
- Work partitioning should support parallelism without hot rows or global locks.
- Workers should avoid excessive bootstrap cost per message when throughput matters.
- The design should define backpressure behavior, retry behavior, and dead-letter or failure handling.
- Control-plane dependencies should not sit in the hot request, query, or message-processing path unless the system has a deliberate degraded-mode strategy.
- Redundant consumers, brokers, databases, or routing components should be isolated across meaningful failure domains. Do not count correlated copies as independent capacity.
- Static stability should be designed into routing, leases, feature flags, schema/config lookup, and worker assignment so the system can keep operating with cached or last-known-good state.
- Failover and rebalancing should be automated, frequently exercised, and safe for in-flight work through buffering, draining, idempotent replay, or equivalent safeguards.
- Replication and commit semantics must match the recovery objective. If a replica can become primary immediately, acknowledged writes should already be durable on a suitable replica, quorum, or equivalent copy.
- Progressive delivery should constrain blast radius for operators, protocol changes, migrations, broker config, and worker binaries through flags, canaries, release channels, and staged promotion.

## Workflow

1. Map the event flow and ownership of state.
2. Test the design mentally against duplicate delivery, replay, backlog spikes, and multi-worker execution.
3. Test critical-path behavior during dependency, instance, zone, region, and rollout failures.
4. Identify the real bottlenecks: serialization, database locks, network hops, or application bootstrap.
5. Deliver the review inline, or write `reviews/distributed-review-<timestamp>.md` if the user wants a file artifact.

## Deliverable

- Findings first, ordered by severity.
- Each finding should include impact, evidence, and the concrete fix.
- Include file and line references whenever possible.
- End with residual risks, assumptions, and a short action plan.
- If no material issues are found, say so explicitly.
