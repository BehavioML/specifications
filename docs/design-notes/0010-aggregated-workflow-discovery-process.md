# 0010 - Aggregated workflow discovery process

## Status

Proposed.

This note captures the modeling process learned while dogfooding aggregated workflows against the QUIC BehavioML model.

Design note `0009-aggregated-workflows.md` introduced the minimal metamodel shape:

```yaml
steps:
  - workflow: child/path
    bind:
      child_role: aggregate_role
```

This note describes when and how to create those aggregated workflows.

---

## Problem

Atomic and medium-sized workflows are useful for traceability and local sequence diagrams, but they can be too small for review.

Reviewers often need to see a behavior-domain slice that combines:

- success paths;
- optional paths;
- failure paths;
- terminal paths;
- supporting lifecycle workflows;
- workflows owned by different semantic areas but needed for one behavior question.

At the same time, naive aggregation creates poor models:

- broad semantic buckets;
- role buckets such as all client workflows;
- directory buckets;
- tiny two-workflow aggregates that fragment stronger lifecycle slices;
- fake executable sequences;
- hidden behavior invented by the aggregation pass.

BehavioML needs a repeatable discovery process that finds useful aggregates without turning them into UML use cases, BPMN flows, control flow, or diagram-only review artifacts.

---

## Core principle

Aggregated workflows should answer a behavior-domain review question.

They should not answer merely:

```text
What workflows live in this folder?
What workflows belong to this semantic area?
What workflows have the same primary role?
What workflows mention the same word?
```

A better question is:

```text
Which existing workflows must be reviewed together to understand this behavior boundary?
```

Examples:

```text
How does startup progress from initial attempt to readiness or abort?
How does termination happen through normal close, timeout, reset, or setup failure?
How does stream behavior span transfer, ACK-visible progress, cancellation, and final-size accounting?
How does path continuity span connection IDs, validation, and migration?
```

---

## Process

### 1. Inventory existing workflows

Inspect workflow bodies before creating aggregates.

For each workflow, capture:

- path identity;
- behavior summary from `description`;
- declared roles;
- roles used in direct `steps[].from` and `steps[].to`;
- direct capability references;
- triggered events;
- semantic-area membership;
- related entities, events, and state machines;
- whether it is atomic, medium-sized, or already aggregate-like.

Do not rely on filenames alone.

### 2. Infer candidate review questions

Infer candidate aggregates from multiple signals:

- workflow descriptions;
- semantic-area membership;
- role overlap;
- lifecycle-relevant state machines;
- shared entity, event, or capability concerns;
- implementation composition notes;
- generated report observations;
- likely future collapsed or expanded diagram usefulness.

No single signal is sufficient.

### 3. Classify candidates

Classify each candidate as:

```text
create
defer-to-event-state-view
reject
fold into stronger aggregate
```

Use `create` when the candidate:

- answers a coherent behavior-domain review question;
- composes existing workflows without inventing behavior;
- is not merely a semantic-area, directory, or role bucket;
- has child roles that can be explicitly bound;
- remains understandable with `description` and `notes`;
- would likely be useful as a collapsed or expanded workflow diagram later.

Use `defer-to-event-state-view` when:

- the main value is lifecycle transition coverage;
- important behavior exists only as events or state-machine transitions;
- workflows alone do not explain the lifecycle;
- ordering workflow references as steps would mislead reviewers.

Use `reject` when the candidate is too broad, too small, unrelated, role-based, directory-based, requires invented workflows, or needs new fields such as `main`, `variants`, `cases`, or `outcome` to be understandable.

Use `fold into stronger aggregate` when a small coherent candidate is a natural sub-slice of a stronger lifecycle aggregate.

### 4. Create only strong aggregates

Do not force a fixed number.

Most useful aggregates should contain three or more child workflows, but this is not a schema rule.

A two-workflow aggregate is acceptable only when it is independently useful and not better explained as part of a larger behavior-domain lifecycle.

### 5. Place aggregates semantically

Atomic workflows may be role-oriented.

Aggregated workflows should usually be behavior-domain-oriented.

Prefer paths such as:

```text
workflows/connection/establishment_lifecycle.yaml
workflows/connection/termination_lifecycle.yaml
workflows/path/continuity_lifecycle.yaml
workflows/packet/protected_traffic_lifecycle.yaml
workflows/stream/lifecycle.yaml
```

