# Phase 03 — Codegen guidance

## Purpose

Create implementation guidance for the allowed initial code generation target.

This phase converts the readiness findings into explicit agent instructions, target scope, and optional structured codegen profile.

It must not generate production code by itself.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/software-design-phase.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-software-units-and-codegen-boundaries.md`
- `skills/software-design-phase/PLAN.md`

The BehavioML model remains the source of truth for behavior.

Implementation guidance may constrain codegen, but it must not define behavior that is absent from the model or referenced source specifications.

## Preconditions

Phase 02 must have produced `implementation/codegen-readiness.md`.

If codegen readiness says generation is unsafe for the requested target, stop unless the user explicitly narrows the target to a safe one such as documentation, scaffolding, test planning, or non-behavioral skeletons.

If readiness is missing, stop and report:

```text
No codegen readiness assessment found. Run phase 02 before codegen guidance.
```

## Inputs to inspect

Inspect:

- `implementation/README.md`;
- `implementation/notes.md`;
- `implementation/units/*.yaml`;
- `implementation/composition.md`;
- `implementation/dependency-rules.md`;
- `implementation/codegen-readiness.md`;
- the existing BehavioML `model/` directory;
- relevant source specifications referenced by the model;
- existing implementation guidance, if present.

Do not inspect production implementation code unless the user explicitly says the generation target must integrate with an existing codebase.

This skill is for initial code generation guidance, not brownfield refactor planning.

## Allowed changes

Allowed:

- create or update `implementation/AGENTS.md`;
- create or update `implementation/codegen-profile.yaml`;
- create or update scope or contract notes under `implementation/contracts/`;
- update `implementation/notes.md` with guidance status.

Forbidden:

- modifying `model/` files;
- generating production source code;
- changing tests or build files;
- creating class diagrams as source of truth;
- adding behavior absent from the model;
- adding local validators;
- relaxing readiness blockers without addressing them.

## Procedure

1. Inspect codegen readiness.
2. Identify the allowed generation target.
3. If target scope is missing, create `implementation/contracts/codegen-target-scope.md` or equivalent.
4. Create or update `implementation/AGENTS.md` with instructions for implementation agents.
5. Create or update `implementation/codegen-profile.yaml` only if structured choices are needed.
6. Create scope or contract notes only for boundaries that readiness identified as needed.
7. Ensure every guidance item references the model, units, composition, dependency rules, or source specifications.
8. Ensure guidance does not define hidden behavior.
9. Update `notes.md`.

## AGENTS.md content

`implementation/AGENTS.md` should tell code-generation agents:

- what source artifacts to inspect;
- which artifacts are source of truth for behavior;
- which units and composition documents constrain structure;
- what generation target is allowed;
- what must not be inferred;
- what missing behavior must be reported as a gap;
- what commands to run;
- how to report failures honestly.

Useful forbidden-generation rules:

```text
Do not invent workflows.
Do not invent callbacks, retries, redirects, responses, or protocol follow-ups.
Do not convert every unit into a class.
Do not hide state transitions in helper code.
Do not introduce generic managers, processors, helpers, services, coordinators, or engines.
Do not implement behavior marked blocked in codegen-readiness.md.
```

## codegen-profile.yaml content

Use `codegen-profile.yaml` only for structured choices such as:

- target language;
- runtime or framework;
- allowed generation modes;
- forbidden generation modes;
- contract locations;
- naming constraints;
- test strategy;
- dependency constraints.

Do not put behavior in the profile.

## Contract notes

Contract notes under `implementation/contracts/` are local scope and ownership notes, not replacements for source specifications.

They may define:

- modeled subset;
- boundary ownership;
- allowed inputs and outputs;
- out-of-scope behavior;
- source anchors;
- codegen constraints.

They must not define new behavior absent from the BehavioML model or referenced source specifications.

## Output

Create or update as needed:

- `implementation/AGENTS.md`;
- `implementation/codegen-profile.yaml`;
- `implementation/contracts/*.md`;
- `implementation/notes.md`.

`notes.md` should include:

- guidance phase completed;
- files created or changed;
- allowed generation target;
- remaining blocked areas;
- whether implementation agents may proceed.

## Validation and checks

Run cheap checks appropriate to the repository:

- list changed files;
- validate YAML syntax for `codegen-profile.yaml`, if created;
- validate YAML syntax for unit files, if practical;
- run the canonical BehavioML validator if available;
- do not implement local validation logic.

Report skipped checks honestly.

## Commit

Commit only implementation guidance and documentation changes.

Suggested commit message:

```text
docs: add implementation codegen guidance
```

## Stop condition

Stop after committing this phase.

Do not generate code unless the user explicitly starts a separate code-generation task using the guidance produced here.
