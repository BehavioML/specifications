# 0011 - Semantic areas and progressive modeling

## Status

Proposed.

This note follows `0010 - Afterthought: semantic-first RFC modeling`.

That note clarified that source-document sections are evidence, not model structure. This note proposes making that semantic-first workflow visible in the BehavioML model itself by introducing `SemanticArea` as a first-class behavior-first grouping entity.

---

## Context

Recent modeling work showed two related pressures.

First, RFC-backed modeling can become too section-shaped when the first unit of work is a source heading. That produces overly atomic workflows, capabilities that mirror normative paragraphs, and diagrams that are technically accurate but not very useful for human review.

Second, once a model grows beyond a small example, humans and agents need a stable way to navigate, review, parallelize, and deepen the model by behaviorally coherent areas.

Current BehavioML has good primitives for behavior and implementation:

```text
Workflow      = behaviorally meaningful scenario
Capability    = responsibility
Entity        = state owner or behaviorally relevant concept
StateMachine  = lifecycle constraints
Module        = component organization / packaging / ownership boundary
Component     = implementation element
```

However, it does not yet have a first-class concept for:

```text
A behaviorally coherent semantic area of the modeled system or protocol.
```

Directories can group files, but directory structure is not a semantic model entity. Modules can group components, but modules describe implementation organization, not behavior.

---

## Problem

Without a first-class semantic grouping construct, large BehavioML models tend to choose one of several imperfect structures:

1. Group by source document sections.
2. Group by filesystem directories only.
3. Overload `Module` to mean behavior area.
4. Treat major workflows as de facto use cases.
5. Keep workflows and capabilities flat, relying on human memory or generated reports.

Each option creates drift.

### Source-section drift

RFC sections, requirement headings, issue numbers, and product-spec sections are source anchors. They are not necessarily behavior boundaries.

If source sections drive model shape, the model changes when the document is reorganized even if system behavior does not change.

### Module drift

`Module` is the wrong abstraction for semantic behavior areas.

Modules organize implementation ownership, packaging, and component boundaries. A semantic behavior area may cut across several modules, and a module may implement capabilities used by several semantic areas.

Using modules for semantic areas couples behavior-first structure to implementation packaging too early.

### Use-case drift

A broad workflow or folder can start acting like a use case, epic, or product goal.

BehavioML workflows should remain behaviorally meaningful scenarios. They should not become the primary top-level semantic map for a complex protocol or system.

### Review and parallelization gap

Large models need a way to answer:

```text
Which workflows belong to this behavior area?
Which area should be deepened next?
Which area is ready for diagrams, review, traceability, or generation?
Which workflows are orphaned or ambiguously grouped?
```

The current metamodel can express workflows, but not the semantic area that organizes them.

---

## Position

Add `SemanticArea` as a first-class BehavioML entity.

A `SemanticArea` is a behavior-first grouping entity that represents a coherent semantic area of the modeled system or protocol.

It exists to organize progressive semantic modeling, parallel work, human review, and area-level readiness analysis.

Core ownership rule:

```text
SemanticArea owns behavioral decomposition.
Module owns implementation decomposition.
```

More concretely:

```text
SemanticArea owns workflows.
Module owns components.
```

The model should express semantic-area ownership through a direct top-level `workflows` field on each semantic area file.

---

## SemanticArea definition

A `SemanticArea` represents a behaviorally coherent area of the system or protocol.

Examples:

```text
packet protection
protected packet receive
initial key derivation
key update
session establishment
session resource lifecycle
ICE restart
authorization and rejection
connection migration
connection termination
```

A semantic area should remain meaningful if:

- the source document is reorganized;
- implementation packaging changes;
- component boundaries change;
- source traceability is represented differently.

A semantic area should be named for the behavior or protocol concept, not for a source section, implementation package, issue number, or planning task.

---

## Ownership semantics

A semantic area owns workflows.

```text
SemanticArea
    owns
Workflow
```

A workflow should be owned by exactly one semantic area once semantic areas are adopted for a model.

During migration, tools may warn rather than fail when workflows are unowned. A workflow must not be owned by more than one semantic area.

A semantic area must not own components.

A semantic area should not reference components. Components remain organized by modules and implement capabilities/interfaces.

```text
Module
    owns / organizes
Component

Component
    implements
Capability / Interface
```

Semantic areas should stay intentionally small: they own only workflows. Related capabilities, roles, entities, events, state machines, interfaces, and decisions are discovered through the owned workflows and ordinary model references rather than repeated in the semantic area.

This keeps behavioral organization and implementation organization orthogonal while avoiding duplicated semantic indexes inside the model.

---

