# Phase 03 — Workflow candidates

## Purpose

Review possible workflows before creating workflow files.

This phase applies the workflow candidate gate and classifies candidates as accepted, needs review, demoted, or out of scope.

It must not create workflow YAML files.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `skills/semantic-top-down-modeling/PLAN.md`
- `skills/semantic-top-down-modeling/workflow-candidate-gate.md`

## Preconditions

Phases 00, 01, and 02 must be complete.

Semantic areas, roles, and behaviorally relevant vocabulary should exist.

If semantic areas or vocabulary are missing, stop and run the earlier phase.

## Inputs to inspect

Inspect:

- source corpus;
- progress report;
- `model/semantic-areas/`;
- `model/roles/`;
- `model/entities/`;
- `model/state-machines/`, if present;
- `workflow-candidate-gate.md`;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- update the progress report with workflow candidate review.

Forbidden:

- creating workflow files;
- updating semantic-area `workflows` lists;
- creating capabilities;
- creating events;
- creating state transitions;
- creating decisions;
- creating components;
- creating modules;
- creating interfaces;
- creating traceability maps.

## Procedure

1. For each semantic area, propose candidate workflows from source behavior.
2. Apply `workflow-candidate-gate.md` to every candidate.
3. Classify each candidate as:
   - `accept`;
   - `needs review`;
   - `demote to capability`;
   - `demote to decision`;
   - `demote to traceability/audit note`;
   - `demote to state/event review`;
   - `contract gap`;
   - `implementation guidance gap`;
   - `out of scope`.
4. Record why each candidate did or did not pass the gate.
5. Record primary role, participants, proposed steps, and lifecycle impact for accepted or needs-review candidates.
6. Do not materialize candidates in this phase.

Candidate workflows from the source survey are hypotheses, not approval to create workflow files.

Re-evaluate them with the gate.

## Output

Update the progress report with a section named:

```text
Workflow candidate review
```

Include:

- candidate table;
- accepted candidates;
- needs-review candidates;
- demoted candidates and reasons;
- out-of-scope candidates;
- open questions;
- next phase readiness.

## Validation and checks

Run cheap repository hygiene checks.

Do not run model validation unless model files were changed by an explicit repository convention.

## Commit

Suggested commit message:

```text
docs: review semantic workflow candidates
```

## Stop condition

Stop after committing this phase.

Do not create workflows until the user confirms the next phase.
