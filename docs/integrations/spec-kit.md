# Spec Kit integration guidance

## Status

Draft guidance.

This document explains how BehavioML can be used with Spec Kit or similar specification-driven development workflows.

It does not introduce new BehavioML metamodel fields.

It does not define a normative workspace layout yet.

It builds on:

- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0009-behavioml-in-sdd-pipeline.md`

---

## Summary

BehavioML should integrate with Spec Kit as a behavioral architecture layer between source specifications and implementation planning.

A useful combined pipeline is:

```text
Spec Kit source specification
        -> BehavioML behavioral model draft
        -> BehavioML validation, diagrams, and model review
        -> Spec Kit technical plan, contracts, and tasks
        -> implementation
```

Spec Kit owns the product specification and development workflow.

BehavioML owns the structured behavioral model.

Neither should absorb the other.

---

## Layer ownership

| Layer | Owns | Should not own |
| --- | --- | --- |
| Spec Kit source specs | Product intent, goals, non-goals, user stories, functional requirements, acceptance criteria, assumptions | Behavioral architecture source model |
| BehavioML model | Workflows, roles, capabilities, interfaces, components, modules, entities, events, state machines, decisions | Full requirements, prose acceptance criteria, wire schemas, UI layout, implementation tasks |
| Spec Kit plan/research | Technical context, implementation strategy, unresolved technical decisions, project structure | Missing behavior not represented in BehavioML |
| Spec Kit contracts | API schemas, command schemas, endpoint contracts, payloads, UI or integration contracts | Behavioral source of truth |
| Spec Kit tasks | Ordered implementation work, file-level tasks, dependencies, parallelizable task groups | Behavioral model semantics |
| Generated BehavioML artifacts | Diagrams, validation reports, traceability reports, navigation indexes | Source-of-truth model content |
| Implementation | Code, tests, runtime config, deployment, handwritten glue | Hidden behavior absent from source specs and BehavioML |

---

## Recommended integration point

BehavioML should be introduced after the source specification is clear enough to model and before technical planning hardens implementation choices.

Recommended flow:

```text
/speckit.constitution
        ↓
/speckit.specify
        ↓
/speckit.clarify
        ↓
/behavioml.derive
        ↓
/behavioml.validate
        ↓
/behavioml.review
        ↓
/behavioml.diagrams
        ↓
/speckit.plan
        ↓
/speckit.tasks
        ↓
/speckit.analyze + /behavioml.traceability
        ↓
/speckit.implement
```

The key point is that `/speckit.plan` should be able to consume a reviewed BehavioML model, not only prose requirements.

---

## Artifact mapping

### `.specify/memory/constitution.md`

Use Spec Kit.

BehavioML should not replace project constitution or governance.

The constitution may state principles such as:

```text
Behaviorally relevant design must be represented in BehavioML before implementation.
Generated code must not invent hidden workflows or state transitions.
```

Those are governance rules, not model content.

---

### `specs/<feature>/spec.md`

Use Spec Kit.

This remains the product-facing source specification. It may contain:

- goals
- non-goals
- users/personas
- scenarios
- functional requirements
- acceptance criteria
- assumptions
- constraints

BehavioML consumes this file and derives a behavioral model draft from it, but does not replace it.

---

### `specs/<feature>/checklists/requirements.md`

Use Spec Kit.

This validates the quality of requirements and source specification prose.

BehavioML validation is separate and checks the model:

- references resolve
- workflows are diagrammable
- events are meaningful occurrences
- state machines are coherent
- capabilities are not hiding workflow behavior
- implementation details have not leaked into the model

Both checks are useful and should remain separate.

---

### `specs/<feature>/plan.md`

Use Spec Kit, informed by BehavioML.

`plan.md` should own:

- language/runtime/framework choices
- dependency choices
- testing strategy
- storage decisions
- project structure
- implementation constraints
- technical architecture planning

BehavioML can inform the plan by exposing:

- capability boundaries
- interface boundaries
- component candidates
- workflow handlers
- state ownership
- behavioral gaps

BehavioML should not replace `plan.md`.

---

### `specs/<feature>/research.md`

Use Spec Kit for technical decisions.

BehavioML `decisions/` should remain focused on behavioral or modeling rationale.

Examples:

| Decision location | Suitable content |
| --- | --- |
| `research.md` | Choose local file storage versus IndexedDB; choose CLI versus web runtime; choose contract format |
| `behavioml/model/decisions/` | Keep model explorer read-only; treat backlinks as a derived navigation index; model diagnostics as generated observations |

Cross-linking may be useful, but the decision types should not be merged.

---

### `specs/<feature>/data-model.md`

Use Spec Kit, informed by BehavioML where appropriate.

This is the most sensitive overlap because both systems use the word `entity`.

They mean different things:

| Concept | Spec Kit `data-model.md` | BehavioML |
| --- | --- | --- |
| Entity | Data object, domain object, persistence concept, UI-facing object | Behaviorally relevant state owner or domain concept |
| Field | Attribute needed by implementation or contract | Usually outside BehavioML unless behaviorally meaningful |
| Relationship | Data relationship or structural relation | Not a general ERD feature; lightweight entity relationships remain an open design area |
| Validation rule | Data or UX constraint | Only modeled if it changes meaningful behavior |
| State transition | May be data lifecycle or implementation rule | Use BehavioML state machines for behaviorally meaningful lifecycles |

Recommended direction:

```text
BehavioML entities and state machines
        -> inform
