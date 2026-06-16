# 0013 - Aggregated workflows as scenario branches

## Status

Proposed.

This note supersedes the parts of `0009-aggregated-workflows.md` and `0010-aggregated-workflow-discovery-process.md` that describe aggregated workflows as review-level behavior-domain slices.

## Position

Aggregated workflows are workflows. Therefore, they must describe one concrete behaviorally meaningful scenario branch.

Aggregated workflows compose existing workflows only when each child workflow sets up, continues, constrains, or completes the same scenario branch.

They must not be used as semantic-area review slices, lifecycle coverage summaries, role buckets, directory buckets, collections of alternatives, collections of optional branches, or bundles of success, failure, and terminal paths.

If a behavior has alternatives, model one aggregate per branch.

If an optional behavior changes the scenario, model a separate aggregate for the optional branch.

If the goal is review, navigation, readiness, or coverage, use semantic areas, generated reports, or event/state views instead.

## Responsibility split

| Concept | Responsibility |
| --- | --- |
| `SemanticArea` | Own and organize workflows for review, navigation, readiness, and area-level coverage. |
| Atomic workflow | Describe a small behaviorally meaningful scenario. |
| Medium workflow | Describe a scenario large enough to be useful without composition. |
| Aggregated workflow | Compose reusable workflows into one larger concrete scenario branch. |
| Generated report/view | Present cross-area coverage, lifecycle review, readiness, traceability, or state/event coverage. |

## Valid aggregate examples

These are valid only when the referenced child workflows already exist and compose one branch without adding missing behavior:

```text
connection/version_negotiation_restart
connection/retry_validated_establishment
connection/zero_rtt_resumption
connection/handshake_failure_termination
path/client_migration
stream/data_transfer_progress
packet/key_update_exchange
```

Example:

```yaml
description: |
  The client handles valid version negotiation and then continues QUIC
  connection establishment with the selected supported version.

notes:
  - This aggregate reuses existing workflows instead of duplicating their steps.
  - The child workflows form one concrete establishment branch.
  - No behavior is implied beyond the referenced child workflows.

steps:
  - workflow: client/negotiate_supported_version
    bind:
      client: client
      server: server

  - workflow: client/establish_connection
    bind:
      client: client
      server: server
```

## Invalid aggregate examples

These should not be modeled as aggregated workflows when they mix alternatives or review concerns:

```text
connection/establishment_lifecycle
connection/termination_lifecycle
packet/protected_traffic_lifecycle
stream/lifecycle
client/all
endpoint/all
```

For example, one aggregate must not combine version negotiation restart, invalid version negotiation abort, normal establishment, Retry establishment, 0-RTT resumption, invalid transport parameter close, and handshake failure close.

Those are different branches. They may belong to the same semantic-area review, but they should not be one workflow.

## Discovery rule

When considering an aggregate, ask:

```text
What concrete scenario branch is this?
```

Do not ask merely:

```text
Which workflows must be reviewed together?
Which workflows belong to this semantic area?
Which workflows belong to this lifecycle topic?
Which workflows would make a useful diagram page?
```

Create an aggregate only when:

- it names one concrete scenario branch;
- it composes existing workflows without adding behavior;
- every child workflow belongs to the same branch;
- child workflow order expresses scenario continuity, not review order;
- child roles can be explicitly bound;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, or execution control flow.

Reject the candidate when child workflows are alternatives, optional variants, lifecycle coverage items, role buckets, semantic-area buckets, or when an existing workflow already covers the scenario.

## Superseded phrases

The following older phrases should be considered superseded:

```text
Aggregated workflows should answer a behavior-domain review question.
The step order is a review order, not necessarily a strict executable runtime sequence.
Some referenced workflows may represent alternatives, optional paths, or terminal paths.
```

Replace them with:

```text
Aggregated workflows should answer a concrete scenario-branch question.
The step order expresses scenario continuity.
Alternatives, optional branches, and terminal paths should be separate aggregates.
```

## Summary

```text
Aggregated workflow = one composed scenario branch.
Semantic area = review / navigation / ownership slice.
Generated views = coverage and lifecycle review.
```
