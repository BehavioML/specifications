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

Aggregated workflows are normal workflows that compose existing workflows with `workflow` + `bind` steps.

Because they are workflows, they must describe one behaviorally meaningful scenario branch.

They should answer a scenario-branch question such as:

```text
Which existing workflows compose this concrete scenario branch?
```

They should not answer a review question such as:

```text
Which existing workflows must be reviewed together to understand this behavior boundary?
```

Good aggregated workflows are composed scenario branches, not broad review slices.

They must not include success, optional, failure, and terminal child workflows in the same aggregate unless those child workflows genuinely occur in the same concrete branch.

Their order should express scenario continuity, not review order.

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

Typical findings include source gaps, modeling gaps, contract gaps, implementation guidance gaps, test gaps, and out-of-scope details.

Do not hide missing behavior in implementation guidance, technical contracts, prompts, generated reports, or code.

---

## Workflow candidate gate

Use this gate before creating workflows.

Create a workflow only if at least one of these is strongly true:

- it is an observable role-to-role interaction;
- it changes which role acts or receives in a behaviorally meaningful order;
- it represents a system-level failure, rejection, recovery, timeout, or cancellation scenario;
- it changes, constrains, or explains lifecycle state;
- omitting it would make sequence diagrams or human review misleading;
- it is needed to make a semantic area's behavior understandable.

Do not create a workflow if the behavior is only local processing by one role, reusable response preparation, generic handling, payload parsing, schema validation, status-code handling without domain meaning, implementation algorithm, source heading, normative sentence, capability decomposition, traceability evidence, or test obligation.

Ambiguous workflow candidates should be recorded as `needs review` instead of being materialized.

---

## Aggregated workflow candidate gate

Use this gate after the model has stable child workflows.

Create an aggregated workflow only when all of these are true:

- it names one concrete scenario branch;
- it composes existing workflows without adding behavior;
- every child workflow belongs to the same branch;
- child workflow order expresses scenario continuity;
- it is not merely a semantic-area, directory, role, naming, or lifecycle-coverage bucket;
- child workflow roles can be explicitly bound;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, or execution control flow.

Do not create an aggregated workflow if it is just all workflows in a semantic area, all workflows for a role, a broad system bucket, a lifecycle coverage view, a collection of alternative branches, or something that would need `main`, `variants`, `cases`, or `outcome` to be understandable.

Record rejected and deferred aggregate candidates in a report rather than forcing them into the model.

---

## Demotion guidance

Semantic top-down modeling should preserve uncertainty instead of forcing every source detail into the model.

Demote a candidate to capability when the behavior is an internal responsibility within an already modeled workflow.

Demote a candidate to decision when the important information is a modeling boundary, tradeoff, or exclusion rationale.

Demote a candidate to traceability or audit note when the source requires behavior but the behavior creates no separate observable scenario spine.

Demote a candidate to state/event review when the behavior is primarily lifecycle-related and should wait for event discipline.

Mark a candidate as a contract gap when behavior exists but missing detail belongs in a route, payload, schema, message, protocol field, or status mapping.

Mark a candidate as an implementation guidance gap when behavior exists but missing detail belongs in runtime, framework, storage, deployment, scheduling, retry policy, or security policy.

Mark a candidate as out of scope when it belongs outside the intended model boundary.

---

## Section-level work

Section-level modeling is still useful, but it should usually happen after a semantic skeleton exists.

Use section-level work to deepen an existing semantic area, audit conformance for a specific source section, tighten traceability, find implementation or test gaps for a known behavior area, and confirm that source evidence is represented by existing workflows, capabilities, entities, events, state machines, decisions, or aggregated workflows.

Do not use section-level work as the default first decomposition step for complex source material.

---

## Anti-patterns

Avoid these patterns:

- source document headings define model structure;
- one source section becomes one workflow by default;
- one normative paragraph becomes one capability by default;
- modules are used as semantic behavior areas;
- semantic areas are used as modules or implementation packages;
- workflows are created for local algorithmic mechanics or generic handling;
- aggregated workflows are created as broad semantic buckets;
- aggregated workflows are created as role buckets;
- aggregated workflows are created as lifecycle coverage summaries;
- aggregated workflows are created as review-order diagram pages;
- aggregated workflows mix mutually exclusive branches;
- aggregated workflows combine optional variants into one apparent sequence;
- aggregated workflows are placed under technical `aggregated/`, `review/`, or `composite/` directories;
- capabilities hide role-to-role interactions;
- events represent generic outcomes instead of observable occurrences;
- traceability drives model creation instead of supporting model review;
- implementation guidance defines behavior missing from the model.

---

## Expected outcome

A semantic top-down BehavioML model should make it clear:

- which semantic areas organize the behavior;
- which workflows each semantic area owns;
- which candidate workflows were accepted, deferred, or demoted;
- which aggregated workflows compose concrete scenario branches;
- which aggregate candidates were rejected because they were review slices, lifecycle coverage views, role buckets, or branch bundles;
- which entities and state machines carry lifecycle meaning;
- which roles participate in behavior;
- which capabilities express stable responsibilities;
- which events are meaningful observable occurrences;
- which decisions explain modeling boundaries;
- which source material supports the model through external traceability;
- which gaps belong in source specs, BehavioML, contracts, implementation guidance, tests, or explicit out-of-scope notes.

The result should be more useful for human review, diagram generation, gap analysis, and implementation planning than a model derived directly from source-document sections.
