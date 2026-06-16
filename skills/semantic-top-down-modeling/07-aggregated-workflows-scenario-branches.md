# Phase 07 — Aggregated workflow scenario branches

## Purpose

Create aggregated workflows only when existing atomic or medium-sized workflows compose one concrete scenario branch.

This file supersedes `07-aggregated-workflows.md` where that older skill describes aggregated workflows as review-level behavior-domain slices.

Follow `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md`.

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

Do not use this phase to discover missing atomic workflows.

If existing workflows are not stable enough to compose, stop and report that aggregation is premature.

## Inputs to inspect

Inspect:

- complete `model/workflows/` tree;
- `model/semantic-areas/`;
- `model/state-machines/`;
- `model/events/`;
- `model/capabilities/`;
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
- creating review-order aggregates;
- creating lifecycle coverage aggregates;
- mixing alternative, optional, success, failure, or terminal branches in one aggregate;
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

The `workflow` field already resolves to `model/workflows/`.

## Candidate gate

Create an aggregated workflow only when all of these are true:

- it names one concrete scenario branch;
- it composes existing workflows without adding behavior;
- every child workflow belongs to the same branch;
- child workflow order expresses scenario continuity, not review order;
- child roles can be explicitly bound;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, or execution control flow.

Reject the candidate when:

- child workflows are alternatives;
- child workflows are optional variants of each other;
- the order is only useful for review;
- the candidate is a lifecycle coverage view;
- the candidate is just all workflows in a semantic area;
- the candidate is just all workflows for a role;
- an existing workflow already covers the scenario.

## Good candidate questions

Good questions:

```text
How does this specific scenario branch continue from one existing workflow to the next?
Which reusable workflows form this concrete path?
Does each child workflow set up, continue, constrain, or complete the same branch?
```

Bad questions:

```text
Which workflows must be reviewed together?
What are all workflows in this folder?
What workflows share the same primary role?
What workflows belong to this semantic area?
How do success, optional, failure, and terminal workflows combine into one lifecycle slice?
```

## Examples

Good aggregate names:

```text
connection/version_negotiation_restart.yaml
connection/retry_validated_establishment.yaml
connection/zero_rtt_resumption.yaml
connection/handshake_failure_termination.yaml
path/client_migration.yaml
stream/data_transfer_progress.yaml
packet/key_update_exchange.yaml
```

Suspicious aggregate names:

```text
connection/establishment_lifecycle.yaml
connection/termination_lifecycle.yaml
packet/protected_traffic_lifecycle.yaml
stream/lifecycle.yaml
client/all.yaml
endpoint/all.yaml
```

## Procedure

1. Inventory existing workflows.
2. Identify possible scenario branches, not review slices.
3. For each candidate, list the child workflows and explain the continuity relation between consecutive children.
4. Reject candidates where the relation is only topical, optional, alternative, terminal, or review-order based.
5. Create only strong scenario-branch aggregates.
6. Bind every child role explicitly.
7. Record rejected, deferred, and uncertain candidates in a generated report.

## Validation and checks

Run repository validation if available.

If a canonical BehavioML validator is available, use it instead of local validation logic.

Do not implement local validators inside the target repository.

At minimum, manually or with non-committed inspection scripts check:

- every aggregate has only `description`, `notes`, and `steps`;
- every aggregate step has only `workflow` and `bind`;
- every child workflow reference resolves;
- every child role is explicitly bound;
- no aggregate notes describe review order, alternatives, optional paths, or terminal paths as part of one aggregate.

## Stop condition

Stop after committing this phase.

Report:

- aggregates created;
- candidates rejected because they were review slices;
- candidates rejected because they mixed alternatives or optional branches;
- validation results;
- warnings;
- remaining uncertainty.
