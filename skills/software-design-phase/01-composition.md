# Phase 01 — Composition

## Purpose

Explain how accepted software units collaborate around the BehavioML workflows.

This phase composes the units discovered in phase 00 into a readable software shape for initial code generation planning.

It must not rediscover units, create classes, generate code, or duplicate workflow order as a new flow model.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/software-design-phase.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-software-units-and-codegen-boundaries.md`
- `skills/software-design-phase/PLAN.md`

This phase explains downstream composition only. The BehavioML model remains the behavior source of truth.

## Preconditions

Phase 00 must have produced an accepted unit set under `implementation/units/`.

If no accepted unit set exists, stop and report:

```text
No software units found. Run phase 00 before composition.
```

Do not add new unit files unless a critical missing unit blocks composition. Prefer documenting the gap in `implementation/notes.md`.

## Inputs to inspect

Inspect:

- `implementation/README.md`;
- `implementation/notes.md`;
- `implementation/units/*.yaml`;
- the existing BehavioML `model/` directory;
- relevant source specifications referenced by the model;
- implementation guidance, if present.

Do not inspect production implementation code in this phase.

## Allowed changes

Allowed:

- create or update `implementation/composition.md`;
- create or update `implementation/dependency-rules.md`;
- update `implementation/notes.md` with composition-phase status;
- add a unit only if composition cannot be understood without it and the gap is justified.

Forbidden:

- modifying `model/` files;
- inspecting or modifying production source code;
- creating classes, methods, or language-specific signatures;
- creating UML or class diagrams as source of truth;
- creating generated code;
- duplicating workflow order as `flows`;
- expanding the unit set without a gate.

## Procedure

1. Inspect the accepted unit files.
2. Identify the main decision spines implied by workflows and units.
3. Identify state owners touched by each spine.
4. Identify protocol or technical boundaries crossed by each spine.
5. Identify support units each spine delegates to.
6. Identify stable dependency direction.
7. Identify responsibilities explicitly not owned by each spine.
8. Identify dependency or ownership mistakes codegen must avoid.
9. Create or update `composition.md`.
10. Create or update `dependency-rules.md`.
11. Update `notes.md` with phase status and gaps.

## Composition content

For each major decision spine or behavior area, document:

- purpose;
- source workflows or capabilities;
- entry boundary, if any;
- units used;
- state owners touched;
- decisions kept visible;
- responsibilities explicitly delegated;
- responsibilities explicitly not owned;
- codegen cautions.

Do not duplicate step-by-step workflow order.

Do not create a new execution graph.

## Dependency rules

`dependency-rules.md` should express ownership and dependency direction at the responsibility level.

It should not be a language import graph.

Useful rule shapes:

```text
A receive spine may use packet format and key state.
A receive spine must not own key lifecycle state.
Packet format must not mutate lifecycle state.
An external adapter boundary must not own domain or protocol lifecycle state.
A top-level association unit may link state owners but must not absorb all responsibilities.
```

Prefer rules that prevent common implementation-agent mistakes.

## Output

Create or update:

- `implementation/composition.md`;
- `implementation/dependency-rules.md`;
- `implementation/notes.md`.

`composition.md` should use the accepted unit set as vocabulary.

`dependency-rules.md` should be concise and actionable.

`notes.md` should mention:

- composition phase completed;
- files created or changed;
- any unit gaps discovered;
- whether any units were added;
- whether codegen readiness is safe to evaluate next.

## Validation and checks

Run cheap checks appropriate to the repository:

- list changed files;
- validate YAML syntax for existing units if practical;
- run the canonical BehavioML validator if available;
- do not implement local validation logic.

Report skipped checks honestly.

## Commit

Commit only implementation documentation changes.

Suggested commit message:

```text
docs: add implementation unit composition
```

## Stop condition

Stop after committing this phase.

Do not create codegen readiness documents until the user confirms the next phase.
