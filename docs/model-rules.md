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
├── semantic-areas/
├── events/
├── entities/
├── state-machines/
├── decisions/
└── generated/
```

Only model directories contain source-of-truth information.

`generated/` contains derived artifacts and should not be treated as source of truth.

Optional implementation guidance may live beside a model, but not inside the model root.

For example:

```text
example/
├── model/
├── generated/
└── implementation/
    ├── README.md
    ├── AGENTS.md
    └── codegen-profile.yaml
```

Implementation guidance may configure, constrain, or instruct implementation/code-generation work, but it must not define behavior that is missing from or contradictory to the BehavioML model.

If behavior is required for correctness, it belongs in the BehavioML model.

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

Forbidden reference forms include current-directory references, parent-directory references, and any path identity that walks upward through a parent directory segment.

---

## Typed fields

Typed fields resolve references to one known target scope.

| Source field | Target scope |
| --- | --- |
| `SemanticArea.workflows[]` | `workflows/` |
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

## Semantic area rules

A semantic area represents a behaviorally coherent area of the modeled system or protocol.

Semantic areas organize behavior.

Modules organize implementation and component ownership.

A semantic area may contain:

```yaml
name: Protected packet receive
description: >-
  Behavior area covering receive-side processing of protected packets before
  frame handling, ACK generation, recovery, or application processing.

workflows:
  - packet/endpoint/receive_protected_packet
  - packet/endpoint/remove_header_protection
  - packet/endpoint/remove_payload_protection

notes:
  - This area excludes frame handling, ACK generation, recovery, and application processing.
```

### Semantic area responsibilities

A semantic area owns:

- a behaviorally coherent semantic boundary
- a list of workflows in that area

The `semantic-areas/` scope determines that the file is a semantic area.

Semantic area files should not define a top-level `kind` field to repeat the entity type.

### Semantic area workflows

`workflows` references workflows.

The `workflows` field is the semantic area's direct workflow ownership list.

A workflow should be listed by exactly one semantic area once semantic areas are adopted for a model.

During migration, tools may warn rather than fail when workflows are not listed by any semantic area.

A workflow must not be listed by more than one semantic area.

### Semantic area non-goals

Semantic areas must not model:

- source document sections
- requirements groups
- user stories
- epics
- use cases
- product journeys
- implementation modules
- component packages
- services
- planning task groups

Semantic areas must not own components.

Semantic areas should not reference components.

Components remain organized by modules and implement capabilities and interfaces.

Semantic areas should stay intentionally small.

They should own only workflows.

Related roles, capabilities, interfaces, entities, events, state machines, and decisions are discovered through the owned workflows and ordinary model references rather than repeated in semantic area files.

Do not add separate ownership objects, component references, source references, or supporting model-element lists to semantic area files in the initial design.

### Difference from modules

A semantic area describes behavioral organization.

A module describes implementation organization, ownership, packaging, or component boundaries.

Use:

```text
SemanticArea -> workflows
Module       -> components
```

Do not use modules as semantic behavior areas.

Do not use semantic areas as implementation packages.

### Semantic top-down modeling

For complex source-backed modeling, prefer semantic top-down modeling.

Recommended process:

```text
1. Survey the source corpus.
2. Identify semantic areas.
3. Identify behaviorally relevant entities and state owners.
4. Identify relationships and dependencies between areas and concepts.
5. Identify roles and protocol/system participants.
6. Identify lifecycle constraints and state machines.
7. Define behaviorally meaningful workflows owned by semantic areas.
8. Define capabilities as stable responsibilities under workflow context.
9. Add events only for meaningful observable occurrences.
10. Add decisions for modeling boundaries, tradeoffs, and rationale.
11. Add external traceability from source evidence to model elements.
12. Review area-level gaps and generation readiness.
```

Do not start by turning every source section, paragraph, requirement, or normative sentence into a workflow or capability.

Source sections are evidence and traceability anchors.

They are not the primary model decomposition unit.

Section-level modeling remains useful later as a deepening, audit, and traceability refinement step.

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

A workflow step should be used when the model must explain who does what with whom.

Object workflow steps provide explicit role context through `from` and optional `to`.

### Workflow triggering

`triggered_by` references events.

Meaningful failure, timeout, retry, and recovery paths may be represented as separate workflows triggered by events.

`triggered_by` should reference the event that makes the workflow behaviorally eligible to start from the perspective of the workflow's primary role.

It should not reference merely any upstream causal event if that event is not observable by, or behaviorally available to, the role that starts the workflow.

For example, a client workflow that exchanges an OAuth authorization code for tokens should not be triggered by the server-side event that the authorization code was issued if the client only learns about the code when the browser delivers the authorization callback.

In that case, the client workflow should be triggered by an explicit callback-delivered or code-received event.

This keeps workflow causality aligned with observable behavior and avoids hidden assumptions in generated diagrams or implementation scaffolds.

### Workflow grouping

Related workflows may be grouped by semantic area.

Directories may still be used as namespaces for related workflows.

A semantic area should be used when a workflow grouping has source-of-truth behavior-model meaning.

Do not introduce separate `Scenario`, `Use Case`, `Story`, or `Journey` entities for behavior grouping.

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

`uses` is ordered.

The order of entries is meaningful and represents ordered decomposition within the execution context of the parent capability.

A used capability should only be placed in `uses` when the parent capability and its workflow-step context are sufficient for an implementer or code generator to understand where the sub-capability belongs.

If a sub-capability needs its own sender, receiver, observable message, callback, protocol exchange, externally meaningful local action, or role ownership that is not clear from the parent context, it should be represented as a workflow step instead.

Do not use `Capability.uses` to hide role interactions.

`uses` does not model branching, loops, retries, concurrency, exception handling, data flow, transaction boundaries, or runtime scheduling.

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

## Implementation guidance

Implementation guidance may live beside a BehavioML model.

It is not part of the behavior-first source model.

Implementation guidance may include:

- human-facing implementation notes
- `AGENTS.md` instructions for code-generation agents
- code-generation profiles
- OpenAPI, AsyncAPI, JSON Schema, protobuf, or other technical contracts
- framework, language, runtime, or storage choices
- security or deployment guidance

Recommended shape:

```text
implementation/
├── README.md
├── AGENTS.md
├── codegen-profile.yaml
└── contracts/
    └── openapi.yaml