## Proposed shape

A semantic area file lives under `semantic-areas/`.

The `semantic-areas/` scope determines that the file is a semantic area. The file should not repeat that fact through a `kind` field.

Example:

```yaml
name: Protected packet receive
description: >-
  Behavior area covering receive-side processing of protected packets before
  frame handling, ACK generation, recovery, or application processing.

workflows:
  - packet/endpoint/receive_protected_packet
  - packet/endpoint/remove_header_protection
  - packet/endpoint/remove_payload_protection

notes:
  - This area excludes frame handling, ACK generation, recovery, and application processing.
```

The `workflows` field is the semantic area's ownership list.

It references workflows by path identity under the `workflows/` scope.

Do not add separate ownership objects, component references, source references, or supporting-vocabulary lists to semantic area files in the initial design.

---

## Source traceability

Source sections should remain traceability evidence, not semantic area boundaries.

Do not add source references such as RFC sections directly to `SemanticArea` in the initial design.

Use external traceability maps to answer:

```text
Which source text supports this semantic area or model element?
```

Do not use traceability to answer:

```text
Which model file did this source heading create?
```

A semantic area such as `protected_packet_receive` may be supported by several source sections. A source section may support several semantic areas.

---

## Difference from Module

A module describes implementation organization, ownership, packaging, or component boundaries.

A semantic area describes behavioral organization.

| Concern | SemanticArea | Module |
| --- | --- | --- |
| Primary purpose | Behavioral grouping | Implementation organization |
| Owns | Workflows | Components |
| Lists | Workflows only | Components |
| Should survive source reorganization | Yes | Not the main concern |
| Should survive implementation repackaging | Yes | No |
| Describes behavior | Yes, by grouping workflows | No |
| Describes component ownership | No | Yes |

Do not use modules as semantic behavior areas.

Do not use semantic areas as implementation packages.

---

## Difference from use cases

A use case usually describes an actor goal or external interaction objective.

A semantic area describes a coherent behavior area of the system or protocol.

A useful distinction:

```text
Use case:
  Actor wants to achieve goal X through the system.

SemanticArea:
  This part of the modeled system has coherent behavior, state concepts,
  workflows, responsibilities, events, and constraints.
```

Examples:

| Candidate | Better modeled as |
| --- | --- |
| Client creates a WHIP session | Workflow |
| WHIP session establishment | SemanticArea |
| Endpoint returns a problem response | Workflow or capability, depending on context |
| Problem response handling | SemanticArea, if it groups meaningful rejection/error workflows |
| User starts authorization | Workflow |
| OAuth authorization code flow | SemanticArea or set of semantic areas, depending on model scope |
| RFC 9001 section 5.5 | Source evidence / traceability anchor |
| Protected packet receive | SemanticArea |

A semantic area should not be named after an actor goal unless that name also describes a stable behavior area independent of product/use-case framing.

---

## Semantic top-down process

For complex source-backed modeling, use semantic top-down modeling.

Recommended process:

```text
1. Survey the source corpus.
2. Identify semantic areas.
3. Identify behaviorally relevant entities and state owners.
4. Identify relationships and dependencies between areas and concepts.
5. Identify roles and protocol/system participants.
6. Identify lifecycle constraints and state machines.
7. Define behaviorally meaningful workflows owned by semantic areas.
8. Define capabilities as stable responsibilities under the workflow context.
9. Add events only for meaningful observable occurrences.
10. Add decisions for modeling boundaries, tradeoffs, and rationale.
11. Add external traceability from source evidence to model elements.
12. Review area-level gaps and generation readiness.
```

This order is intentionally top-down.

Do not start by turning every source section, paragraph, requirement, or normative sentence into a workflow or capability.

Section-level work remains useful later as a deepening, audit, and traceability refinement step.

---

## Section-level modeling as refinement

Section-level modeling is still useful when:

- the semantic skeleton already exists;
- the section fills detail in an existing semantic area;
- the section is behaviorally coherent;
- the goal is conformance audit;
- traceability needs to be tightened;
- implementation/test gaps need to be found for a known behavior area.

In that case, the section should deepen or audit existing semantic areas rather than create model structure directly from document headings.

---

## Parallel modeling implications

Semantic areas provide useful work boundaries.

A team or agent can work on one semantic area without owning the whole model:

```text
Deepen semantic-areas/session/establishment
Deepen semantic-areas/session/resource-lifecycle
Deepen semantic-areas/ice/restart
Review semantic-areas/errors/problem-responses
Audit semantic-areas/packet/protected-receive against RFC evidence
```

Each area can be reviewed for:

