# BehavioML Model Rules

This document defines the current operational rules for BehavioML model files.

It is intended to bridge the conceptual specification in `README.md` and future validation tooling.

These rules describe the current exploratory model. They are not a final schema.

---

## Model root

A BehavioML model lives under a `model/` directory.

Expected top-level scopes:

```text
model/
├── workflows/
├── roles/
├── capabilities/
├── interfaces/
├── components/
├── modules/
├── events/
├── entities/
├── state-machines/
├── decisions/
└── generated/
```

Only model directories contain source-of-truth information.

`generated/` contains derived artifacts and should not be treated as source of truth.

---

## Identity rules

### One file equals one entity

Every source-of-truth model entity is represented by exactly one file.

### Path identity

Entity identity is derived from the file path inside its scope directory.

Example:

```text
model/capabilities/auth/validate_user.yaml
```

Scope:

```text
capabilities
```

Path identity:

```text
auth/validate_user
```

### No internal IDs

Model YAML files must not define top-level identity fields such as:

```text
id
ids
uuid
uuids
```

Identity belongs to the filesystem path.

---

## Reference rules

References are resolved by semantic field scope.

A field defines the target entity type for its references.

The reference value is a path identity inside that target scope.

References are never filesystem-relative.

Forbidden reference forms:

```text
../foo
./foo
foo/../bar
```

---

## Typed fields

Typed fields resolve references to one known target scope.

| Source field | Target scope |
| --- | --- |
| `Workflow.roles.primary` | `roles/` |
| `Workflow.roles.participants[]` | `roles/` |
| `Workflow.steps[]` | `capabilities/` |
| `Workflow.triggered_by[]` | `events/` |
| `Capability.uses[]` | `capabilities/` |
| `Capability.requires[]` | `interfaces/` |
| `Capability.events[]` | `events/` |
| `Component.implements.capabilities[]` | `capabilities/` |
| `Component.implements.interfaces[]` | `interfaces/` |
| `Component.belongs_to` | `modules/` |
| `StateMachine.entity` | `entities/` |
| `StateMachine.transitions[].on` | `events/` |

Examples:

```yaml
triggered_by:
  - handshake_failed
```

resolves to:

```text
events/handshake_failed.yaml
```

```yaml
steps:
  - connection/send_initial
```

resolves to:

```text
capabilities/connection/send_initial.yaml
```

```yaml
requires:
  - crypto/tls_handshake
```

resolves to:

```text
interfaces/crypto/tls_handshake.yaml
```

---

## Polymorphic references

Polymorphic fields may reference multiple entity types.

Polymorphic fields must use typed references.

Typed reference syntax:

```text
<scope>:<path-identity>
```

Example:

```yaml
affects:
  - workflows:connection/client/establish_connection
  - capabilities:connection/perform_handshake
  - events:handshake_failed
```

URL-like references are not used.

Forbidden:

```text
events://handshake_failed
```

Current known polymorphic fields:

| Field | Meaning |
| --- | --- |
| `Decision.affects[]` | Model entities affected by the decision |

---

## Workflow rules

A workflow describes one behaviorally meaningful scenario.

A workflow is not an exhaustive execution graph.

A workflow is not a program.

A workflow may contain:

```yaml
description: |
  ...

roles:
  primary: client
  participants:
    - server

triggered_by:
  - handshake_failed

steps:
  - connection/send_connection_close
  - connection/discard_connection_state
```

### Workflow responsibilities

A workflow owns:

- behavioral intent
- ordered steps
- participating roles
- optional triggering events

### Workflow steps

`steps` references capabilities.

Workflows must not reference components directly.

### Workflow triggering

`triggered_by` references events.

Meaningful failure, timeout, retry, and recovery paths may be represented as separate workflows triggered by events.

`triggered_by` should reference the event that makes the workflow behaviorally eligible to start from the perspective of the workflow's primary role.

It should not reference merely any upstream causal event if that event is not observable by, or behaviorally available to, the role that starts the workflow.

For example, a client workflow that exchanges an OAuth authorization code for tokens should not be triggered by the server-side event that the authorization code was issued if the client only learns about the code when the browser delivers the authorization callback.

In that case, the client workflow should be triggered by an explicit callback-delivered or code-received event.

This keeps workflow causality aligned with observable behavior and avoids hidden assumptions in generated diagrams or implementation scaffolds.

### Workflow grouping

Related workflows may be grouped by directory.

A separate higher-level entity such as `Scenario`, `Use Case`, `Story`, or `Journey` should only be introduced if the group needs its own source-of-truth metadata.

### Workflow non-goals

Workflows should not model:

