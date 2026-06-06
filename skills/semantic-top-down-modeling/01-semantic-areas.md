# Phase 01 — Semantic areas

## Purpose

Create the initial semantic-area skeleton from the source survey.

Semantic areas organize behavior. They are not source sections, use cases, modules, components, services, requirements groups, epics, stories, or planning task groups.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `skills/semantic-top-down-modeling/PLAN.md`

Use `docs/model-rules.md` for the valid semantic-area shape.

## Preconditions

Phase 00 must be complete.

The progress report must contain a source survey and candidate semantic areas.

If the source survey is missing, stop and run Phase 00.

## Inputs to inspect

Inspect:

- source corpus;
- progress report from Phase 00;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create `model/semantic-areas/`;
- create semantic-area YAML files;
- update the progress report.

Forbidden:

- creating workflows;
- creating capabilities;
- creating roles;
- creating entities;
- creating events;
- creating state machines;
- creating decisions;
- creating components;
- creating modules;
- creating traceability maps;
- adding source references to semantic-area files;
- adding component references to semantic-area files.

## Semantic-area shape

Semantic-area files must use this minimal shape:

```yaml
name: Area name
description: >-
  Behaviorally coherent area description.

workflows: []

notes: >-
  Optional human note explaining scope or exclusions.
```

Do not add:

- `kind`;
- `owns`;
- `model_refs`;
- source refs;
- component refs;
- supporting model-element lists.

The `semantic-areas/` directory determines the entity type.

The `workflows` field is the direct workflow ownership list.

It may be empty in this phase because workflows are created later.

## Procedure

1. Read the candidate semantic areas from the Phase 00 survey.
2. Keep only behaviorally coherent areas.
3. Remove areas that are merely source sections, requirements groups, use cases, implementation modules, or generic concerns.
4. Name each area using stable behavior or protocol concepts.
5. Create one semantic-area file per accepted area.
6. Use empty `workflows: []` unless an approved workflow already exists from an earlier explicit human decision.
7. Add notes only for scope, exclusions, or important modeling boundaries.
8. Update the progress report with accepted, rejected, and deferred areas.

## Output

- `model/semantic-areas/*.yaml`
- progress report update

## Validation and checks

Run repository model validation if it can tolerate semantic areas with empty workflow lists.

If validator support for semantic areas is not available yet, report that honestly.

Do not implement local validation.

## Commit

Suggested commit message:

```text
docs: add semantic area skeleton
```

## Stop condition

Stop after committing this phase.

Do not create vocabulary or workflows until the user confirms the next phase.
