# Semantic top-down modeling skill plan

## Purpose

This skill derives a new BehavioML model from source material using the semantic top-down modeling process.

It is intended for humans, ChatGPT, Codex, and other agents working in this repository or in repositories that follow the BehavioML conventions.

## Sources of truth

This skill is operational guidance only.

It must not redefine BehavioML semantics.

Before running any phase, inspect and follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- relevant design notes under `docs/design-notes/`

If this skill conflicts with `docs/model-rules.md`, follow `docs/model-rules.md`.

If this skill conflicts with `docs/semantic-top-down-modeling.md`, follow `docs/semantic-top-down-modeling.md` for process guidance.

## Preconditions

Use this skill only for fresh semantic top-down derivation.

The target BehavioML model must be empty, absent, or intentionally prepared for fresh derivation before this skill starts.

If a non-empty existing BehavioML model is present, stop before editing and report:

```text
Existing BehavioML model found. This skill is for fresh semantic top-down derivation. Use a separate existing-model remodeling skill instead.
```

Do not delete, overwrite, refactor, or migrate an existing model as part of this skill.

Resetting or deleting a model is not part of this plan.

## Phase discipline

Run exactly one phase per invocation unless the user explicitly asks for a different mode.

After each phase:

1. update the progress report;
2. run the required checks for that phase;
3. commit the changes;
4. report the result;
5. stop.

Do not continue to the next phase until the user explicitly confirms.

If resuming a previous run, inspect the progress report first and continue from the next incomplete phase.

## Progress report

Each target should keep a progress report outside the source model, normally under a generated or reports directory appropriate for that project.

Example:

```text
<target>/generated/reports/semantic-top-down-modeling-progress.md
```

The progress report should include:

- current phase;
- phase status;
- commits made;
- files changed per phase;
- source material inspected;
- open questions;
- rejected or demoted candidates;
- validation/check results;
- whether the next phase is safe to run.

The progress report is not source-of-truth model content.

## Phase sequence

Run phases in this order:

1. [`00-source-survey.md`](00-source-survey.md)
2. [`01-semantic-areas.md`](01-semantic-areas.md)
3. [`02-vocabulary.md`](02-vocabulary.md)
4. [`03-workflow-candidates.md`](03-workflow-candidates.md)
5. [`04-workflows.md`](04-workflows.md)
6. [`05-capabilities.md`](05-capabilities.md)
7. [`06-events-lifecycle-decisions.md`](06-events-lifecycle-decisions.md)
8. [`07-aggregated-workflows.md`](07-aggregated-workflows.md)
9. [`08-traceability-report.md`](08-traceability-report.md)

The workflow candidate gate used by phases 03 and 04 is defined in:

- [`workflow-candidate-gate.md`](workflow-candidate-gate.md)

Aggregated workflow discovery and classification used by phase 07 is defined in:

- `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md`
- `docs/design-notes/0014-aggregated-workflows-and-branch-local-steps.md`

Historical aggregate workflow design notes may still explain earlier decisions, but `0013` and `0014` define the current rule: aggregates are concrete scenario branches and may mix workflow references with branch-local object steps.

## Global non-goals

Do not:

- derive model structure from source section headings;
- create one workflow per source section;
- create one capability per normative paragraph;
- add pseudo-code;
- add control-flow constructs;
- add implementation-local branching;
- add OpenAPI, AsyncAPI, JSON Schema, protobuf, or other technical contracts to the core model;
- add payload grammar or wire schema details to the core model;
- add implementation guidance to the core model;
- add components before behavior requires implementation anchors;
- use modules as semantic behavior areas;
- use semantic areas as modules, packages, services, use cases, epics, stories, or requirements groups;
- use aggregated workflows as broad semantic buckets, role buckets, directory buckets, lifecycle coverage summaries, or review-order artifacts;
- infer hidden callbacks, retries, redirects, responses, broker deliveries, or protocol follow-ups;
- implement local validation logic.

## Global completion criteria

A run of this skill is complete when:

- source material has been surveyed;
- semantic areas have been created;
- behaviorally relevant vocabulary has been introduced;
- workflow candidates have been reviewed and classified;
- accepted workflows have been created and assigned to semantic areas;
- capabilities have been refined under workflow context;
- events, lifecycle transitions, and decisions have been added deliberately;
- strong aggregated workflow candidates have been created, deferred, marked for workflow-granularity review, or rejected;
- traceability and final reporting have been added outside the model;
- validation limitations are reported honestly;
- remaining gaps are classified.
