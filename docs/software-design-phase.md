# Software design phase

This document describes the downstream software-design phase that can follow a BehavioML model.

It is an operational view that summarizes the design-note direction around implementation guidance, software units, composition, codegen readiness, and brownfield reconciliation.

It is not a BehavioML core metamodel change.

---

## Purpose

BehavioML remains behavior-first.

The BehavioML model describes:

- workflows;
- roles;
- capabilities;
- interfaces;
- components;
- modules;
- entities;
- state machines;
- events;
- decisions.

That model is useful for understanding behavior and responsibilities, but production implementation still needs additional structure:

- implementation responsibility boundaries;
- state ownership boundaries;
- technical/protocol boundaries;
- decision spines that should remain readable;
- dependency direction;
- codegen scope;
- implementation guidance;
- brownfield reconciliation when code already exists.

The software-design phase provides that downstream bridge without turning BehavioML into UML, a class model, an ERD, an OpenAPI document, or a code-generation language.

---

## Pipeline

The intended pipeline is:

```text
Source specification / RFC / SDD
  ↓
BehavioML model
  behavior, workflows, roles, capabilities, entities, state machines, decisions
  ↓
Software design phase
  software units, composition, codegen readiness, current-code reconciliation
  ↓
Implementation guidance / codegen profile
  target scope, contracts, agent instructions, tests, scaffolding policy
  ↓
Generated or handwritten code
```

The BehavioML model owns behavior.

The software-design phase owns implementation responsibility mapping.

Implementation guidance owns technology-specific constraints and codegen policy.

Code owns executable details.

---

## Directory shape

For an example or downstream project:

```text
example/
├── model/
├── generated/
└── implementation/
    ├── README.md
    ├── notes.md
    ├── units/
    │   └── *.yaml
    ├── composition.md
    ├── dependency-rules.md
    ├── codegen-readiness.md
    ├── current-code-reconciliation.md       # brownfield only
    ├── refactor-slices.md                   # brownfield only
    ├── AGENTS.md                            # optional
    ├── codegen-profile.yaml                 # optional
    └── contracts/                           # optional technical contracts
```

The `implementation/` directory is downstream of the model.

It must not define hidden behavior that is absent from `model/` or the referenced source specifications.

---

## Phase 1: software-unit discovery

### Goal

Discover the smallest useful set of stable implementation responsibility boundaries.

The output should help a code generator or implementation agent avoid inventing anonymous managers, processors, helpers, or services.

### Inputs

- `model/`
- source specifications referenced by the model, such as RFCs
- design notes and traceability reports, if available
- implementation guidance only if it does not bias discovery toward an existing code shape

For greenfield or model-first work, do not inspect existing code during this phase unless the explicit goal is brownfield reconciliation.

### Output

```text
implementation/README.md
implementation/notes.md
implementation/units/*.yaml
```

### Unit criteria

Create a unit only when omitting it would likely cause implementation work to:

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

- a role wrapper;
- a workflow side such as client side or server side;
- a workflow step restated as a noun;
- a capability mechanically converted to a unit;
- an entity mechanically converted to a unit;
- a class-shaped guess;
- a temporary analysis category.

### Suggested unit YAML shape

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

Rules:

- use `name`, not `id`;
- omit empty fields;
- use `owns` only for actual state or durable data ownership;
- do not add `classes`, `methods`, `layers`, `groups`, or `flows`;
- do not add language-specific signatures;
- notes are non-normative and must not define behavior.

### Gate

Before moving to composition, review:

- whether the unit set is intentionally limited;
- whether role-side analysis was over-promoted into units;
- whether important implementation boundaries are missing;
- whether state owners are explicit enough;
- whether any unit is just a disguised class guess;
- whether codegen would be forced to invent missing structure.

---

## Phase 2: composition

### Goal

Explain how accepted units collaborate around the BehavioML workflows.

Composition uses the accepted unit set as vocabulary.

It does not rediscover units.

It does not duplicate workflow order as a new flow model.

### Inputs

- accepted `implementation/units/*.yaml`
- `model/`
- source specifications referenced by the model
- implementation guidance, if present

### Output

```text
implementation/composition.md
implementation/dependency-rules.md
```

### Composition questions

For each major decision spine or behavior area:

- what is the purpose;
- which workflows/capabilities justify it;
- which entry boundary is involved;
- which units are used;
- which state owners are touched;
- which decisions should remain visible;
- which responsibilities are delegated;
- which responsibilities are explicitly not owned;
- what should codegen avoid doing.

### Dependency rules

`dependency-rules.md` should express ownership and dependency direction at the responsibility level.

It should not be a language import graph.

Useful rule shapes:

```text
Protected packet receive may use packet protection key set, packet number space, and packet format.
Protected packet receive must not own key lifecycle state.
Packet format must not mutate connection lifecycle state.
TLS handshake interface must not own QUIC packet number spaces.
Connection may associate state owners but must not absorb their responsibilities.
```

### Gate

Before moving to codegen readiness, review:

- whether composition added hidden behavior;
- whether composition duplicated workflow order;
- whether units were expanded without a discovery gate;
- whether dependency rules are clear enough to constrain implementation agents.

---

## Phase 3: codegen readiness

