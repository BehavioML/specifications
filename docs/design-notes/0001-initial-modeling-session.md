# Initial Modeling Session

This document captures the initial reasoning and decisions behind BehavioML v0.1.

It is not a stable specification. It is a design note intended to preserve context for future work.

## Background

BehavioML started from the observation that modern AI-assisted development needs a system model that is useful to both humans and agents.

The initial discussion compared several existing approaches:

- UML
- CASE tools
- C4
- Mermaid
- draw.io / Excalidraw
- Node-RED-style flow editors
- Architecture-as-Code tools
- Spec-driven development workflows

The conclusion was that existing tools either focus too much on static structure or treat diagrams as drawings rather than semantic models.

BehavioML should instead model systems using behavior, responsibilities, state, events, implementation mappings, and decisions.

## Foundational Direction

The central idea is:

```text
Behavior
    -> Capabilities
    -> Interfaces
    -> Components
    -> Modules
```

State is modeled separately:

```text
Workflow
    emits Event

Event
    triggers State Machine

State Machine
    belongs to Entity
```

Architecture is not modeled directly.

Architecture emerges from the model.

## Key Decisions

### Use YAML as the model format

YAML was selected as the likely source format because it is:

- readable
- diffable
- easy for agents to generate and modify
- compatible with Git-based review
- suitable for one-file-per-entity modeling

The YAML schema is intentionally not frozen yet.

The schema should emerge from real modeling examples.

### One file per entity

Each model entity should live in its own file.

This improves:

- Git diffs
- semantic review
- merge behavior
- agent navigation
- human comprehension

Large collection files should be avoided.

### File paths define identity

BehavioML should not use explicit IDs, UUIDs, or duplicated internal names.

The path of the file inside the model tree is the entity identity.

Example:

```text
capabilities/auth/validate_user.yaml
```

Identity:

```text
auth/validate_user
```

### References are absolute

Relative references are forbidden.

Allowed:

```text
auth/validate_user
```

Forbidden:

```text
../validate_user
./validate_user
validate_user
```

This keeps references stable and mechanically refactorable.

### Workflows must not reference components

A workflow describes behavior.

It should not know which component implements that behavior.

Workflows use capabilities and emit events.

### Capabilities are reusable responsibilities

Capabilities are the key bridge between behavior and implementation.

A capability may be atomic or composite.

Composite capabilities allow repeated behavior sequences to be extracted and reused.

This is the semantic equivalent of DRY.

### Interfaces are architectural dependencies

The initial term considered was `Contract`, but `Interface` was chosen because it is easier for engineers to understand.

Interfaces are not necessarily programming-language interfaces.

They represent architectural dependency points.

A capability may require an interface.

A component may implement an interface.

### Components describe implementation

Components implement capabilities and interfaces.

Components should not be used to describe behavior directly.

### Modules describe organization

Modules are for ownership, packaging, and boundaries.

They are not behavior containers.

### Events connect workflows and state machines

Workflows do not own state transitions.

State machines own transitions.

Workflows emit events.

Events trigger transitions.

This avoids duplicating transition information in both workflows and state machines.

### State machines are first-class

State machines contain information that cannot be derived safely from workflows.

They define what is allowed, not merely what happens.

### Entities own state

State machines belong to entities.

Examples:

- User
- Order
- Session
- Stream
- QUIC Connection
- QUIC Stream

### Decisions preserve rationale

Decisions explain why a system is shaped the way it is.

They are especially important because architecture is emergent.

Decisions capture constraints, tradeoffs, and rejected alternatives.

## Explicit Non-Goals

BehavioML should not model:

- classes
- inheritance
- private methods
- framework details
- implementation patterns
- visual layout as source of truth

Those belong in source code or generated views.

## Open Questions

### YAML shape

The exact YAML schema remains intentionally open.

The schema should be derived while modeling real systems.

### Actors and roles

Protocols such as QUIC, WHIP, and MOQ may require concepts such as:

- client
- server
- publisher
- subscriber
- relay

It is not yet clear whether these should be first-class entities or properties on workflows/components.

### Data model depth

Entities currently own state, but it is not yet decided whether they should also model fields/properties.

BehavioML should avoid becoming an ERD or class-modeling system unless that information proves necessary.

### Interface detail

Interfaces exist as architectural dependency points.

It is not yet decided whether they should define operations, message shapes, or only semantic contracts.

### State transition syntax

State machines own transitions, but the exact representation of transitions is not yet defined.

Events are expected to drive transitions.

### Generated views

Architecture, flow diagrams, dependency diagrams, and state diagrams should be generated views.

The exact view model is not defined yet.

## Validation Strategy

The next step is not to freeze the YAML schema.

The next step is to validate the meta-model against real examples.

The recommended first validation example is the QUIC connection lifecycle.

QUIC is useful because it has:

- explicit protocol behavior
- events
- state machines
- entities such as connection and stream
- client/server roles
- constraints and lifecycle rules

The first example should focus only on the QUIC connection lifecycle, not the entire RFC.

## Suggested Workflow For The Next Session

1. Read the current README.
2. Read this design note.
3. Create `examples/quic/` as an exploratory example.
4. Model QUIC connection lifecycle in plain Markdown first.
5. Derive candidate YAML files from the model.
6. Update the meta-model only when the example exposes a real gap.
7. Avoid generating many files mechanically before the conceptual structure is clear.

## Current Conceptual Model

```text
Workflow
    uses Capability
    emits Event

Capability
    uses Capability
    requires Interface

Component
    implements Capability
    implements Interface
    belongs to Module

Event
    triggers State Machine

State Machine
    belongs to Entity

Decision
    affects any entity
```

## Design Bias

BehavioML should be:

- behavior-first
- state-aware
- Git-native
- visual-first but text-backed
- useful to humans and agents
- strict about information ownership
- resistant to duplication and drift

The goal is not to recreate UML.

The goal is to create a practical semantic model for real systems and specifications.
