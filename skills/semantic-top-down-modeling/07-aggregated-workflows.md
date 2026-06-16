# Phase 07 — Aggregated workflows

## Current guidance

This phase is governed by:

- `docs/semantic-top-down-modeling.md`, especially phase 11;
- `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md`;
- `docs/design-notes/0014-aggregated-workflows-and-branch-local-steps.md`.

Older guidance that described aggregated workflows as review-order behavior-domain slices is superseded.

## Rule

An aggregated workflow is a normal workflow that describes one concrete scenario branch.

It may contain:

- workflow-reference steps, using `workflow` and `bind`; and
- ordinary object steps, using the normal workflow step shape.

Object steps are allowed only when they are concrete branch-local setup, transition glue, context, or continuation needed to make the scenario branch complete.

Aggregates must not be semantic-area review slices, lifecycle coverage summaries, role buckets, directory buckets, or diagram-only pages.

## Procedure

1. Inspect existing workflows, semantic areas, capabilities, events, state machines, decisions, and generated reports.
2. Identify concrete scenario branches, not review slices.
3. For each candidate, list child workflows and any branch-local object steps needed for scenario continuity.
4. Classify each candidate as `create`, `defer-to-event-state-view`, `needs-workflow-granularity-review`, or `reject`.
5. Create only strong scenario-branch aggregates.
6. Bind every child workflow role explicitly.
7. Record created, deferred, rejected, and uncertain candidates in a generated report.

## Validation

Use the repository validator if available.

Check that every aggregate describes one concrete branch, every workflow-reference step contains only `workflow` and `bind`, every object step uses normal workflow step semantics, and no aggregate is only review order or lifecycle coverage.

## Stop condition

Stop after committing this phase and report validation results plus remaining uncertainty.
