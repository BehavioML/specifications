# Phase 07 — Aggregated workflows

## Purpose

Create review-level behavior-domain workflow aggregates after atomic and medium-sized workflows, capabilities, events, lifecycle constraints, and decisions are stable enough to compose.

Aggregated workflows reuse existing workflows through workflow reference steps and explicit role bindings.

They help reviewers inspect larger behavior slices without duplicating child workflow steps or inventing hidden behavior.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0009-aggregated-workflows.md`
- `docs/design-notes/0010-aggregated-workflow-discovery-process.md`
- `skills/semantic-top-down-modeling/PLAN.md`

## Preconditions

Phase 06 must be complete.

The model should already contain stable enough:

- semantic areas;
- roles;
- atomic or medium-sized workflows;
- capabilities;
- events;
- entities and state machines;
- modeling decisions.

Do not run this phase before creating atomic workflows. Aggregates compose existing workflows; they must not become a substitute for discovering the underlying behavior.

If no existing workflows are stable enough to compose, stop and report that aggregation is premature.

## Inputs to inspect

Inspect:

- complete `model/workflows/` tree;
- `model/semantic-areas/`;
- `model/state-machines/`;
- `model/events/`;
- `model/capabilities/`;
- progress report;
- generated reports, if present;
- implementation composition notes, if present;
- relevant design notes under `docs/design-notes/`.

Do not rely on filenames alone.

## Allowed changes

Allowed:

- create aggregated workflow files under semantically meaningful workflow directories;
- create or update an aggregation/skill-pass report outside the source model;
- update the progress report;
- make tiny model corrections only when an existing typo prevents a referenced workflow from resolving.

Forbidden:

- modifying existing atomic workflows as part of aggregation;
- duplicating child workflow steps as capability steps;
- adding `main`, `variants`, `cases`, or `outcome`;
- adding review-view entities;
- adding top-level `id` or `kind`;
- adding role buckets such as `client/all.yaml` or `endpoint/all.yaml`;
- adding technical aggregation directories such as `aggregated/`, `review/`, or `composite/`;
- generating diagrams unless explicitly requested;
- modifying generator, validator, explorer, CI, implementation guidance, or production code.

## Aggregate workflow shape

Created aggregate workflows should use only:

```yaml
description: |
  ...

notes:
  - ...

steps:
  - workflow: some/existing_workflow
    bind:
      child_role: aggregate_role
```

Each workflow reference step must contain exactly:

```yaml
workflow: ...
bind: ...
```

Do not add `label`, `from`, `to`, `capability`, `event`, `emits`, or `uses` to workflow reference steps.

Use short scoped workflow references:

```yaml
workflow: client/establish_connection
```

Do not use:

```yaml
workflow: workflows/client/establish_connection
```

The `workflow` field already resolves to `model/workflows/`.

## Description and notes

Use behavior-first descriptions.

Good:

```yaml
description: |
  Stream lifecycle behavior spans stream opening, flow-control-gated data
  transfer, ACK-observable send progress, cancellation, and final-size
  accounting.
```

Avoid:

```yaml
description: |
  Review stream lifecycle behavior.
```

Notes should clarify aggregation semantics without defining hidden behavior:

```yaml
notes:
  - This workflow aggregates existing workflow slices through workflow reference steps.
  - The listed child workflows form a stream lifecycle behavior-domain slice.
  - The step order is a review order, not necessarily a strict executable runtime sequence.
  - Some referenced workflows may represent alternatives, optional paths, or terminal paths.
  - No behavior is implied beyond the referenced child workflows.