Spec Kit data-model.md
```

Do not blindly generate BehavioML entities from every data object.

Do not turn BehavioML into an ERD.

---

### `specs/<feature>/contracts/`

Use Spec Kit.

Contracts own technical interface details:

- API routes
- command schemas
- request/response payloads
- status codes
- message schemas
- UI or integration contracts

BehavioML `interfaces/` own architectural dependency boundaries and the capabilities that require those boundaries.

Recommended relationship:

```text
behavioml/model/interfaces/workspace_loader.yaml
        -> specs/<feature>/contracts/workspace-loader.yaml
```

The link may be represented in external traceability metadata.

Do not duplicate full contract schemas in BehavioML.

---

### `specs/<feature>/quickstart.md`

Use Spec Kit, possibly informed by BehavioML workflows.

BehavioML workflows can suggest quickstart scenarios and integration test outlines.

`quickstart.md` remains the human/agent-facing validation guide for the implemented feature.

---

### `specs/<feature>/tasks.md`

Use Spec Kit.

BehavioML should not become a task tracker.

BehavioML can improve task generation by providing:

- one task group per capability boundary
- workflow-based integration tests
- interface contract binding tasks
- state-machine lifecycle tests
- TODOs for modeling gaps

But ordered implementation tasks belong in `tasks.md`.

---

### `/speckit.analyze`

Extend or complement it.

Spec Kit analysis checks consistency between specification, plan, and tasks.

BehavioML can add model-aware analysis:

- requirement has no model mapping
- workflow has no source requirement
- task implements behavior not present in the model
- contract has no matching BehavioML interface or capability
- state transition is not exercised by any workflow
- event is unused or represents an outcome label instead of an occurrence

---

## Recommended workspace shape

A Spec Kit-compatible BehavioML project may use:

```text
project/
├── .specify/
│   ├── memory/
│   │   └── constitution.md
│   ├── templates/
│   │   └── overrides/
│   ├── extensions/
│   │   └── behavioml/
│   └── extensions.yml
│
├── specs/
│   └── 001-feature-name/
│       ├── spec.md
│       ├── checklists/
│       │   └── requirements.md
│       ├── plan.md
│       ├── research.md
│       ├── data-model.md
│       ├── contracts/
│       ├── quickstart.md
│       ├── tasks.md
│       └── behavioml-draft/
│           ├── model/
│           ├── traceability/
│           └── generated/
│
├── behavioml/
│   ├── model/
│   ├── traceability/
│   └── generated/
│
└── src/
```

### Root model versus feature-local draft

Use both levels if needed.

| Location | Purpose |
| --- | --- |
| `specs/<feature>/behavioml-draft/model/` | Feature-local proposed model changes derived from the source spec |
| `behavioml/model/` | Accepted system-level BehavioML model |

A possible flow is:

```text
specs/<feature>/spec.md
        -> specs/<feature>/behavioml-draft/model/
        -> review
        -> promote or merge into behavioml/model/
        -> plan/tasks/code
```

This avoids creating multiple divergent system models while still fitting Spec Kit's feature-oriented workflow.

---

## BehavioML extension commands

BehavioML should integrate through Spec Kit's extension or skills mechanism rather than introducing a parallel project-local `skills/` convention.

Suggested commands:

| Command | Purpose |
| --- | --- |
| `/behavioml.derive` | Derive a BehavioML model draft from `spec.md` and related source spec artifacts |
| `/behavioml.validate` | Validate model structure, references, event discipline, and workflow diagrammability |
| `/behavioml.review` | Produce a design review of the model and classify gaps |
| `/behavioml.diagrams` | Generate Mermaid or other derived model views |
| `/behavioml.traceability` | Generate or check source spec to model coverage reports |

A future `.specify/extensions.yml` could wire these commands into Spec Kit phases:

```yaml
hooks:
  after_specify:
    - extension: behavioml
      command: behavioml.derive
      optional: true
      description: Derive an initial BehavioML model draft from the source spec.

  before_plan:
    - extension: behavioml
      command: behavioml.review
      optional: false
      description: Review the BehavioML model before technical planning.
