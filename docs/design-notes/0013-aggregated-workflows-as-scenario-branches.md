# 0013 - Aggregated workflows as scenario branches

## Status

Proposed.

This note supersedes the parts of `0009-aggregated-workflows.md` and `0010-aggregated-workflow-discovery-process.md` that describe aggregated workflows as review-level behavior-domain slices.

This note is refined by `0014 - Aggregated workflows and branch-local steps`, which clarifies that an aggregate may mix workflow-reference steps with ordinary object steps when those object steps are concrete branch-local behavior.

## Position

Aggregated workflows are workflows. Therefore, they must describe one concrete behaviorally meaningful scenario branch.

Aggregated workflows may reuse existing workflows when each child workflow sets up, continues, constrains, or completes the same scenario branch.

Aggregated workflows may also contain ordinary object steps when those steps are concrete branch-local setup, transition glue, context, or continuation needed to make the scenario branch complete.

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
| Aggregated workflow | Compose reusable workflows and branch-local object steps into one larger concrete scenario branch. |
| Generated report/view | Present cross-area coverage, lifecycle review, readiness, traceability, or state/event coverage. |

## Valid aggregate examples

These are valid only when the referenced child workflows and any object steps compose one branch without mixing alternatives or inventing unsupported behavior:

```text
connection/version_negotiation_restart
connection/retry_validated_establishment
connection/zero_rtt_resumption
connection/handshake_failure_termination
connection/transport_parameter_error_termination
path/client_migration
stream/data_transfer_progress
packet/key_update_exchange
```

Example using only child workflow references:

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

Example using branch-local object steps before a reusable failure-tail workflow:

```yaml
description: |
  Establishment reaches transport parameter exchange, the received peer
  parameters are invalid, and the endpoint closes the connection for the
  transport-parameter error branch.

notes:
  - This aggregate describes one concrete failure branch.
  - Object steps provide branch-local establishment context before the reusable failure-tail workflow.
  - No success-path protected-traffic readiness is implied.

steps:
  - from: client
    to: server
    capability: connection/send_initial
    label: Start connection establishment

  - from: server
    to: client
    capability: connection/send_establishment_response
    label: Establishment response

  - from: server
    to: client
    capability: transport_parameters/send_local_parameters
    label: Send peer transport parameters

  - workflow: endpoint/reject_invalid_transport_parameters
    bind:
      endpoint: client
      peer_endpoint: server
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
- reused child workflows and any object steps all belong to that same branch;
- object steps are concrete branch-local behavior, not review-only annotation;
- object steps reference existing capabilities;
- child workflow order and object-step order express scenario continuity, not review order;
- child roles can be explicitly bound;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, or execution control flow.

Reject the candidate when child workflows are alternatives, optional variants, lifecycle coverage items, role buckets, semantic-area buckets, or when an existing workflow already covers the whole scenario.

Do not reject a full-scenario candidate merely because an existing workflow covers a terminal tail. A terminal-tail workflow may be reused inside a larger branch aggregate with concrete branch-local setup steps.

## Superseded phrases

The following older phrases should be considered superseded:

```text
Aggregated workflows should answer a behavior-domain review question.
The step order is a review order, not necessarily a strict executable runtime sequence.
Some referenced workflows may represent alternatives, optional paths, or terminal paths.
Aggregated workflows compose existing workflows without adding behavior.
```

Replace them with:

```text
Aggregated workflows should answer a concrete scenario-branch question.
The step order expresses scenario continuity.
Alternatives, optional branches, and terminal paths should be separate aggregates.
Aggregated workflows may mix child workflow references with concrete branch-local object steps.
```

## Summary

```text
Aggregated workflow = one composed scenario branch.
Aggregated workflows may mix workflow references and branch-local object steps.
Semantic area = review / navigation / ownership slice.
Generated views = coverage and lifecycle review.
```