- owned workflows;
- workflow granularity;
- traceability coverage;
- generation readiness;
- modeling gaps.

Capabilities, entities, events, state machines, interfaces, roles, and decisions remain reviewable through the workflows owned by the area and their normal model references. They are not repeated in the semantic area file.

This helps large models evolve progressively without becoming either too atomic or too vague.

---

## Review implications

Semantic-area review should ask:

```text
Does this area describe a stable behavior area rather than a source section?
Are its workflows behaviorally meaningful and sequence-diagrammable?
Are capabilities reachable from those workflows stable responsibilities rather than copied source paragraphs?
Are entities involved in those workflows real behaviorally relevant concepts or implementation DTOs?
Are events involved in those workflows observable occurrences rather than outcomes or branch labels?
Are decisions reachable from the area recording rationale rather than restating requirements?
Are components kept out of the semantic area?
Are source references external traceability evidence rather than model structure?
```

The model should also support orphan checks:

```text
Which workflows are not listed by any semantic area?
Which workflows are listed by more than one semantic area?
Which semantic areas list no workflows?
Which semantic areas list missing workflows?
```

These checks should start as warnings while the concept is adopted.

---

## Validator implications

A future validator should recognize `semantic-areas/` as a source scope.

Initial checks should be structural:

1. `semantic-areas/` files are source model files.
2. Identity is path-based.
3. Top-level `id`, `ids`, `uuid`, and `uuids` remain forbidden.
4. `kind` is not used; the `semantic-areas/` scope determines entity type.
5. `workflows[]` references `workflows/`.
6. Component references are not supported in semantic areas.
7. `owns` is not supported in semantic areas.
8. Supporting reference-list fields are not supported in semantic areas.
9. A workflow listed by more than one semantic area should be reported.
10. A workflow listed by no semantic area may be a warning during adoption.

Validators should not initially require every model element to be reachable from a semantic area.

Validators should not infer semantic ownership from directories.

---

## Generator and Explorer implications

Generators and explorers can use semantic areas to provide better human-facing views:

- area overview pages;
- area-level workflow lists;
- area-level sequence diagram sets;
- area-level traceability reports;
- area-level gap/readiness reports;
- orphan workflow reports.

A richer explorer may derive related capabilities, entities, events, state machines, interfaces, roles, and decisions by traversing the ordinary model graph from the area's workflows. It should not require semantic area files to duplicate those references.

A generator must not infer omitted workflows, callbacks, retries, redirects, source relationships, implementation ownership, component ownership, or supporting model references from semantic area membership.

Semantic areas are navigation and review structure, not executable control flow.

---

## Rejected direction: use Module for semantic grouping

Using `Module` to represent semantic behavior areas is rejected.

It would conflate behavior and implementation organization.

A module can own components that implement capabilities used by several semantic areas. A semantic area can own workflows that are implemented by components across several modules.

These are different axes of the model.

---

## Rejected direction: infer areas from directories

Inferring semantic areas from workflow or capability directories is rejected as a source-of-truth mechanism.

Directories are useful namespaces. They may mirror semantic areas for convenience, but they should not be the only owner of semantic grouping.

If a semantic grouping has source-of-truth meaning, it should be represented explicitly as a semantic area.

---

## Rejected direction: make SemanticArea a requirements/use-case entity

Semantic areas should not become requirements groups, user stories, epics, product journeys, or use cases.

Source specifications own product requirements and acceptance criteria.

BehavioML semantic areas own behavior-first grouping of workflows.

---

## Current position

Add `SemanticArea` as a first-class BehavioML entity.

Use `semantic-areas/` as its source scope.

The `semantic-areas/` scope determines entity type; do not repeat `kind` inside semantic area files.

Semantic areas own workflows through a direct top-level `workflows` field.

Workflows should be listed by exactly one semantic area once adoption is complete, and must not be listed by multiple semantic areas.

Semantic areas should not include separate ownership objects, component references, source references, or supporting model-element lists in the initial design.

Modules continue to own or organize components.

Source traceability remains external.

Semantic top-down modeling should become the preferred process for complex source-backed models.

Section-level modeling remains useful as later refinement, audit, and traceability tightening.

---

## Open questions

- Should unlisted workflows be warnings or errors once semantic areas are widely adopted?
- Should `SemanticArea` support references to other semantic areas, or should hierarchy remain path-based only?
- Should semantic area readiness be modeled explicitly or reported externally?
- Should semantic areas eventually reference source traceability entries, or should traceability remain fully external?
- Should semantic area files remain workflow-only permanently, or can derived tooling provide all supporting model summaries without extending the file shape?
- How should generated diagrams show cross-area shared capabilities without implying ownership?
