# 0006 - BehavioML and UML boundary

## Status

Proposed.

This note clarifies the relationship between BehavioML and UML-like diagrams.

BehavioML may generate familiar diagram forms such as state-machine diagrams and sequence diagrams.

That does not mean BehavioML adopts UML's general-purpose modeling scope or metamodel.

---

## Context

Recent modeling work introduced sequence-diagrammable workflow steps:

```yaml
steps:
  - from: client
    to: user_agent
    capability: oauth/redirect_to_authorization_server
    label: Redirect to authorization server

  - from: authorization_server
    capability: oauth/validate_redirect_uri
    label: Validate redirect URI
```

This makes workflows easier to render as Mermaid `sequenceDiagram` views.

That raises a useful concern: BehavioML should avoid becoming a lighter clone of UML.

---

## Position

BehavioML may use UML-like diagrams as generated views.

Diagrams are views, not the language.

The source model remains behavior-first and centered on:

- workflows
- roles
- capabilities
- interfaces
- components
- modules
- events
- entities
- state machines
- decisions

BehavioML should describe behaviorally relevant responsibilities, interactions, events, and lifecycle constraints.

It should not become a general-purpose software modeling language.

---

## What BehavioML intentionally keeps

BehavioML keeps a small subset of concepts that are useful for behavior-first architecture modeling:

- roles as functional participants
- workflows as meaningful behavioral scenarios
- capabilities as stable responsibilities
- events as observable occurrences
- state machines as lifecycle constraints
- interfaces as architectural dependency points
- components and modules as implementation and ownership anchors
- decisions as rationale

Generated diagrams may include:

- state-machine diagrams
- sequence diagrams
- relationship/inspection graphs

These diagrams are derived from the model.

They are not independent sources of truth.

---

## What BehavioML intentionally avoids

BehavioML should not model implementation structure such as:

- classes
- objects
- methods
- attributes
- inheritance
- composition
- aggregation
- visibility
- object lifetimes
- call stacks
- package dependencies as code structure

BehavioML should also avoid turning workflows into executable control-flow models.

Do not add inline workflow constructs such as:

- `if` / `else`
- loops
- branches
- guards
- `alt`
- `opt`
- `par`
- retries as embedded control flow
- exception handling blocks
- activity-diagram logic

When alternative behavior matters, model it as a separate workflow, event, state transition, or decision.

---

## Difference from UML

BehavioML can generate diagrams that look familiar to UML users.

That is intentional when the diagram form is useful.

However, BehavioML differs from UML in scope and source-of-truth rules:

| Area | UML tendency | BehavioML position |
| --- | --- | --- |
| Scope | General-purpose software modeling | Behavior-first architecture modeling |
| Source of truth | Multiple diagram types may be edited independently | YAML model is the source of truth; diagrams are generated views |
| Structure | Classes, objects, associations, inheritance | No class/object modeling |
| Workflows | May become activity/control-flow diagrams | One meaningful scenario per workflow; no inline branching |
| Interactions | Sequence diagrams may contain rich control constructs | Minimal subset: participants, messages, notes |
| Responsibilities | Often tied to structural elements | Capabilities are stable behavioral responsibilities |
| Roles | Often actors or lifelines | Functional participants in a behavior |

---

## Sequence diagram boundary

BehavioML sequence views should remain intentionally small.

The initial supported subset should be limited to:

- participants
- messages
- notes over roles

Avoid adding Mermaid/UML sequence constructs unless there is strong model pressure:

- `alt`
- `opt`
- `loop`
- `par`
- `critical`
- `break`
- activation/deactivation

If these constructs seem necessary, first consider whether the behavior should be represented as:

- another workflow
- an event-triggered workflow
- a state-machine transition
- a decision note
- capability decomposition via `uses`

---

## Design principle

BehavioML may generate UML-like diagrams, but it should not adopt UML's general-purpose metamodel.

The model should stay small, explicit, behavior-first, and source-of-truth oriented.

A useful test is:

```text
Would this concept help explain behavior, responsibility, observability, lifecycle, or architectural rationale?
```

If not, it probably does not belong in BehavioML.

---

## Current position

Use familiar diagram forms when they are useful.

Keep diagrams generated from the model.

Do not make diagrams independent sources of truth.

Do not add class/object/method modeling.

Do not add executable workflow control flow.

Keep sequence diagrams to a minimal subset until real examples justify more.
