# 0009 - Aggregated workflows

## Status

Proposed.

This note captures a metamodel issue discovered while reviewing generated QUIC workflows and diagrams.

Atomic workflows are useful for traceability, but they are often too small to review the behavior of a complete scenario. At the same time, grouping workflows merely because they share a semantic area can create broad review views that mix related but causally disconnected behavior.

BehavioML needs a small composition mechanism that lets a workflow aggregate existing workflows without copying their steps, inventing control flow, or creating new review-view entity types.

---

## Context

Current sequence-diagrammable workflows use explicit object steps:

```yaml
steps:
  - from: client
    to: server
    capability: protocol/send_request
    label: Send request

  - from: server
    capability: protocol/process_request
    label: Process locally
```

This works well for atomic and medium-sized scenarios.

However, review often needs a larger view such as:

- connection startup across negotiation, Retry, handshake, 0-RTT, and failure handling
- protected packet receipt through ACK-visible accounting and terminal packet consequences
- stream lifecycle across send, receive, ACK observation, and cancellation
- path migration across validation, constrained response, accepted path use, and failure handling

Reviewing each small workflow separately does not show the complete behavior. But flattening every child workflow into one large ordered capability list duplicates behavior and loses the identity of the smaller workflows.

---

## Problem

A larger reviewable behavior slice needs to reuse existing workflows.

A parent workflow cannot simply reference a child workflow by path unless it can also say how the child workflow's roles map into the parent context.

For example, a reusable child workflow might use generic roles:

```yaml
roles:
  primary: endpoint
  participants:
    - peer_endpoint
```

When reused in a concrete connection startup or migration review, those child roles may need to mean:

```text
endpoint      -> server
peer_endpoint -> client
```

or:

```text
endpoint      -> client
peer_endpoint -> server
```

The composition site needs an explicit role binding.

---

## Proposed direction

Allow a workflow step to reference another workflow.

The minimal aggregated workflow step shape is:

```yaml
steps:
  - workflow: workflows/endpoint/receive_protected_packet
    bind:
      endpoint: server
      peer_endpoint: client
```

`workflow` references a child workflow.

`bind` maps role names from the referenced child workflow context into role names in the parent aggregation context.

The referenced child workflow is not modified. The binding applies only at the composition site.

The parent workflow remains identified by its file path. It must not introduce a top-level `id` field.

---

## Minimal aggregate shape

An aggregated workflow should stay small:

```yaml
description: |
  Review connection startup across version negotiation, Retry, handshake,
  0-RTT use, and explicit abort paths.

notes:
  - This aggregate reuses existing workflows instead of duplicating their steps.
  - Steps are workflow references, not newly inferred behavior.

steps:
  - workflow: workflows/client/negotiate_supported_version
    bind:
      client: client
      server: server

  - workflow: workflows/server/validate_client_address_with_retry
    bind:
      client: client
      server: server

  - workflow: workflows/client/establish_connection
    bind:
      client: client
      server: server

  - workflow: workflows/client/use_0rtt
    bind:
      client: client
      server: server

  - workflow: workflows/client/handle_handshake_failure
    bind:
      client: client
      server: server
```

The aggregate does not need a separate `main`, `variants`, `cases`, `outcome`, or review-specific structure.

If the review intent matters, describe it in `description`.

If reviewers need non-normative guidance, use `notes`.

---

## Step variants

`Workflow.steps[]` may contain two object step variants.

### Capability step

A direct behavioral step with role context:

```yaml
- from: client
  to: server
  capability: protocol/send_request
  label: Send request
```

Rules:

- `from` is required.
- `to` is optional.
- `capability` is required.
- `label` is recommended for human-facing diagrams.
- The step owns the role context for that capability in the current workflow.

### Workflow reference step

An aggregation step:

```yaml
- workflow: workflows/path/child_workflow
  bind:
    child_role: parent_role
```

Rules:

