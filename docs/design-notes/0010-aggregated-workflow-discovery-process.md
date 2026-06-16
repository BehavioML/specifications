# 0010 - Aggregated workflow discovery process

## Status

Superseded.

This note is retained as historical context for early aggregated workflow experiments.

Do not use this note as current guidance where it describes aggregated workflows as behavior-domain review slices, lifecycle coverage views, review-order sequences, or combinations of success, optional, failure, and terminal paths.

Current guidance is defined by:

- `0013 - Aggregated workflows as scenario branches`
- `0014 - Aggregated workflows and branch-local steps`
- `docs/semantic-top-down-modeling.md`, especially phase 11
- `skills/semantic-top-down-modeling/07-aggregated-workflows.md`

## Superseded idea

The original note explored using aggregates to help reviewers inspect broad behavior-domain slices across multiple workflows.

That direction proved too broad for the core model because it encouraged aggregates such as:

```text
connection/establishment_lifecycle
connection/termination_lifecycle
packet/protected_traffic_lifecycle
stream/lifecycle
```

Those are better treated as semantic-area review, generated reports, readiness views, or event/state lifecycle views.

## Current replacement

An aggregated workflow is a normal workflow that describes one concrete scenario branch.

It may contain:

- workflow-reference steps, using `workflow` and `bind`; and
- ordinary object steps, when those steps are concrete branch-local setup, transition glue, context, or continuation.

Aggregates must not be review-order artifacts, lifecycle coverage summaries, semantic-area buckets, role buckets, directory buckets, or diagram-only pages.

Use this current test instead:

```text
What concrete scenario branch is this?
```

Do not use the older test:

```text
Which workflows must be reviewed together?
```

## Historical value

This note still documents why aggregation needed a disciplined discovery process:

- inspect workflows before aggregating;
- bind child roles explicitly;
- avoid broad buckets;
- report rejected and deferred candidates;
- do not infer hidden protocol behavior from aggregation order.

Those process lessons remain useful only when interpreted through the current scenario-branch rule in notes 0013 and 0014.
