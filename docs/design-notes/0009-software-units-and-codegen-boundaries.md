# 0009 - Software units and codegen boundaries

## Status

Proposed.

This note captures lessons from experimenting with a downstream software-unit layer for the QUIC model in Quiver.

The experiment explored whether BehavioML can guide implementation structure without turning the core language into a class model, UML model, framework profile, or code-generation DSL.

---

## Context

BehavioML is behavior-first.

It models workflows, roles, capabilities, interfaces, components, entities, state machines, events, and decisions.

That is enough to describe behavior and many responsibility boundaries, but it is not always enough to safely generate or refactor implementation structure.

A code generator or implementation agent still needs to know things such as:

- which software responsibilities should exist;
- which state owners must stay explicit;
- which protocol or technical boundaries must not be blurred;
- which decision spines should remain visible;
- which responsibilities should not be invented with generic names;
- which existing code concentrations are intentional versus accidental.

QUIC made this visible because a behavior-first model can naturally expose connection lifecycle, packet number spaces, packet protection keys, streams, transport parameters, path validation, and 0-RTT behavior, but production code also needs packet format boundaries, TLS adapter boundaries, timer ownership, flow-control ownership, error mapping, and recovery/congestion boundaries.

Those implementation boundaries are useful, but they should not be folded into BehavioML core as classes or framework concepts.

---

## Position

BehavioML should not model classes directly.

A downstream software-unit layer may be useful beside a BehavioML model.

A software unit is a named implementation responsibility boundary derived from BehavioML behavior and relevant source specifications.

A software unit is not necessarily a class, file, module, component, service, adapter, function group, or generated artifact.

It may later map to one of those implementation forms, but that mapping is a later projection.

The BehavioML model remains the source of truth for behavior.

The software-unit layer may assign implementation responsibility for existing behavior, but it must not define hidden behavior.

---

## Recommended phase separation

The QUIC experiments worked best when the work was split into phases:

```text
Phase 1: Unit discovery / decomposition
         discover the minimum useful responsibility boundaries

Phase 2: Composition
         show how accepted units collaborate around workflows and decision spines

Phase 3: Codegen readiness / guidance
         identify missing scope notes, contracts, and implementation constraints

Phase 4: Current-code reconciliation, if brownfield
         compare intended boundaries with existing implementation structure
```

Mixing these phases produced noisy results.

If unit discovery also tries to compose, it tends to over-create abstractions.

If composition also tries to invent units, it tends to re-open decomposition.

If codegen guidance is introduced too early, it can bias the model toward a particular implementation style before the behavior-derived boundaries are understood.

---

## Software unit discovery

The useful rule is not:

```text
Create every unit that might exist.
```

The useful rule is:

```text
Create the smallest useful set of stable units that codegen must not invent.
```

A unit is usually justified when omitting it would likely cause an implementation agent to:

- hide state ownership;
- blur a protocol or technical boundary;
- scatter a meaningful decision spine;
- create generic managers, processors, helpers, or services;
- mix unrelated responsibilities;
- make a behaviorally important rule hard to test.

A unit should normally represent at least one of:

- a state owner;
- a stable protocol or technical boundary;
- a protocol artifact with behaviorally important structure;
- a decision spine that should remain visible;
- an independently testable rule or mechanism;
- an external dependency boundary;
- an implementation-support responsibility required for modeled behavior.

A unit should not normally represent:

- the client side of one workflow;
- the server side of one workflow;
- a generic endpoint participant;
- a workflow step restated as a noun;
- a capability mechanically converted to a unit;
- an entity mechanically converted to a unit;
- a class-shaped guess;
- a temporary analysis category.

Roles and participants are discovery evidence, not automatically software units.

---

## Avoiding entity bias and participant bias

Two opposite failure modes appeared.

### Entity bias

Starting only from entities and capabilities produced mostly state owners.

That found useful units such as packet number space, stream, connection, path, and key set, but missed active boundaries such as packet ingress, packet format, TLS handshake interface, Retry integrity, and protected packet receive.

### Participant bias

Starting too strongly from workflows and roles produced too many role-side artifacts.

Examples include units shaped like:

```text
client establishment participant
server establishment participant
ACK exchange participant
stream transfer participant
```

These are useful during analysis, but they are often not stable software responsibilities.

The better rule is:

```text
Use roles and workflow participation to discover responsibilities.
Promote only stable responsibilities to software units.
```

---

## Suggested unit file shape

A lightweight experimental unit shape was sufficient:

```yaml
name: Human readable name

from:
  - model or source references that justify the unit

owns:
  - state or durable data controlled by the unit

does:
  - responsibilities or operations the unit preserves

uses:
  - units/other-unit.yaml

refs:
  - RFC or specification references, when useful

notes:
  - short human explanation or uncertainty
```

Important constraints:

