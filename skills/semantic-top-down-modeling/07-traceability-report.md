# Phase 07 — Traceability and report

## Purpose

Add external traceability and final reporting after the BehavioML model has semantic structure.

Traceability supports audit and review. It must not drive model decomposition.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `skills/semantic-top-down-modeling/PLAN.md`

## Preconditions

Phase 06 must be complete.

Semantic areas, workflows, capabilities, events, state machines, and decisions should be stable enough to map back to source evidence.

If the model is still structurally unstable, stop and return to the relevant earlier phase.

## Inputs to inspect

Inspect:

- source corpus;
- progress report;
- complete `model/` tree;
- existing `traceability/`, if present;
- existing generated reports, if present;
- repository conventions for generated artifacts and traceability;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create or update external traceability maps;
- create or update final generated/review reports;
- update README or example documentation;
- update the progress report;
- make tiny model corrections only when traceability reveals an obvious stale reference or typo.

Forbidden:

- using traceability to create new model structure directly from source headings;
- adding source references to semantic-area files unless the metamodel changes;
- adding behavior to implementation guidance instead of the model;
- adding technical contracts unless explicitly requested;
- adding implementation tasks unless explicitly requested;
- adding generated diagrams unless explicitly requested or repository convention requires it.

## Traceability rule

Traceability should answer:

```text
Which source text supports this model element?
```

It should not answer:

```text
Which model file did this source heading create?
```

Use source sections as evidence anchors, not decomposition units.

Keep traceability external to the source model unless the metamodel deliberately changes.

## Gap classification

Classify remaining gaps before adding detail to the wrong layer.

Use at least:

- source gap;
- modeling gap;
- contract gap;
- implementation guidance gap;
- test gap;
- out of scope.

Do not hide missing behavior in implementation guidance, technical contracts, prompts, generated reports, or code.

## Final report

Create a final report appropriate to the target repository.

The report should include:

- source inputs inspected;
- semantic areas created;
- workflows owned by each semantic area;
- roles, entities, and state machines created;
- capabilities created or refined;
- events and decisions created or refined;
- traceability coverage summary;
- what intentionally remains outside core BehavioML;
- how the model follows semantic top-down modeling;
- remaining gaps;
- validator/generator/tooling follow-up issues;
- commands run;
- failures or uncertainty.

## Procedure

1. Inspect source corpus and model files.
2. Create or update external traceability maps following repository convention.
3. Check for source anchors with no model coverage and model elements with unclear source support.
4. Classify gaps by layer.
5. Create or update the final report.
6. Update README or example docs if needed.
7. Update the progress report and mark the run complete.

## Output

Possible outputs:

- `traceability/source-map.yaml` or repository-equivalent external traceability file;
- `generated/reports/*` final report;
- README/example docs updates;
- progress report update.

## Validation and checks

Run repository validation if available.

Run traceability checks only if the repository provides them.

Do not implement local validation or ad hoc traceability validators inside the target repository unless explicitly requested.

## Commit

Suggested commit message:

```text
docs: add semantic top-down traceability report
```

## Stop condition

Stop after committing this phase.

Report completion, remaining gaps, and recommended follow-up work.
