# Phase 00 — Software-unit discovery

## Purpose

Discover the smallest useful set of stable implementation responsibility boundaries from an existing BehavioML model.

This phase identifies software units that future implementation work or initial codegen should preserve instead of inventing generic managers, processors, helpers, or services.

It must not create classes, modules, generated code, or a language-specific design.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/software-design-phase.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-software-units-and-codegen-boundaries.md`
- `skills/software-design-phase/PLAN.md`

This phase applies the downstream software-design process; it does not redefine BehavioML.

## Preconditions

A BehavioML model must already exist.

The model should be valid or have known validation limitations documented.

Do not remediate the core model in this phase unless the user explicitly asks for model changes.

Do not inspect production implementation code in this phase. This skill is for initial code generation planning, not reverse engineering existing code.

## Inputs to inspect

Inspect:

- the existing BehavioML `model/` directory;
- relevant source specifications referenced by the model;
- generated reports or traceability maps, if present;
- existing `implementation/` artifacts, if present;
- repository guidance documents, if they do not bias discovery toward existing code shape;
- relevant design notes.

Do not use source section headings as direct unit names.

Do not use roles or participants as units unless they represent stable implementation responsibility boundaries.

## Allowed changes

Allowed:

- create or update `implementation/README.md`;
- create or update `implementation/notes.md`;
- create or update `implementation/units/*.yaml`;
- record rejected, demoted, or future unit candidates in notes.

Forbidden:

- modifying `model/` files;
- inspecting or modifying production source code;
- modifying tests or build files;
- creating UML or class diagrams as source of truth;
- creating codegen output;
- adding local validators;
- creating implementation contracts that define new behavior.

## Procedure

1. Confirm that a BehavioML model exists.
2. Inspect workflows, roles, capabilities, interfaces, entities, state machines, events, and decisions.
3. Inspect referenced source specifications only to ground responsibilities needed by the model.
4. Identify state owners.
5. Identify protocol or technical boundaries.
6. Identify protocol artifacts with behaviorally important structure.
7. Identify decision spines that should remain readable.
8. Identify independently testable rules or mechanisms.
9. Identify external dependency boundaries.
10. Identify responsibilities codegen would otherwise invent.
11. Reject role wrappers and workflow-side artifacts unless they are stable boundaries.
12. Consolidate candidates into the smallest useful unit set.
13. Document possible future units rather than promoting uncertain candidates.

## Creation threshold

Before creating a YAML unit, answer:

```text
1. Is this a stable thing in the model or source specification?
2. Is it required to implement modeled behavior?
3. Would omitting it likely force codegen to invent structure?
4. Does it own state, define a boundary, or preserve a decision spine?
5. Is it reusable across more than one step/workflow, or independently testable?
6. Is it more than a role or participant wrapper?
```

Create the unit only when the answer is clearly yes to at least two of these and it is not merely a role-side artifact.

If unsure, do not create a unit. Record it in `implementation/notes.md` under possible future units.

## Suggested unit YAML shape

Use this intentionally small shape:

```yaml
name: Human readable name

from:
  - model or source references that justify the unit

owns:
  - state or durable data controlled by the unit

does:
  - responsibilities or operations the unit preserves

uses:
  - units/other-unit.yaml

refs:
  - specification references, when useful

notes:
  - short human explanation or uncertainty
```

Rules:

- `name` is required;
- `from` is required;
- `does` is required;
- `owns` is only for real state or durable data ownership;
- omit empty fields;
- use `name`, not `id`;
- do not add `kind`, `classes`, `methods`, `layers`, `groups`, or `flows`;
- notes must not define new behavior.

## Output

Create or update:

- `implementation/README.md`;
- `implementation/notes.md`;
- `implementation/units/*.yaml`.

`README.md` should explain:

- the downstream nature of the artifacts;
- that units are not BehavioML core;
- that units are not classes;
- that roles and participants are discovery evidence only;
- that codegen should report missing units instead of inventing generic structure.

`notes.md` should include:

- sources inspected;
- final unit count;
- why the unit count is intentionally limited;
- accepted units;
- responsibilities intentionally not promoted;
- possible future units;
- model gaps that matter before codegen;
- whether codegen is safe yet at a high level.

## Validation and checks

Run cheap checks appropriate to the repository:

- list changed files;
- validate YAML syntax if practical;
- run the canonical BehavioML validator if available;
- do not implement local validation logic.

Report skipped checks honestly.

## Commit

Commit only implementation documentation and unit files.

Suggested commit message:

```text
docs: add implementation software units
```

## Stop condition

Stop after committing this phase.

Do not create composition documents until the user confirms the next phase.