Avoid placing aggregates under role directories such as:

```text
workflows/client/
workflows/server/
workflows/endpoint/
workflows/endpoints/
```

unless the aggregate is genuinely role-specific.

Avoid technical aggregation directories:

```text
workflows/aggregated/
workflows/review/
workflows/composite/
```

The path should name the behavior-domain slice, not the modeling mechanism.

### 6. Bind roles explicitly

For every child workflow reference:

1. inspect the child workflow;
2. collect roles from `roles.primary`, `roles.participants`, direct `steps[].from`, and direct `steps[].to`;
3. bind every child role explicitly;
4. keep same-name bindings explicit;
5. choose bind targets that express the aggregate context.

Example:

```yaml
steps:
  - workflow: endpoint/validate_path
    bind:
      endpoint: client
      peer_endpoint: server
```

The binding is local to the aggregation site and must not mutate the child workflow.

---

## Aggregate file shape

An aggregate is a normal workflow file.

Recommended shape:

```yaml
description: |
  Connection establishment behavior spans version negotiation, Retry address
  validation, transport parameters, TLS encryption-level progress, optional
  early data, protected traffic readiness, and establishment-time failure paths.

notes:
  - This workflow aggregates existing workflow slices through workflow reference steps.
  - The listed child workflows form a connection establishment behavior-domain slice.
  - The step order is a review order, not necessarily a strict executable runtime sequence.
  - Some referenced workflows may represent alternatives, optional paths, or terminal paths.
  - No behavior is implied beyond the referenced child workflows.

steps:
  - workflow: client/establish_connection
    bind:
      client: client
      server: server
```

Use behavior-first descriptions.

Avoid descriptions such as:

```text
Review...
Endpoints review...
This review artifact...
```

Keep the model file stable and behavior-oriented. The report or skill may discuss review intent; the source model should describe behavior.

---

## Ordering semantics

Aggregated workflow steps are ordered, but the order may be review order rather than a strict executable runtime sequence.

This is acceptable when notes make the intent explicit.

Do not infer hidden control flow from the order.

Do not invent omitted callbacks, redirects, retries, responses, broker deliveries, protocol follow-ups, or failure branches.

If the aggregate would be misleading even with notes, reject it or defer it to an event/state view.

---

## Relationship to semantic areas

Semantic areas still own atomic and medium-sized workflows.

An aggregate may cross semantic areas when the behavior-domain review question requires it.

Crossing semantic areas is not a problem by itself; crossing them merely because they are adjacent, similarly named, or role-overlapping is a problem.

Do not use semantic-area membership alone as the aggregation rule.

---

## Relationship to event/state lifecycle views

Workflow aggregation and event/state lifecycle review are related but separate.

Use aggregated workflows when existing workflows together explain a behavior-domain slice.

Use or defer to event/state views when the important question is transition coverage across an entity lifecycle and the behavior is mostly represented by events and state machines rather than workflows.

Examples of deferred questions:

- complete key discard lifecycle when key discard is only an event/state transition;
- packet-number-space discard lifecycle when only ACK exchange is modeled as a workflow;
- detailed stream send/receive state coverage when workflows do not expose every transition.

---

## Skill implications

A reusable aggregation skill should:

- inspect first;
- infer review questions from the model;
- classify candidates before creating files;
- create only strong aggregates;
- place aggregates by behavior-domain path;
- bind child roles explicitly;
- avoid broad semantic buckets and role buckets;
- avoid standalone two-child sub-slices when they naturally fold into stronger lifecycle aggregates;
- report candidates that should become event/state views instead;
- avoid generated diagrams unless explicitly requested.

A safe skill output should include:

- created aggregate workflow files;
- a generated report documenting candidates, decisions, bindings, uncertainty, and skill-readiness findings.

---

## Non-goals

This process does not introduce:

- `main`;
- `variants`;
- `cases`;
- `outcome`;
- review-view entities;
- executable control flow;
- recursive workflow composition;
- hidden behavior inference;
- aggregate-specific role semantics.

It also does not change `Capability.uses`.

---

## Open questions

Open follow-up questions:

- whether aggregates should eventually be listed by semantic areas or treated as derived/review workflows;
- whether validators should warn differently for role-less aggregated workflows;
- whether generated diagrams should default to collapsed or expanded aggregate rendering;
- whether event/state lifecycle views should become a separate skill phase.