- `workflow` is required.
- `bind` is required.
- `bind` maps child workflow roles to parent aggregation roles.
- The step should not contain `from`, `to`, `capability`, or `label`.
- The child workflow keeps its own steps, roles, capabilities, and traceability.
- The parent aggregate orders or groups child workflows without copying their internals.

---

## Binding semantics

`bind` is evaluated at the composition site.

Given:

```yaml
- workflow: workflows/endpoint/validate_path
  bind:
    endpoint: server
    peer_endpoint: client
```

all child steps using `endpoint` are rendered or interpreted as `server` in this aggregate, and all child steps using `peer_endpoint` are rendered or interpreted as `client`.

A validator should eventually check that:

- every role used by the referenced child workflow is bound
- every key in `bind` names a role used by the child workflow
- every bind target is a valid role name in the aggregate context or becomes part of the aggregate's derived role set
- workflow reference steps do not mix `workflow` with direct capability-step fields

For the first version, explicit binding is preferred even when names are identical:

```yaml
bind:
  client: client
  server: server
```

This avoids hidden same-name inference and makes composition sites stable under refactoring.

---

## Aggregated workflows are not control flow

Aggregated workflows are review and composition spines.

They do not model:

- branching
- loops
- retries as executable control flow
- concurrency
- exception handling
- scheduler behavior
- implicit protocol follow-ups
- hidden responses

If alternatives matter, model the alternative behaviors as separate child workflows and aggregate them explicitly.

The aggregate may place related child workflows in an order useful for review, but that order must not imply an executable path when the children are actually alternatives. The description or notes should make the review intent clear.

Do not add `main`, `variants`, `cases`, `outcome`, or similar fields as part of this minimal proposal.

---

## Composition cycles

Workflow composition references should be acyclic.

A workflow may reuse child workflows, and multiple parent workflows may reference the same child workflow.

A parent workflow may also reference the same child workflow more than once with different bindings.

But workflow references must not form a cycle such as:

```text
workflows/a -> workflows/b -> workflows/c -> workflows/a
```

Behavioral loops belong in state machines, event/state lifecycle views, or explicit bounded workflows, not recursive workflow composition.

Generators should defensively detect cycles and refuse full expansion with a diagnostic.

Validators should eventually report workflow composition cycles as errors.

---

## Relationship to semantic areas

Semantic areas remain ownership/grouping boundaries for workflows.

An aggregated workflow may live inside a semantic area like any other workflow.

A semantic area should not become the aggregate itself.

The aggregate is useful when there is a reviewable behavior slice that benefits from composing child workflows. A broad semantic bucket that merely lists related workflows is not enough.

---

## Relationship to generated diagrams

Generators may render aggregated workflows in at least two modes:

1. collapsed mode, where each child workflow appears as one aggregate step
2. expanded mode, where child workflow steps are expanded using the local `bind`

In expanded mode, role names from child workflows must be rewritten through `bind` before rendering.

Generators must not infer omitted child workflows, callbacks, retries, redirects, broker deliveries, protocol responses, or hidden follow-up exchanges.

If a behavior matters to the review, the aggregate must reference a workflow that models it.

---

## Non-goals

This proposal does not introduce:

- review-view entities
- `main`
- `variants`
- `cases`
- `outcome`
- top-level `id`
- step-local `event`
- step-local `emits`
- step-local `uses`
- arbitrary control-flow structures

It also does not change `Capability.uses`.

Capability decomposition remains ordered internal decomposition under a parent capability context. Workflow aggregation composes behaviorally meaningful workflows.

---

## Summary

Aggregated workflows add one minimal composition mechanism:

```yaml
steps:
  - workflow: workflows/foo/bar
    bind:
      child_role: parent_role
```

This preserves atomic workflow traceability while allowing larger reviewable behavior slices.

The design intentionally avoids richer review-view structure until the minimal `workflow` + `bind` mechanism has been tested in examples and generators.
