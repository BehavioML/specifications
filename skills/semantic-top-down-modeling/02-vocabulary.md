# Phase 02 — Vocabulary

## Purpose

Introduce the high-level vocabulary needed before workflows are created.

This phase creates roles, behaviorally relevant entities, and lifecycle skeletons when they are already clear from the source survey.

It does not create workflows or refine capabilities.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `skills/semantic-top-down-modeling/PLAN.md`

## Preconditions

Phases 00 and 01 must be complete.

Semantic areas should exist under `model/semantic-areas/`.

If semantic areas are missing, stop and run Phase 01.

## Inputs to inspect

Inspect:

- source corpus;
- progress report;
- `model/semantic-areas/`;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create `model/roles/` files;
- create `model/entities/` files;
- create state-machine skeletons under `model/state-machines/` only when lifecycle states are already clear;
- update the progress report.

Forbidden:

- creating workflows;
- creating capabilities, except when explicitly required by a pre-existing model reference and approved by the user;
- creating events;
- creating state-machine transitions unless meaningful events already exist and the user explicitly asked for lifecycle refinement;
- creating decisions;
- creating components;
- creating modules;
- creating interfaces;
- creating traceability maps;
- adding implementation details;
- adding wire schema or payload grammar.

## Role guidance

Create roles for functional participants in workflows.

Roles are not necessarily components, services, classes, users, processes, or deployment units.

Create a role only if it helps explain who participates in behavior.

## Entity guidance

Create entities for behaviorally relevant state owners or domain concepts.

Do not create entities for:

- every payload;
- every field;
- every source heading;
- every DTO;
- temporary values;
- implementation classes;
- database tables;
- generated view models.

Entities should help explain behavior, lifecycle, ownership, identity, or state constraints.

## State-machine guidance

Create a state-machine skeleton only when a coherent lifecycle is already clear.

A skeleton may define `entity` and `states` without transitions.

Do not add transitions unless the relevant events are already defined and the phase explicitly allows it.

Do not use a state machine to collect miscellaneous status labels, UI states, branch names, implementation flags, or planning states.

## Procedure

1. Review the Phase 00 survey and Phase 01 semantic areas.
2. Identify roles needed by likely workflows.
3. Identify behaviorally relevant entities and state owners.
4. Identify lifecycle skeletons that are clear enough to model now.
5. Create minimal files with descriptions.
6. Avoid over-modeling technical data structures.
7. Update the progress report with created vocabulary and deferred candidates.

## Output

- `model/roles/*.yaml`
- `model/entities/*.yaml`
- optional `model/state-machines/**/*.yaml` skeletons
- progress report update

## Validation and checks

Run repository validation if available.

Expected warnings about missing workflows, missing events, or incomplete transitions may be acceptable at this phase if the model is intentionally incomplete.

Report all warnings honestly.

Do not implement local validation.

## Commit

Suggested commit message:

```text
docs: add semantic vocabulary skeleton
```

## Stop condition

Stop after committing this phase.

Do not create workflow candidates or workflows until the user confirms the next phase.