```

Do not use notes to add behavior that is missing from referenced child workflows.

## Procedure

### 1. Inventory existing workflows

For each existing workflow, capture:

- path identity;
- behavior summary from `description`;
- declared roles;
- roles used in direct `steps[].from` and `steps[].to`;
- direct capabilities;
- triggered events;
- semantic-area membership;
- related entities, events, and state machines;
- whether it is atomic, medium-sized, or already aggregate-like.

Record the inventory in the phase report, not in source model files.

### 2. Infer candidate review questions

Infer candidate aggregates from behavior questions.

Good candidates answer questions like:

```text
How does this behavior progress from start to meaningful completion or abort?
How do success, optional, failure, and terminal workflows combine into one lifecycle slice?
Which workflows must be seen together to review this behavior boundary?
Which workflows explain a domain behavior better together than separately?
```

Bad candidates answer only:

```text
What are all workflows in this folder?
What workflows share the same primary role?
What workflows belong to this semantic area?
```

Use multiple signals:

- workflow descriptions;
- semantic-area membership;
- role overlap;
- lifecycle-relevant state machines;
- shared entity, event, or capability concerns;
- implementation composition notes;
- generated report observations;
- likely future diagram usefulness.

No single signal is sufficient.

### 3. Classify candidates

Classify each candidate as:

```text
create
fold into stronger aggregate
defer-to-event-state-view
reject
```

Use `create` when the candidate is a coherent behavior-domain slice that composes existing workflows without inventing behavior.

Use `fold into stronger aggregate` when a small coherent candidate is a natural sub-slice of a stronger lifecycle aggregate.

Use `defer-to-event-state-view` when the main value is transition coverage and the relevant behavior mostly lives in events/state machines rather than workflows.

Use `reject` for broad buckets, role buckets, directory buckets, unrelated behavior, speculative binding, missing workflows, or candidates that need fields not adopted by the metamodel.

### 4. Create only strong aggregates

Do not force a fixed number.

Most created aggregates should contain three or more child workflows. A two-child aggregate is acceptable only when it is independently useful and not better folded into a stronger aggregate.

Place aggregates by behavior domain.

Good style:

```text
model/workflows/connection/establishment_lifecycle.yaml
model/workflows/connection/termination_lifecycle.yaml
model/workflows/path/continuity_lifecycle.yaml
model/workflows/packet/protected_traffic_lifecycle.yaml
model/workflows/stream/lifecycle.yaml
```

Avoid role-oriented aggregate placement unless the aggregate is truly role-specific.

### 5. Bind child roles explicitly

For every child workflow reference:

1. inspect the child workflow;
2. collect roles from `roles.primary`, `roles.participants`, direct `steps[].from`, and direct `steps[].to`;
3. bind every child role explicitly;
4. keep same-name bindings explicit;
5. choose bind values that express the aggregate context.

Example:

```yaml
steps:
  - workflow: endpoint/validate_path
    bind:
      endpoint: client
      peer_endpoint: server
```

Report uncertainty when a generic endpoint binding could reasonably map in more than one direction.

### 6. Write the skill-pass report

Create or update a generated report appropriate to the target repository.

Recommended path:

```text
<target>/generated/reports/aggregated-workflow-skill-pass.md
```

The report should include:

- source model inspected;
- candidate review questions;
- classification decisions;
- created aggregates;
- child workflows and binding summaries;
- why each aggregate is not a semantic bucket or role bucket;
- candidates folded into stronger aggregates;
- candidates deferred to event/state views;
- rejected candidates;
- findings for future skill refinement;
- commands run;
- validator/generator limitations;
- uncertainty.

## Validation and checks

Run repository validation if available.

If a canonical BehavioML validator is available, use it instead of local validation logic.

Do not implement local validators inside the target repository.

At minimum, manually or with non-committed inspection scripts check:

- every aggregate has only `description`, `notes`, and `steps`;
- every aggregate step has only `workflow` and `bind`;
- every child workflow reference resolves;
- every child role is explicitly bound.

If validation warns that aggregate workflows are not listed in semantic areas or have no primary role, report the warning rather than adding rushed ownership or role declarations.

## Commit

Suggested commit message:

```text
docs: add aggregated workflow skill pass
```

## Stop condition

Stop after committing this phase.

Report:

- aggregates created;
- candidates folded, deferred, or rejected;
- validation results;
- warnings;
- remaining uncertainty;
- whether the process seems reusable as a future skill.