- use `name`, not `id`;
- do not add `classes`, `methods`, `layers`, `flows`, or `groups`;
- do not add language-specific signatures;
- omit empty fields;
- use notes only as non-normative human annotation;
- do not make the unit layer a second workflow model.

This shape is intentionally experimental and should not be standardized before more dogfooding.

---

## Composition

Composition should come after unit discovery.

Composition does not rediscover units.

Composition answers questions such as:

- what are the main decision spines;
- which state owners does each spine touch;
- which technical boundaries does each spine cross;
- which dependencies are allowed;
- which ownership mistakes are forbidden;
- which units should remain abstract;
- which units must not become one-to-one classes.

Composition should not duplicate workflow order.

The workflow remains the source of scenario ordering.

The composition layer explains how implementation responsibilities collaborate to realize those workflows.

---

## RFC-scoped implementation guidance

Some details needed by implementation are already defined by source specifications such as RFCs.

The downstream layer should not rewrite those specifications.

However, source specifications usually do not say:

- which subset is in scope for this model;
- which unit owns a state or boundary;
- which errors are modeled now;
- which extension points are out of scope;
- which implementation choices are allowed for codegen;
- which generated code would be unsafe.

A useful artifact is therefore not a duplicate protocol contract, but an RFC-scoped implementation guidance note.

Examples:

```text
packet-format-contract.md
  states the modeled packet/frame subset and the boundary between parsing and applying behavior

tls-adapter-contract.md
  states the QUIC/TLS dependency shape needed by this model

timer-and-retention-contract.md
  states ownership for idle, close, drain, validation, and key discard timing

codegen-target-scope.md
  states whether generation may create docs, scaffolds, tests, partial code, or production code
```

These notes may select scope and assign ownership.

They must not invent behavior outside the BehavioML model and the referenced source specifications.

---

## Brownfield reconciliation

When existing code exists, compare it after unit discovery and composition.

Existing code is evidence, not authority.

The intended software-unit shape may differ from the current code, especially when the current code has grown organically.

In the QUIC experiment, the current implementation had a large `QuicConnection` that already contained real behavior:

- packet ingress and receive path;
- TLS integration;
- packet protection key state;
- packet number spaces;
- stream send and receive;
- flow-control fields;
- ACK and recovery hooks;
- timers and retention;
- path validation;
- connection ID state;
- close and error handling.

A large connection object is not automatically wrong.

Mature QUIC stacks also have central connection objects.

The issue is whether the connection object owns every state and applies every frame directly, or whether it is surrounded by clear boundaries such as packet format, TLS adapter, stream/session layer, sent packet/recovery manager, path validator, connection ID manager, timers, and visitor/session callbacks.

The software-unit layer is useful because it gives a vocabulary for this comparison without requiring a premature class model.

---

## Codegen readiness

A software-unit layer does not imply codegen is safe.

Before codegen, the model or adjacent guidance should say:

- which workflows are in scope;
- which units are allowed to become code artifacts;
- which units must remain abstract decision spines;
- which contracts are missing;
- which external dependencies are assumed;
- whether the target is documentation, scaffolding, tests, partial implementation, or production code.

For QUIC, production codegen was not safe after unit discovery and composition.

The model was useful for responsibility review and refactor planning, but missing details remained around packet/frame contracts, TLS adapter shape, timer ownership, flow-control lifecycle, key lifecycle, error mapping, and RFC 9002 recovery.

That is the desired failure mode.

A generator should report these gaps instead of inventing generic code structure.

---

## Implications for BehavioML core

Do not add classes to BehavioML core.

Do not add actors as a new concept when existing `roles` already cover active workflow participants.

Clarify instead:

- roles are active workflow participants;
- interfaces are dependency or boundary participants;
- entities are state owners;
- capabilities are responsibilities;
- workflows provide ordered observable scenario context;
- downstream software units may derive from all of the above, but are not core BehavioML elements.

The software-unit layer belongs under `implementation/` or another downstream area, not under `model/`.

Example:

```text
example/
├── model/
├── generated/
└── implementation/
    ├── README.md
    ├── notes.md
    ├── units/
    ├── composition.md
    ├── dependency-rules.md
    └── codegen-readiness.md
```

This keeps the boundary clear:

```text
BehavioML owns behavior.
Implementation guidance owns implementation responsibility mapping.
Code owns executable details.
```

---

## Open questions

This note is exploratory.

Questions to revisit after more dogfooding:

- Should software units remain completely outside the metamodel, or become an optional downstream profile?
- Should validators know anything about software-unit files, or should they remain purely documentation for agents?
- Is the simple unit YAML shape enough across non-protocol domains?
- How much composition should be structured versus prose?
- What is the smallest useful codegen-readiness checklist?
- How should existing code reconciliation be represented without turning BehavioML into a reverse-engineered class model?

The current direction is to keep the core language simple and collect more examples before standardizing any software-unit syntax.
