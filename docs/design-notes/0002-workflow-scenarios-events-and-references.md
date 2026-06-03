# 0002 - Workflow scenarios, events, and references

## Status

Accepted as current exploratory direction.

This note captures the reasoning behind recent changes to workflows, events, capability-declared events, workflow triggering, directory grouping, and reference resolution.

It is not a final schema definition.

---

## Context

The initial QUIC example modeled workflows as ordered lists of capabilities.

Example:

```yaml
steps:
  - connection/send_initial
  - connection/perform_handshake
```

This was simple and readable, but it raised several design questions:

- How should failures be modeled?
- How should timeouts be modeled?
- Should workflows contain branching?
- Should emitted events live on workflows, workflow steps, or capabilities?
- Should related workflows require a higher-level entity such as Scenario, Use Case, Story, or Journey?
- How should references resolve without duplicating scope names everywhere?

Several alternatives were explored and rejected or deferred.

---

## Decision 1: Workflows describe behavioral scenarios, not programs

A workflow represents one behaviorally meaningful scenario.

Examples:

```text
establish_connection
handle_handshake_failure
handle_idle_timeout
close_connection
```

A workflow is not an exhaustive execution graph.

A workflow is not a program.

Implementation-local branching belongs in source code.

This means a workflow should not attempt to model every possible `if`, exception, retry, or technical branch that might appear in implementation code.

Instead, important system-level behaviors can be modeled as separate workflows.

---

## Decision 2: Meaningful failure, timeout, and recovery paths may be separate workflows

Rather than embedding success, failure, timeout, and recovery branches inside one large workflow, BehavioML can model them as separate scenarios.

Example:

```text
workflows/client/establish_connection.yaml
workflows/client/handle_handshake_failure.yaml
```

The nominal workflow stays simple:

```yaml
steps:
  - connection/send_initial
  - connection/perform_handshake
```

The failure workflow is triggered by an observable event:

```yaml
triggered_by:
  - handshake_failed

steps:
  - connection/send_connection_close
  - connection/discard_connection_state
```

This keeps workflows readable, diff-friendly, and focused.

---

## Decision 3: Events are observable occurrences

An event represents something observable that happened in the system.

Events may be consumed by:

- workflows
- state machines
- monitoring
- other behavior

Errors, failures, timeouts, and cancellations that matter at the behavior level should be modeled as events.

Technical exceptions that are local to implementation code should not be modeled directly.

Example:

```text
handshake_failed
idle_timeout_expired
connection_close_received
```

---

## Decision 4: Capabilities may declare observable events

A capability may declare observable events associated with its behavior.

Example:

```yaml
requires:
  - crypto/tls_handshake

events:
  - handshake_completed
  - handshake_failed
```

Capability-declared events do not imply:

- exact timing
- final result
- success/failure classification
- single receiver
- exclusive ownership by one consumer

The purpose is to make observable behavior discoverable without turning workflows into event scripts.

---

## Decision 5: Workflows may be triggered by events

Workflows may declare triggering events.

Example:

```yaml
triggered_by:
  - handshake_failed
```

This connects behavior scenarios without embedding branching logic inside a single workflow.

The current model treats `triggered_by` as a typed field whose references resolve to events.

---

## Decision 6: Directories may group related workflows

A higher-level entity such as `Scenario`, `UseCase`, `Story`, or `Journey` is not required yet.

Related workflows can be grouped by directory because the filesystem is part of the model.

Example:

```text
workflows/connection/client/establish_connection.yaml
workflows/connection/client/handle_handshake_failure.yaml
workflows/connection/endpoint/handle_idle_timeout.yaml
```

A separate higher-level entity should only be introduced when the group itself needs source-of-truth metadata.

Examples of such metadata might include:

- goal
- scope
- actors
- preconditions
- success criteria
- priority
- coverage
- ownership

Until then, directory grouping is sufficient.

---

## Decision 7: References are resolved by semantic field scope

References are not filesystem-relative.

A field defines the target entity type for its references.

The reference value is a path identity inside that target scope.

Examples:

| Field | Target scope | Value | Resolves to |
| --- | --- | --- | --- |
| `steps` | `capabilities/` | `connection/send_initial` | `capabilities/connection/send_initial.yaml` |
| `triggered_by` | `events/` | `handshake_failed` | `events/handshake_failed.yaml` |
| `requires` | `interfaces/` | `crypto/tls_handshake` | `interfaces/crypto/tls_handshake.yaml` |
| `roles.primary` | `roles/` | `client` | `roles/client.yaml` |

This avoids unnecessary verbosity such as:

```yaml
triggered_by:
  - events:handshake_failed
```

because `triggered_by` already implies the `events/` scope.

---

## Decision 8: Polymorphic fields use typed references

Some fields may reference multiple entity types.

For example, a decision may affect workflows, capabilities, events, modules, or other model entities.

Those fields need explicit typed references.

Syntax:

```text
<scope>:<path-identity>
```

Examples:

```text
workflows:connection/client/establish_connection
capabilities:connection/perform_handshake
events:handshake_failed
```

URL-like reference forms are intentionally not used.

Rejected:

```text
events://handshake_failed
```

---

## Alternatives considered

### Step-level emitted events

One explored option was to attach events directly to workflow steps:

```yaml
steps:
  - capability: connection/send_initial
    emits:
      - connection_started
```

This improved causal locality, but it duplicated information that may belong on capabilities and pushed workflows toward event scripting.

Rejected as the default direction.

---

### Capability `emits`

Another option was to place `emits` on capabilities:

```yaml
emits:
  - handshake_completed
```

The term `emits` suggested timing or completion semantics too strongly.

Renamed to `events`.

---

### Capability `outcomes`

`outcomes` was considered but rejected because events are not necessarily final results.

Events may be broadcast, observed by multiple consumers, and occur during behavior.

---

### Inline workflow branching

A diff-friendly branching shape was explored:

```yaml
steps:
  - capability: connection/perform_handshake
    on_event:
      handshake_completed:
        then:
          - end: connected
      handshake_failed:
        then:
          - capability: connection/send_connection_close
```

This was readable, but it moved workflows too close to declarative code.

Rejected as the current direction.

---

### Global workflow graph

A graph-shaped workflow was considered:

```yaml
start: send_initial

nodes:
  send_initial:
    capability: connection/send_initial
    next: perform_handshake
```

This can represent branching, but it makes YAML diffs harder to review and introduces fragile internal node references.

Deferred.

---

### New Scenario / Use Case / Story entity

A higher-level grouping entity was considered for related workflows.

Deferred until workflow groups need their own metadata.

For now, directories provide sufficient grouping.

---

## Consequences

The current exploratory model favors:

- simple, readable workflows
- workflow-per-scenario modeling
- event-triggered follow-up workflows
- capability-declared observable events
- directory-based workflow grouping
- semantic field-scope reference resolution
- typed references only for polymorphic fields

It avoids:

- executable workflow graphs
- implementation-local branching in the model
- technical exceptions as model entities
- duplicating events across workflows and capabilities
- unnecessary higher-level grouping entities

---

## Open questions

- When should behavior become a separate workflow rather than remain implicit in implementation code?
- Should `triggered_by` accept only events, or later support conditions?
- Should workflows declare preconditions separately from triggering events?
- Can one capability declare many events, or does that indicate the capability is too broad?
- Should capability `events` mean possible observable events or expected observable events?
- Should related workflow directories ever gain metadata through a future entity?
- How should retries be represented without turning workflows into code?
- How much behavior detail is useful before the model becomes a protocol specification?
