# Phase 02 — Codegen readiness

## Purpose

Decide whether the BehavioML model plus software units plus composition are safe for initial code generation.

The answer may be no.

A good outcome is a precise list of missing contracts, scope notes, or implementation guidance that would otherwise force a generator to invent behavior or structure.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/software-design-phase.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-software-units-and-codegen-boundaries.md`
- `skills/software-design-phase/PLAN.md`

This phase evaluates readiness only. It must not generate code.

## Preconditions

Phase 00 must have produced accepted units.

Phase 01 must have produced composition and dependency rules.

If composition is missing, stop and report:

```text
No composition found. Run phase 01 before codegen readiness.
```

## Inputs to inspect

Inspect:

- `implementation/README.md`;
- `implementation/notes.md`;
- `implementation/units/*.yaml`;
- `implementation/composition.md`;
- `implementation/dependency-rules.md`;
- the existing BehavioML `model/` directory;
- relevant source specifications referenced by the model;
- implementation guidance, if present.

Do not inspect production implementation code in this phase.

## Allowed changes

Allowed:

- create or update `implementation/codegen-readiness.md`;
- update `implementation/notes.md` with readiness status;
- identify missing guidance files or contracts.

Forbidden:

- modifying `model/` files;
- inspecting or modifying production source code;
- generating code;
- creating classes, methods, or language-specific APIs;
- adding local validators;
- adding technical contracts that define new behavior;
- silently declaring blocked workflows ready.

## Procedure

1. Inspect the model, units, composition, and dependency rules.
2. Identify the intended generation target if already known.
3. Classify workflows by readiness.
4. Identify units that need more precise contracts.
5. Identify missing scope notes or implementation guidance.
6. Identify units that should remain abstract and not become one-to-one classes.
7. Identify behavior that is missing from the model and cannot be supplied by implementation guidance.
8. Identify behavior that belongs to referenced source specifications but needs local scope selection.
9. Write a readiness verdict.
10. Update `notes.md`.

## Readiness questions

Answer:

- Is codegen safe?
- For which target: docs, scaffold, tests, partial implementation, or production?
- Which workflows are closest to ready?
- Which workflows are blocked?
- Which missing behavior or boundary decisions block codegen?
- Which units need more precise contracts?
- Which units should stay abstract?
- Which implementation guidance files are needed?
- Which source specifications are required but out of current scope?

## Scope guidance

Do not duplicate source specifications.

When implementation details are already defined by a source specification, create or request only a scope or ownership note.

Useful guidance documents may include:

```text
packet-format-contract.md
  modeled packet/frame subset and parse/apply boundary

tls-adapter-contract.md
  external dependency boundary and signals needed by the model

timer-and-retention-contract.md
  ownership for timeout, retention, discard, and scheduling responsibilities

flow-control-contract.md
  modeled credit, final size, blocked behavior, and limit updates

codegen-target-scope.md
  allowed generation target and forbidden output
```

These documents must not invent behavior outside the BehavioML model and referenced source specifications.

## Output

Create or update:

- `implementation/codegen-readiness.md`;
- `implementation/notes.md`.

`codegen-readiness.md` should include:

- verdict;
- workflows closest to ready;
- workflows blocked;
- missing behavior and boundary decisions;
- guidance files needed before codegen;
- units needing more precise contracts;
- units that should remain abstract;
- safe near-term uses;
- forbidden generation uses.

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
docs: assess implementation codegen readiness
```

## Stop condition

Stop after committing this phase.

Do not create AGENTS, codegen profiles, contracts, or generated code until the user confirms the next phase.