```

`README.md` explains the implementation guidance package to humans.

`AGENTS.md` instructs code-generation agents.

`codegen-profile.yaml` captures structured implementation choices.

Technical contracts may define HTTP routes, payload schemas, message schemas, or service contracts.

Implementation guidance must not become a hidden behavior model.

If guidance needs behavior that is missing from the BehavioML model, the behavior should either be added to the model or explicitly marked as out of scope.

---

## Initial validator scope

A first validator should check structural consistency, not final schema completeness.

Suggested initial checks:

1. Every YAML file parses successfully.
2. No YAML file contains top-level `id`, `ids`, `uuid`, or `uuids`.
3. References do not use relative filesystem forms.
4. SemanticArea `workflows` references resolve under `workflows/`.
5. SemanticArea files do not use top-level `kind`, `owns`, `model_refs`, or component reference fields.
6. A workflow listed by more than one semantic area is reported.
7. Workflow role references resolve under `roles/`.
8. Workflow `steps` references resolve under `capabilities/`.
9. Workflow `triggered_by` references resolve under `events/`.
10. Workflows do not reference components directly.
11. Capability `uses` references resolve under `capabilities/`.
12. Capability `requires` references resolve under `interfaces/`.
13. Capability `events` references resolve under `events/`.
14. Component implemented capabilities resolve under `capabilities/`.
15. Component implemented interfaces resolve under `interfaces/`.
16. Component `belongs_to` resolves under `modules/`.
17. State machine `entity` resolves under `entities/`.
18. State machine transition events resolve under `events/`.
19. State machine transition source states, if validated, may be scalar or array-valued.
20. State machine transition target states, if validated, are scalar.
21. Decision `affects` entries use typed references and resolve to existing model entities.
22. `generated/` directories are ignored as source-of-truth input.
23. Capability `uses` entries resolve under `capabilities/` and are treated as ordered decomposition.

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
- whether every workflow must be listed by a semantic area
- whether workflow directories imply a formal scenario entity
- implementation-specific behavior

These may be explored later.
