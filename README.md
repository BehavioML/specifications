# BehavioML Specification v0.1

Behavior-first system modeling language.

BehavioML models systems using:

- Workflows
- Roles
- Capabilities
- Interfaces
- Components
- Modules
- Events
- Entities
- State Machines
- Decisions

Architecture is not modeled directly.

Architecture emerges from the model.

## Vision

BehavioML is a behavior-first system modeling language designed for both humans and AI agents.

The goal is to model systems using behavior, responsibilities, state, and constraints, allowing architecture to emerge naturally from the model instead of being modeled explicitly.

BehavioML is:

- Visual-first
- Git-native
- AI-native
- Semantic
- Architecture-agnostic

BehavioML is not UML, BPMN, or Architecture-as-Code.

It is a system model.

---

# Core Philosophy

## Principle 1: The model is the source of truth

Editors, diagrams, architecture views, documentation, and generated artifacts are views of the model.

Only the model is authoritative.

---

## Principle 2: Every piece of information has a single owner

Information must exist in exactly one place.

If information appears in multiple places, the model is wrong.

| Entity | Owns |
|----------|----------|
| Workflow | Behavior |
| Role | Workflow participation |
| Capability | Responsibility |
| Interface | Architectural contracts |
| Component | Implementation |
| Module | Organization |
| Event | Domain events |
| Entity | State ownership |
| State Machine | State transitions |
| Decision | Rationale |

---

## Principle 3: Behavior comes before structure

Behavior is the primary concern.

Structure exists to implement behavior.

```text
Behavior
    ↓
Responsibilities
    ↓
Implementation
```

---

## Principle 4: Workflows are first-class citizens

Workflows are the primary entry point for understanding a system.

A workflow describes:

- actions
- decisions
- branching
- failures
- emitted events

Workflows never describe implementation.

---

## Principle 5: Capabilities are first-class citizens

Capabilities describe responsibilities.

Examples:

```text
validate_user
authenticate_user
store_user
send_email
create_stream
restart_ice
```

Capabilities:

- are reusable
- are implementation-independent
- can be composed
- can be shared across workflows

---

## Principle 6: Components implement capabilities and interfaces

Components describe implementation.

Examples:

```text
AuthService
PromptDetector
UserRepository
IndexedDbStorage
```

Components do not describe behavior.

Components implement behavior.

---

## Principle 7: Modules organize components

Modules describe:

- ownership
- packaging
- boundaries

Modules do not describe behavior.

---

## Principle 8: Decisions are explicit

Decisions answer:

```text
Why?
```

Not:

```text
What?
```

---

## Principle 9: Architecture is not an entity

Architecture is an emergent property.

Architecture is derived from:

```text
Workflows
Roles
Capabilities
Interfaces
Components
Modules
Decisions
```

Architecture is a generated view.

Architecture is not a source of truth.

---

## Principle 10: The filesystem is part of the model

Paths are semantic.

The filesystem defines identity and namespace.

Example:

```text
capabilities/auth/validate_user.yaml
```

Identity:

```text
auth/validate_user
```

---

## Principle 11: One file equals one entity

Every entity is represented by exactly one file.

---

## Principle 12: Paths are identities

BehavioML does not use:

- IDs
- UUIDs
- Internal names

Identity is derived from the file path.

---

## Principle 13: References are always absolute

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

---

## Principle 14: Semantic DRY

Behavior must not be duplicated.

Repeated behavior should be extracted into reusable capabilities.

---

# Core Entities

## Workflow

Describes behavior.

Owns:

- actions
- decisions
- branching
- emitted events

A workflow is expressed as steps through capabilities.

---

## Role

Represents a functional participant in a workflow.

Examples:

```text
client
server
endpoint
publisher
subscriber
relay
```

A role is not:

- a Component
- an Entity
- a Module
- an implementation

Roles describe who participates in behavior, not how that behavior is implemented.

---

## Capability

Describes responsibility.

Capabilities may be atomic or composite.

---

## Interface

Describes an architectural dependency.

Examples:

```text
user_repository
storage_provider
llm_provider
```

Interfaces separate responsibility from implementation.

---

## Component

Describes implementation.

Implements:

- capabilities
- interfaces

---

## Module

Describes organizational boundaries.

---

## Event

Represents something that happened.

Examples:

```text
user_created
payment_completed
ice_restart_completed
```

---

## Entity

Represents ownership of state.

Examples:

```text
User
Order
Session
Prompt
Stream
WhipSession
```

---

## State Machine

Owns:

- states
- transitions
- lifecycle constraints

State machines describe what is allowed.

---

## Decision

Explains rationale.

---

# Relationships

```text
Workflow
    involves
Role

Workflow
    steps through
Capability

Capability
    uses
Capability

Capability
    requires
Interface

Component
    implements
Capability

Component
    implements
Interface

Component
    belongs_to
Module

Workflow
    emits
Event

Event
    triggers
StateMachine

StateMachine
    belongs_to
Entity
```

---

# State Ownership Rules

Workflows do not own transitions.

State machines own transitions.

Workflows emit events.

Events trigger state transitions.

This prevents:

- duplication
- circular references
- workflow-state coupling

---

# Architecture Formula

```text
Architecture =
    Workflows
  + Roles
  + Capabilities
  + Interfaces
  + Components
  + Modules
  + Decisions
```

Architecture is derived.

Architecture is never modeled directly.

---

# Explicitly Out Of Scope

BehavioML does not model:

- Classes
- Objects
- Inheritance
- Aggregation
- Composition
- Private Methods
- Framework Details
- Implementation Patterns

These belong in source code.

---

# Repository Layout

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
