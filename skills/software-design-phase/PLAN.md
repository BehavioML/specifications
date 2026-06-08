# Software design phase skill plan

## Purpose

This skill derives a downstream software-design layer from an existing BehavioML model.

It is intended for humans, ChatGPT, Codex, and other agents working in this repository or in repositories that follow the BehavioML conventions.

The skill helps bridge from a behavior-first model to implementation planning without turning BehavioML into a class model, UML model, framework profile, or code-generation language.

## Sources of truth

This skill is operational guidance only.

It must not redefine BehavioML semantics.

Before running any phase, inspect and follow:

- `docs/model-rules.md`
- `docs/software-design-phase.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-software-units-and-codegen-boundaries.md`

If this skill conflicts with `docs/model-rules.md`, follow `docs/model-rules.md`.

If this skill conflicts with `docs/software-design-phase.md`, follow `docs/software-design-phase.md` for process guidance.

## Preconditions

Use this skill only when a BehavioML model already exists.

The model should already contain enough workflows, roles, capabilities, interfaces, entities, state machines, events, and decisions to support downstream implementation responsibility analysis.

If no BehavioML model exists, stop before editing and report:

```text
No BehavioML model found. This skill requires an existing model. Run semantic top-down modeling first.
```

If the model is clearly incomplete for the requested design work, report the gap before creating downstream artifacts.

Do not add missing core behavior to `model/` as part of this skill unless the user explicitly asks for model remediation.

## Phase discipline

Run exactly one phase per invocation unless the user explicitly asks for a different mode.

After each phase:

1. update the phase notes or progress section;
2. run the required checks for that phase;
3. commit the changes;
4. report the result;
5. stop.

Do not continue to the next phase until the user explicitly confirms.

If resuming a previous run, inspect `implementation/notes.md` and the existing implementation artifacts first, then continue from the next incomplete phase.

## Output location

The downstream artifacts normally live outside `model/`:

```text
<target>/implementation/
├── README.md
├── notes.md
├── units/
├── composition.md
├── dependency-rules.md
├── codegen-readiness.md
├── current-code-reconciliation.md       # brownfield only
└── refactor-slices.md                   # brownfield only
```

The `implementation/` directory is not the BehavioML source model.

It must not define hidden behavior absent from the model or referenced source specifications.

## Phase sequence

Run phases in this order:

1. [`00-unit-discovery.md`](00-unit-discovery.md)
2. [`01-composition.md`](01-composition.md)
3. [`02-codegen-readiness.md`](02-codegen-readiness.md)
4. [`03-brownfield-reconciliation.md`](03-brownfield-reconciliation.md) — optional, only when existing code should be compared

## Global non-goals

Do not:

- add classes to BehavioML core;
- create UML as source of truth;
- create a class model as source of truth;
- create one software unit per workflow step;
- create one software unit per capability;
- create one software unit per entity mechanically;
- create role-side units such as client participant or server participant unless they are stable implementation boundaries;
- duplicate source specifications as local mini-specs;
- hide behavior in implementation guidance;
- add technical payload schemas to the BehavioML model;
- generate production code;
- implement local validation logic;
- infer missing callbacks, retries, redirects, responses, or protocol follow-ups.

## Global completion criteria

A run of this skill is complete when:

- a minimal useful set of software units has been discovered;
- role and participant evidence has not been over-promoted into units;
- composition explains how accepted units collaborate around workflows;
- dependency and ownership rules are documented;
- codegen readiness has a clear verdict;
- missing contracts, scope notes, or implementation guidance are identified;
- brownfield reconciliation is complete when applicable;
- no hidden behavior has been introduced outside the model;
- limitations and remaining gaps are reported honestly.