- every execution branch
- implementation-local branching
- technical exceptions
- framework details
- executable control flow

---

## Capability rules

A capability describes a responsibility.

Capabilities may be atomic or composite.

A capability may contain:

```yaml
description: |
  ...

uses:
  - connection/validate_peer

requires:
  - crypto/tls_handshake

events:
  - handshake_completed
  - handshake_failed
```

### Capability composition

`uses` references other capabilities.

### Capability dependencies

`requires` references interfaces.

### Capability events

`events` references observable events associated with the capability behavior.

Capability-declared events do not imply:

- exact timing
- final result
- success/failure classification
- single receiver

---

## Role rules

A role represents a functional participant in a workflow.

A role is not:

- a component
- an entity
- a module
- an implementation

Workflow role references resolve to files under `roles/`.

---

## Interface rules

An interface describes an architectural dependency point.

Capabilities may require interfaces.

Components may implement interfaces.

Interfaces do not describe implementation.

---

## Component rules

A component describes implementation.

A component may implement capabilities and interfaces.

A component may belong to a module.

Example:

```yaml
implements:
  capabilities:
    - connection/perform_handshake
  interfaces:
    - crypto/tls_handshake

belongs_to: transport
```

Rules:

- `implements.capabilities[]` references `capabilities/`
- `implements.interfaces[]` references `interfaces/`
- `belongs_to` references `modules/`

Components should not describe behavior directly.

---

## Module rules

A module describes organization, ownership, packaging, or boundaries.

Modules do not describe behavior.

Components may belong to modules.

---

## Event rules

An event represents something observable that happened in the system.

Events may be consumed by:

- workflows
- state machines
- monitoring
- other behavior

Failures, timeouts, cancellations, and recovery signals that matter at system behavior level may be modeled as events.

Technical exceptions local to implementation code should not be modeled directly.

---

## Entity rules

An entity represents ownership of state.

Entities do not own transitions.

State machines own transitions.

---

## State machine rules

A state machine owns lifecycle states, transitions, and constraints.

A state machine may contain:

```yaml
entity: connection

states:
  - initial
  - handshaking
  - connected
  - closing
  - closed

transitions:
  - from: initial
    on: connection_started
    to: handshaking
  - from:
      - handshaking
      - connected
    on: connection_close_received
    to: closing
```

Rules:

- `entity` references `entities/`
- `transitions[].from` may be a single state string or a non-empty array of state strings
- `transitions[].to` is a single state string
- `transitions[].on` references `events/`
- state machines own transitions
- workflows do not own transitions

Multiple `from` states may be used when the same event causes the same transition to the same target state from several source states.

Multiple `to` states are not supported. Multiple targets imply conditional branching and should be modeled explicitly instead.

---

## Decision rules

A decision explains rationale.

A decision may affect any model entity.

Because `affects` is polymorphic, affected entities must be referenced using typed references.

Example:

```yaml
affects:
  - workflows:connection/client/establish_connection
  - capabilities:connection/perform_handshake
  - events:handshake_failed
```

---

## Generated artifacts

Generated artifacts are derived from the model.

They are not source of truth.

Validators should ignore `generated/` directories unless explicitly validating generated output.

---

## Initial validator scope

A first validator should check structural consistency, not final schema completeness.

Suggested initial checks:

1. Every YAML file parses successfully.
2. No YAML file contains top-level `id`, `ids`, `uuid`, or `uuids`.
3. References do not use relative filesystem forms.
4. Workflow role references resolve under `roles/`.
5. Workflow `steps` references resolve under `capabilities/`.
6. Workflow `triggered_by` references resolve under `events/`.
7. Workflows do not reference components directly.
8. Capability `uses` references resolve under `capabilities/`.
9. Capability `requires` references resolve under `interfaces/`.
10. Capability `events` references resolve under `events/`.
11. Component implemented capabilities resolve under `capabilities/`.
12. Component implemented interfaces resolve under `interfaces/`.
13. Component `belongs_to` resolves under `modules/`.
14. State machine `entity` resolves under `entities/`.
15. State machine transition events resolve under `events/`.
16. State machine transition source states, if validated, may be scalar or array-valued.
17. State machine transition target states, if validated, are scalar.
18. Decision `affects` entries use typed references and resolve to existing model entities.
19. `generated/` directories are ignored as source-of-truth input.

---

## Explicitly not validated yet

The initial validator should not enforce:

- final YAML schema shape
- formatting preferences
- complete protocol correctness
- generated view correctness
- whether every event must be consumed
- whether every capability event must appear in a workflow
- whether every workflow must be reachable from another workflow
- whether workflow directories imply a formal scenario entity
- implementation-specific behavior

These may be explored later.
