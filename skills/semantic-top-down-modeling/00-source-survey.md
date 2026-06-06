# Phase 00 — Source survey

## Purpose

Survey the source corpus before creating BehavioML model files.

This phase identifies behaviorally coherent areas, roles, state concepts, lifecycle candidates, exclusions, and likely traceability anchors.

It must not create source model entities.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `skills/semantic-top-down-modeling/PLAN.md`

This phase applies the process from `docs/semantic-top-down-modeling.md`; it does not redefine it.

## Preconditions

The target model must be empty, absent, or intentionally prepared for fresh derivation.

If a non-empty target model exists, stop before editing and report that this skill is not the right workflow.

Do not delete or reset existing model files.

## Inputs to inspect

Inspect:

- source corpus or source artifact;
- repository README or feature README;
- relevant source/spec/RFC/design documents;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`;
- relevant design notes;
- existing progress report, if present.

If the source corpus is missing, do not infer behavior from an old BehavioML model.

Stop and report the missing source material.

## Allowed changes

Allowed:

- create or update the progress report;
- add a local source artifact only when the user requested it or when repository convention expects source snapshots;
- record source identity, retrieval command, and inspection limitations.

Forbidden:

- creating `model/` files;
- creating semantic areas;
- creating workflows;
- creating capabilities;
- creating entities;
- creating roles;
- creating state machines;
- creating events;
- creating decisions;
- creating components or modules;
- creating traceability maps;
- using the old model as behavioral source.

## Procedure

1. Confirm the target is suitable for fresh derivation.
2. Locate or fetch the source corpus if allowed.
3. Read or survey the source corpus as a whole.
4. Identify major participants and role candidates.
5. Identify behaviorally coherent semantic area candidates.
6. Identify entity and state-owner candidates.
7. Identify lifecycle candidates.
8. Identify observable protocol/system exchanges.
9. Identify major failure, rejection, timeout, and recovery behaviors.
10. Identify behavior that belongs outside core BehavioML.
11. Identify likely traceability anchors.
12. Propose a modeling order.
13. Record open questions.

Do not decide final workflow shape in this phase.

Candidate workflows may be mentioned as hypotheses, but they are not approved for creation.

## Output

Update the progress report with:

- source inputs inspected;
- source retrieval details, if any;
- major participants and role candidates;
- semantic area candidates;
- entity/state-owner candidates;
- lifecycle candidates;
- observable exchanges;
- major failure/rejection behaviors;
- exclusions and non-goals;
- likely traceability anchors;
- proposed modeling order;
- open questions;
- next phase readiness.

## Validation and checks

Run cheap repository hygiene checks appropriate to the repository.

Do not run model validation if no model exists yet unless the repository validation command is expected to tolerate an absent target model.

Report skipped validation honestly.

## Commit

Commit only the source artifact, if added, and the progress report.

Suggested commit message:

```text
docs: survey source for semantic top-down model
```

## Stop condition

Stop after committing this phase.

Do not create semantic areas until the user confirms the next phase.