### Goal

Decide whether the model plus units plus composition is safe for code generation.

The answer may be no.

A useful failure mode is to identify exactly what a generator would otherwise invent.

### Inputs

- `model/`
- `implementation/units/`
- `implementation/composition.md`
- `implementation/dependency-rules.md`
- source specifications
- existing implementation guidance

### Output

```text
implementation/codegen-readiness.md
```

### Questions

`codegen-readiness.md` should answer:

- is codegen safe;
- for which target: docs, scaffold, tests, partial implementation, production;
- which workflows are closest to codegen-ready;
- which workflows are blocked;
- which missing behavior or boundary decisions block codegen;
- which units need more precise contracts;
- which units should remain abstract and not become one-to-one classes;
- which external specifications or profiles are needed;
- which implementation guidance files are missing.

### RFC-scoped implementation guidance

Do not duplicate source specifications such as RFCs.

Instead, write small guidance notes that select scope and assign ownership for this model.

Examples:

```text
packet-format-contract.md
  modeled packet/frame subset and parse/apply boundary

tls-adapter-contract.md
  QUIC/TLS dependency boundary needed by this model

timer-and-retention-contract.md
  ownership for idle, close, drain, validation, and key discard timing

flow-control-contract.md
  modeled send credit, receive credit, final size, blocked behavior, and limit updates

codegen-target-scope.md
  allowed generation target: docs, scaffold, tests, partial code, production code
```

These documents may select scope and assign responsibility.

They must not invent behavior outside the BehavioML model and referenced source specifications.

### Gate

Before codegen, confirm:

- behavior is not hidden in implementation guidance;
- generated target scope is explicit;
- missing contracts are either written or declared out of scope;
- abstract units are not forced into one-to-one classes;
- the generator is instructed to report gaps instead of inventing structure.

---

## Phase 4: brownfield reconciliation

### Goal

Compare the intended software design shape with existing code.

This phase is only for brownfield projects.

Existing code is evidence, not authority.

The intended shape may differ from current code.

### Inputs

- `model/`
- `implementation/units/`
- `implementation/composition.md`
- `implementation/dependency-rules.md`
- `implementation/codegen-readiness.md`
- current implementation code

### Output

```text
implementation/current-code-reconciliation.md
implementation/refactor-slices.md
```

Optional:

```text
implementation/quic-connection-refactor-plan.md
```

or a domain-specific refactor plan for the largest concentration point.

### Reconciliation questions

For each unit or contract area:

- where is this responsibility currently implemented;
- who owns the state today;
- which dependencies exist today;
- what aligns well;
- what is concentrated in an oversized object;
- what is split across multiple files;
- what exists in code but not in the model;
- what exists in the model but not in code;
- what is outside the current model scope.

### Refactor slices

Refactor planning should be staged.

Do not propose one giant rewrite.

For each slice:

- title;
- goal;
- files likely touched;
- responsibility boundary changed;
- behavior that must not change;
- tests needed;
- risk;
- ordering rationale.

Useful slice categories:

```text
Safe mechanical extractions
Behavior-preserving ownership clarifications
Risky semantic changes
Out-of-scope future work
```

### Gate

Before changing code, confirm:

- tests exist around the behavior to preserve;
- the first slice is small and reversible;
- responsibility ownership is clear;
- refactor plans do not blindly implement the unit layer as classes;
- divergence from current code is treated as expected when current code has grown organically.

---

## What belongs where

| Concern | BehavioML model | Software design phase | Implementation/code |
|---|---|---|---|
| observable workflow order | owns | references | implements |
| roles | owns | uses as evidence | maps to runtime participants only if needed |
| capabilities | owns | maps to responsibilities | implements |
| entities/state machines | owns behaviorally relevant state | maps to state owners | implements state and transitions |
| protocol grammar | references source spec | scopes and assigns boundary | parses/builds |
| external adapter shape | names interface | defines guidance if needed | implements adapter |
| class/module/file shape | no | optional later projection | owns |
| codegen target | no | owns | follows |
| hidden behavior | forbidden | forbidden | forbidden |

---

## Anti-patterns

Avoid:

- turning BehavioML into UML or class diagrams;
- creating one software unit per workflow step;
- creating one software unit per capability;
- creating one software unit per entity mechanically;
- creating role-side units such as client participant unless they are stable boundaries;
- using `Manager`, `Processor`, `Helper`, `Service`, `Coordinator`, or `Engine` as fallback names;
- duplicating RFCs as local mini-specs;
- letting implementation guidance define behavior absent from the model;
- generating code when codegen readiness says the boundary is unsafe;
- using existing code as the target architecture without reconciliation.

---

## Relationship to design notes

This document operationalizes the direction from the design notes around:

- implementation guidance boundary;
- lessons from protocol modeling;
- software units and codegen boundaries.

The design notes explain why the boundary exists.

This document describes how to run the phase.

---

## Current status

This process is experimental.

It should be dogfooded on several examples before any software-unit syntax is standardized.

For now:

- software units remain outside BehavioML core;
- validators do not need to understand software units;
- generators may consume the documents experimentally;
- codegen agents should treat missing units or contracts as gaps, not as permission to invent structure.
