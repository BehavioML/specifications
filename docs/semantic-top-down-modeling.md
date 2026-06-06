# Semantic top-down modeling

This document defines the recommended process for deriving and refining BehavioML models from source specifications, RFCs, product specs, design documents, or existing system behavior.

It is an operational modeling process for humans, prompts, skills, and agents.

It is not a new BehavioML model entity, schema, or validator rule.

---

## Purpose

Semantic top-down modeling helps keep BehavioML models organized around system behavior rather than source-document structure.

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

Examples:

```text
session establishment
session resource lifecycle
ICE candidate trickle
ICE restart
authorization and rejection
packet protection
protected packet receive
key update
connection migration
```

Semantic areas should be named after stable behavior or protocol concepts, not after source sections, issue numbers, implementation packages, or planning tasks.

Create `model/semantic-areas/` files when the area is stable enough to guide modeling work.

Each semantic area should directly list the workflows it owns.

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

### 7. Define workflows owned by semantic areas

Define workflows only when there is a behaviorally meaningful scenario.

A workflow should answer:

```text
Who does what, with whom, in what observable or architecturally meaningful order?
```

Workflows should be owned by semantic areas.

A workflow should not be created merely because a source section exists.

Algorithmic local mechanics should not automatically become workflows.

### 8. Define capabilities under workflow context

Define capabilities after the higher-level behavior is understood.

Capabilities should express stable responsibilities.

Use `Workflow.steps` for the ordered observable scenario spine with explicit role context.

Use `Capability.uses` for ordered internal decomposition only when the parent capability and workflow-step context are sufficient to understand where the sub-capability belongs.

Do not create one capability per normative sentence, helper, return value, branch, implementation step, or source paragraph.

### 9. Add events and decisions deliberately

Add events only for meaningful observable occurrences that happened in the system.

Do not use events merely as success labels, failure labels, branch names, return values, helper completions, or status-code aliases.

Add decisions for modeling boundaries, rationale, tradeoffs, exclusions, or important interpretation choices.

Decisions should explain why, not restate what.

### 10. Add external traceability

Add traceability after the model has semantic structure.

Traceability should answer:

```text
Which source text supports this model element?
```

It should not answer:

```text
Which model file did this source heading create?
```

Keep traceability external unless the metamodel deliberately changes.

### 11. Review gaps and readiness

Review the model by semantic area.

Classify missing information before adding detail to the wrong layer.

Typical findings include:

- source gaps
- modeling gaps
- contract gaps
- implementation guidance gaps
- test gaps
- out-of-scope details

Do not hide missing behavior in implementation guidance, technical contracts, prompts, generated reports, or code.

---

## Section-level work

Section-level modeling is still useful, but it should usually happen after a semantic skeleton exists.

Use section-level work to:

- deepen an existing semantic area;
- audit conformance for a specific source section;
- tighten traceability;
- find implementation or test gaps for a known behavior area;
- confirm that source evidence is represented by existing workflows, capabilities, entities, events, state machines, or decisions.

Do not use section-level work as the default first decomposition step for complex source material.

---

## Anti-patterns

Avoid these patterns:

- one source section becomes one workflow by default;
- one normative paragraph becomes one capability by default;
- source document headings define model structure;
- modules are used as semantic behavior areas;
- semantic areas are used as modules or implementation packages;
- semantic areas are treated as use cases, epics, user stories, or requirements groups;
- workflows are created for local algorithmic mechanics;
- capabilities hide role-to-role interactions;
- events represent generic outcomes instead of observable occurrences;
- traceability drives model creation instead of supporting model review;
- implementation guidance defines behavior missing from the model.

---

## Expected outcome

A semantic top-down BehavioML model should make it clear:

- which semantic areas organize the behavior;
- which workflows each semantic area owns;
- which entities and state machines carry lifecycle meaning;
- which roles participate in behavior;
- which capabilities express stable responsibilities;
- which events are meaningful observable occurrences;
- which decisions explain modeling boundaries;
- which source material supports the model through external traceability;
- which gaps belong in source specs, BehavioML, contracts, implementation guidance, tests, or explicit out-of-scope notes.

The result should be more useful for human review, diagram generation, gap analysis, and implementation planning than a model derived directly from source-document sections.
