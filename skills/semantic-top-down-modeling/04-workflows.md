# Phase 04 — Workflows

## Purpose

Create accepted BehavioML workflows and assign them to semantic areas.

This phase materializes only high-confidence workflow candidates accepted in Phase 03 or explicitly approved by the user.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0005-sequence-diagrammable-workflows.md`
- `skills/semantic-top-down-modeling/PLAN.md`
- `skills/semantic-top-down-modeling/workflow-candidate-gate.md`

## Preconditions

Phase 03 must be complete.

The progress report must include accepted workflow candidates.

If workflow candidates have not been reviewed, stop and run Phase 03.

## Inputs to inspect

Inspect:

- source corpus;
- progress report and workflow candidate review;
- `model/semantic-areas/`;
- `model/roles/`;
- `model/entities/`;
- `model/state-machines/`, if present;
- `workflow-candidate-gate.md`;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create accepted workflow files under `model/workflows/`;
- update semantic-area `workflows` lists;
- create minimal capability stubs only when required by workflow step references;
- update the progress report.

Forbidden:

- creating medium-confidence or rejected workflows;
- creating full capability decomposition;
- creating events;
- creating state-machine transitions;
- creating decisions;
- creating components;
- creating modules;
- creating interfaces;
- creating traceability maps;
- adding technical contracts;
- adding payload grammar;
- adding implementation details.

## Workflow creation rules

Create only workflows that Phase 03 marked `accept` or that the user explicitly approved.

Do not create workflows marked `needs review` unless the user explicitly approved them.

Do not create demoted candidates.

Each workflow must:

- describe one behaviorally meaningful scenario;
- use object steps;
- use explicit `from`;
- use optional `to` only for role-to-role interactions;
- reference capabilities with `capability`;
- include contextual `label`;
- avoid `at`;
- avoid hidden role inference;
- avoid inline branches, loops, guards, retries, exceptions, `alt`, `opt`, or executable control flow.

Workflow step shape:

```yaml
steps:
  - from: client
    to: endpoint
    capability: protocol/send_request
    label: Send request

  - from: endpoint
    capability: protocol/process_request
    label: Process request locally

  - from: endpoint
    to: client
    capability: protocol/return_response
    label: Return response
```

## Semantic area ownership

Every created workflow must be listed by exactly one semantic area.

Update the owning semantic area's direct `workflows` list.

Do not infer ownership from directories.

Do not list a workflow in more than one semantic area.

If ownership is ambiguous, do not create the workflow; return it to `needs review` in the progress report.

## Capability stubs

Workflow steps require capability references.

Create minimal capability stubs only when necessary.

A minimal stub should use only a behavior-level description.

Example:

```yaml
description: |
  Send the setup request to the endpoint.
```

Do not add detailed `uses` in this phase unless the user explicitly requested capability refinement.

Capability decomposition belongs in Phase 05.

## Procedure

1. Read the accepted workflow candidates from the progress report.
2. Confirm each candidate still passes the workflow gate.
3. Create workflow files for accepted candidates only.
4. Create minimal capability stubs for workflow step references if missing.
5. Update semantic-area workflow lists.
6. Record any candidates moved back to `needs review`.
7. Update the progress report.

## Output

- `model/workflows/**/*.yaml`
- minimal `model/capabilities/**/*.yaml` stubs as needed
- updated `model/semantic-areas/*.yaml`
- progress report update

## Validation and checks

Run repository validation if available.

If validator support for semantic areas is incomplete, report that honestly.

Expected warnings about triggers, events, transitions, or capability events may be acceptable if those are intentionally deferred.

Do not implement local validation.

## Commit

Suggested commit message:

```text
docs: add semantic area workflows
```

## Stop condition

Stop after committing this phase.

Do not refine capabilities until the user confirms the next phase.
