# Phase 07 — Aggregated workflow scenario branches

## Current guidance

This file is a compatibility entry point for the current Phase 07 aggregate workflow rules.

Follow:

- `skills/semantic-top-down-modeling/07-aggregated-workflows.md`
- `docs/semantic-top-down-modeling.md`, especially phase 11;
- `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md`;
- `docs/design-notes/0014-aggregated-workflows-and-branch-local-steps.md`.

## Rule

An aggregated workflow is a normal workflow that describes one concrete scenario branch.

It may contain workflow-reference steps and ordinary object steps.

Workflow-reference steps use only `workflow` and `bind`.

Object steps use normal workflow step semantics and are allowed only when they provide concrete branch-local setup, transition glue, context, or continuation.

Aggregates must not be review slices, lifecycle coverage summaries, semantic-area buckets, role buckets, directory buckets, or diagram-only pages.

## Candidate gate

Create an aggregate only when it names one concrete scenario branch and every child workflow or object step belongs to that branch.

Reject alternatives, optional variants, lifecycle coverage, review order, broad buckets, and candidates already fully covered by one existing workflow.

Do not reject a full-scenario candidate merely because one existing workflow covers only the terminal tail. A tail workflow may be reused inside a larger branch aggregate with concrete branch-local object steps.

## Stop condition

Stop after committing this phase and report aggregates created, candidates deferred or rejected, validation results, and remaining uncertainty.
