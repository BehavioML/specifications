# 0014 - Aggregated workflows and branch-local steps

## Status

Proposed.

This note refines `0013 - Aggregated workflows as scenario branches`.

Design note 0013 corrected the older review-slice interpretation: an aggregated workflow must describe one concrete scenario branch, not a semantic-area review slice or lifecycle coverage bundle.

This note clarifies that an aggregated workflow is still a normal workflow. It may therefore combine workflow-reference steps with ordinary object steps when those object steps are concrete branch-local behavior needed to make the scenario branch complete.

---

## Problem

A strict "workflow references only" interpretation makes some valid scenario branches impossible to model.

For example, a model may contain a terminal workflow such as:

```text
endpoint/reject_invalid_transport_parameters
```

that covers only the failure tail:

```text
receive peer transport parameters
reject invalid parameters
send CONNECTION_CLOSE
```

That workflow does not cover the larger concrete branch:

```text
connection establishment starts
handshake carries transport parameters
peer transport parameters are received
parameters are invalid
endpoint rejects them
endpoint sends CONNECTION_CLOSE
connection fails
```

At the same time, composing it with a successful establishment workflow would be wrong if that child workflow reaches protected traffic readiness.

The aggregate needs concrete branch-local setup or glue steps before the reusable terminal workflow. Those steps are not review decoration; they are the missing scenario prefix.

---

## Position

Aggregated workflows are normal workflows.

They may contain both:

- workflow-reference steps, using `workflow` + `bind`; and
- ordinary object steps, using normal workflow step fields such as `from`, optional `to`, `capability`, and `label`.

Workflow-reference steps reuse existing scenario fragments.

Object steps are allowed when they provide concrete branch-local behavior needed for scenario continuity, such as:

- setup before a reusable child workflow;
- transition glue between child workflows;
- observable context that the aggregate must show so the branch is understandable;
- a concrete prefix before a terminal or failure-tail workflow;
- a concrete continuation after a child workflow when no reusable child exists yet.

Object steps are not allowed merely to improve review order, decorate a diagram, summarize a lifecycle, hide alternatives, or encode control flow.

---

## Shape

A mixed aggregate may look like:

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

Workflow-reference steps keep their strict local shape:

```yaml
- workflow: endpoint/reject_invalid_transport_parameters
  bind:
    endpoint: client
    peer_endpoint: server
```

Do not add `from`, `to`, `capability`, `label`, `event`, `emits`, or `uses` to a workflow-reference step.

Ordinary object steps follow the same rules as normal workflow object steps.

---

## Candidate gate

Create a mixed aggregate only when all of these are true:

- it names one concrete scenario branch;
- child workflows and object steps all belong to that same branch;
- object steps are branch-local behavior, not review-only annotation;
- object steps reference existing capabilities;
- the step order expresses scenario continuity;
- alternatives, optional variants, success paths, failure paths, and terminal paths are not bundled together unless they genuinely occur in that one branch;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, loops, or execution-control fields.

Reject or defer when:

- the object steps would merely duplicate a child workflow body;
- the candidate requires inventing behavior not supported by the source model or source material;
- the candidate is a lifecycle coverage view;
- the candidate is a semantic-area, role, directory, or review bucket;
- the aggregate would mix success-path completion with a failure branch;
- an existing workflow already covers the whole scenario.

Do not reject a full-scenario candidate merely because one existing workflow covers the terminal tail. A terminal-tail workflow may be reusable inside a larger branch aggregate.

---

## Relationship to atomic workflow granularity

Mixed aggregates are not a substitute for good atomic and medium-sized workflows.

If a branch-local object step becomes reused in multiple aggregates or carries a substantial scenario fragment, consider extracting it into a normal workflow in a later modeling pass.

Do not refactor existing atomic workflows inside the aggregation phase unless the user explicitly requested remodeling.

---

## Relationship to review views

This note does not reopen review-slice aggregates.

Invalid examples remain invalid:

```text
connection/establishment_lifecycle
connection/termination_lifecycle
packet/protected_traffic_lifecycle
stream/lifecycle
client/all
endpoint/all
```

Those names usually describe coverage or review views, not one concrete branch.

Use semantic areas, generated reports, or event/state views for review/navigation/readiness/lifecycle coverage.

---

## Summary

```text
Aggregated workflow = one concrete scenario branch.
Aggregated workflows may mix workflow references and branch-local object steps.
Workflow-reference steps reuse existing scenario fragments.
Object steps provide concrete branch-local setup, glue, context, or continuation.
Review slices and lifecycle coverage remain generated views, not workflows.
```
