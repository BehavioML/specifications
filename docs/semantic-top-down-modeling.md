# Semantic top-down modeling

This document defines the recommended process for deriving and refining BehavioML models from source specifications, RFCs, product specs, design documents, or existing system behavior.

It is an operational modeling process for humans, prompts, skills, and agents.

It is not a new BehavioML model entity, schema, or validator rule.

---

## Purpose

Semantic top-down modeling keeps BehavioML models organized around system behavior rather than source-document structure.

Use this process when modeling a complex system, protocol, feature, or implementation from external source material.

The goal is to produce a model that remains meaningful even if the source document is reorganized, implementation packaging changes, or traceability mappings evolve.

---

## Core principle

Model behavior structure first.

Use source sections as evidence later.

Source headings, RFC sections, requirement IDs, issues, and product-spec sections are useful anchors for traceability and audit, but they should not be the primary decomposition unit of a BehavioML model.

A useful test:

```text
If the source document were reorganized without changing system behavior, would the BehavioML model still have mostly the same shape?
```

If the answer is no, the model is probably too coupled to source-document structure.

---

## Recommended process

### 1. Survey the source corpus

Read or inspect the relevant source material before creating detailed model files.

Identify the broad behavior, terminology, major participants, lifecycle concepts, constraints, and repeated patterns.

Do not immediately create one workflow, capability, or entity per source section.

### 2. Identify semantic areas

Identify behaviorally coherent areas of the system or protocol.

Semantic areas should be named after stable behavior or protocol concepts, not after source sections, issue numbers, implementation packages, or planning tasks.

Create `model/semantic-areas/` files when the area is stable enough to guide modeling work.

Each semantic area should directly list the workflows it owns.

Semantic area files should stay intentionally small. Related roles, capabilities, interfaces, entities, events, state machines, and decisions should be discovered through owned workflows and ordinary model references rather than repeated in semantic area files.

### 3. Identify entities and state owners

Identify behaviorally relevant concepts that own state or lifecycle meaning.

Do not create entities for every data object, payload field, source heading, implementation class, DTO, or temporary value.

Entities should help explain behavior, lifecycle, ownership, or state constraints.

### 4. Identify relationships and dependencies conceptually

Before defining detailed workflows, understand how semantic areas and state concepts relate.

This does not require a formal relationship model unless the BehavioML metamodel adopts one later.

The goal is to avoid isolated capability fragments without shared concepts.

### 5. Identify roles and participants

Identify functional participants in behavior.

Roles are not necessarily components, services, classes, processes, users, or deployment units.

A role should explain who participates in a workflow.

### 6. Identify lifecycle constraints

Identify state machines only for coherent entities with meaningful lifecycle constraints.

Do not use state machines to collect miscellaneous status labels, UI states, branch names, implementation flags, or planning states.

### 7. Review workflow candidates

Before creating workflow files, review candidate workflows by semantic area.

A workflow should answer:

```text
Who does what, with whom, in what observable or architecturally meaningful order?
```

Candidate workflows from a source survey are hypotheses, not approval to create workflow files.

Classify each candidate before materializing it:

- accept;
- needs review;
- demote to capability;
- demote to decision;
- demote to traceability or audit note;
- demote to state/event review;
- contract gap;
- implementation guidance gap;
- test gap;
- out of scope.

Create a workflow only when it is high confidence.

High-confidence workflow candidates have clear semantic area ownership, roles, participants, ordered scenario spine, observable interaction or lifecycle impact, no hidden role inference, no executable control-flow dependency, and no source-section-shaped structure.

### 8. Define workflows owned by semantic areas

Define workflows only when there is a behaviorally meaningful scenario and the candidate has passed workflow review.

Workflows should be owned by semantic areas.

A workflow should not be created merely because a source section exists.

Do not create workflows for generic response handling, payload parsing, schema validation, status-code handling without domain or protocol meaning, implementation algorithms, helper completion, or test obligations.

### 9. Define capabilities under workflow context

Define capabilities after the higher-level behavior is understood.

Capabilities should express stable responsibilities.