```

This hook shape is illustrative, not yet a BehavioML standard.

---

## Traceability

Traceability is useful, but should start outside the core metamodel.

Recommended first experiment:

```text
behavioml/traceability/source-map.yaml
```

or feature-local:

```text
specs/<feature>/behavioml-draft/traceability/source-map.yaml
```

Example:

```yaml
mappings:
  - source: specs/001-model-explorer/spec.md#FR-003
    targets:
      - workflows:workspace/open_model_workspace
      - capabilities:model/resolve_references
      - entities:reference
```

### Why external first?

External traceability:

- avoids a premature metamodel change
- can be generated, edited, or discarded during experiments
- allows the explorer to display source links later
- keeps BehavioML from becoming a requirements management system

Possible future model-local fields such as `derived_from` or `based_on` should remain open questions until experiments show they are needed.

---

## Gap classification

When moving through the combined pipeline, classify missing information explicitly.

| Gap type | Meaning | Fix |
| --- | --- | --- |
| Modeling gap | Behavior required for correctness is missing from BehavioML | Update the BehavioML model |
| Source spec gap | Product requirement or acceptance criterion is unclear | Update the source spec |
| Technical planning gap | Behavior is modeled, but implementation choices are missing | Update `plan.md` or `research.md` |
| Contract gap | Interface exists, but payload/API/schema details are missing | Update `contracts/` |
| Task gap | Implementation work is not decomposed | Update `tasks.md` |
| Out of scope | Missing detail is intentionally excluded | Document the exclusion |

Agents and generators should report the gap instead of silently inventing behavior.

---

## Model Explorer as first experiment

A BehavioML Model Explorer is a useful first test case because it is model-centric but should not become an editor or requirements management tool.

Initial product scope may include:

- loading a BehavioML model workspace
- indexing model entities
- resolving references
- showing backlinks
- showing workflows, capabilities, entities, events, state machines, and decisions
- showing validator diagnostics
- showing generated diagrams
- opening source YAML
- optionally showing links back to source specs later

The experiment should not initially choose a frontend framework or runtime.

It should test whether the following pipeline is useful:

```text
Spec Kit source spec
        -> BehavioML model draft
        -> validation and generated diagrams
        -> traceability report
        -> Spec Kit plan/tasks
```

Expected findings:

- what mapped cleanly from source spec to BehavioML
- what stayed in Spec Kit
- what required technical contracts
- what implementation guidance was still needed
- whether external traceability was enough
- whether any metamodel change is justified

---

## What BehavioML should not replace

BehavioML should not replace:

- Spec Kit source specifications
- Spec Kit technical planning
- Spec Kit tasks
- Spec Kit contracts
- implementation quickstarts
- project governance
- product requirements management
- issue tracking

BehavioML should add:

- behavioral architecture review before technical planning
- explicit workflow and role interaction modeling
- capability and responsibility boundaries
- state lifecycle constraints
- event discipline
- generated diagrams
- model validation
- traceability between source specs and behavior, if useful

---

## Open questions

- Should BehavioML eventually define a standard SDD-compatible workspace layout?
- Should `behavioml/model/` be supported as a first-class model root, or should tools continue to default to `model/`?
- Should feature-local `behavioml-draft/` directories be standardized?
- Should traceability remain external, or should fields such as `derived_from` or `based_on` become core model fields?
- Should BehavioML provide a Spec Kit extension package?
- Should `/speckit.plan` require a successful BehavioML review when a project opts into BehavioML?
- What coverage reports are most useful between source specs, model elements, contracts, and tasks?

---

## Current recommendation

For now:

1. Keep Spec Kit as the owner of source specs, plans, contracts, tasks, and implementation workflow.
2. Add BehavioML as a behavioral model layer between source specs and technical planning.
3. Use Spec Kit extension or skills mechanisms for BehavioML commands.
4. Avoid a project-local `skills/` convention if Spec Kit is present.
5. Avoid a separate `implementation/` directory in Spec Kit projects unless there is a strong reason.
6. Use `specs/<feature>/behavioml-draft/` for feature-local model derivation.
7. Use `behavioml/model/` for the accepted system model.
8. Keep traceability external during initial experiments.
9. Do not add metamodel fields until experiments justify them.
10. Do not let implementation guidance define behavior absent from the model.