Use `Workflow.steps` for the ordered observable scenario spine with explicit role context.

Use `Capability.uses` for ordered internal decomposition only when the parent capability and workflow-step context are sufficient to understand where the sub-capability belongs.

Do not create one capability per normative sentence, helper, return value, branch, implementation step, or source paragraph.

### 10. Add events and decisions deliberately

Add events only for meaningful observable occurrences that happened in the system.

Do not use events merely as success labels, failure labels, branch names, return values, helper completions, or status-code aliases.

If a candidate is primarily lifecycle-related, review whether it belongs as an event-triggered state-machine transition rather than a workflow.

Add decisions for modeling boundaries, rationale, tradeoffs, exclusions, or important interpretation choices.

### 11. Add aggregated workflows deliberately

After atomic and medium-sized workflows, capabilities, events, state machines, and decisions are stable enough, review whether the model needs aggregated workflows.

Aggregated workflows are normal workflows. They describe one behaviorally meaningful scenario branch.

Aggregated workflows may contain:

- workflow-reference steps using `workflow` + `bind`, to reuse existing scenario fragments; and
- ordinary object steps using normal workflow step fields, to add concrete branch-local setup, transition glue, context, or continuation.

They should answer a scenario-branch question such as:

```text
Which existing workflows and concrete branch-local steps compose this scenario branch?
```

They should not answer a review question such as:

```text
Which existing workflows must be reviewed together to understand this behavior boundary?
```

Good aggregated workflows are composed scenario branches, not broad review slices.

They must not include success, optional, failure, and terminal child workflows in the same aggregate unless those child workflows and object steps genuinely occur in the same concrete branch.

Their order should express scenario continuity, not review order.

Object steps inside aggregates are allowed only when they are concrete branch-local behavior. They must not be review-only decoration, lifecycle summaries, hidden branch logic, or diagram glue without behavioral meaning.

Workflow-reference steps should contain only `workflow` and `bind`. Do not add `from`, `to`, `capability`, `label`, `event`, `emits`, or `uses` to a workflow-reference step.

Ordinary object steps should follow the normal workflow step shape with explicit `from`, optional `to`, `capability`, and contextual `label`.

Do not create aggregated workflows merely because workflows live in the same directory, share the same primary role, belong to the same semantic area, have similar names, or would make a convenient diagram page.

Classify candidates before creating them:

- create;
- defer to event/state view;
- reject.

Place created aggregates by behavior domain, not by implementation, mechanism, or role bucket.

Good style:

```text
model/workflows/connection/version_negotiation_restart.yaml
model/workflows/connection/retry_validated_establishment.yaml
model/workflows/connection/zero_rtt_resumption.yaml
model/workflows/connection/handshake_failure_termination.yaml
model/workflows/connection/transport_parameter_error_termination.yaml
model/workflows/path/client_migration.yaml
model/workflows/stream/data_transfer_progress.yaml
model/workflows/packet/key_update_exchange.yaml
```

Avoid:

```text
model/workflows/connection/establishment_lifecycle.yaml
model/workflows/connection/termination_lifecycle.yaml
model/workflows/packet/protected_traffic_lifecycle.yaml
model/workflows/stream/lifecycle.yaml
model/workflows/aggregated/
model/workflows/review/
model/workflows/composite/
model/workflows/client/all.yaml
model/workflows/endpoint/all.yaml
```

Use semantic-area generated views when the important question is review, navigation, readiness, or area-level coverage.

Use event/state lifecycle views when the important question is transition coverage and the relevant behavior mostly lives in events or state machines rather than workflows.

Follow:

- `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md`
- `docs/design-notes/0014-aggregated-workflows-and-branch-local-steps.md`

### 12. Add external traceability

Add traceability after the model has semantic structure and aggregated workflow candidates have been considered.

Traceability should answer:

```text
Which source text supports this model element?
```

It should not answer:

```text
Which model file did this source heading create?
```

Keep traceability external unless the metamodel deliberately changes.

### 13. Review gaps and readiness

Review the model by semantic area and concrete scenario branch.

Classify missing information before adding detail to the wrong layer.
