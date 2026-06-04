# 0009 - BehavioML in a specification-driven development pipeline

## Status

Proposed.

This note clarifies where BehavioML fits relative to specification-driven development, external specifications, model exploration, and code generation.

---

## Motivation

The QUIC, OAuth, and WHIP examples were all created from an existing specification or protocol understanding:

- QUIC came from protocol behavior and RFC-style knowledge.
- OAuth came from the OAuth Authorization Code Flow.
- WHIP came from the WHIP RFC and its HTTP/WebRTC behavior.

That is significant.

BehavioML was useful for reviewing and structuring behavior, but it was not the original source specification.

This suggests a better positioning:

```text
source specs / requirements / RFCs / SDD artifacts
        -> BehavioML behavioral model
        -> generated diagrams, validation, architecture review, codegen planning
        -> implementation guidance and technical contracts
        -> code generation / implementation
```

BehavioML is not a replacement for source specifications.

BehavioML is a structured behavioral model derived from specifications.

---

## Positioning

BehavioML should be treated as the behavioral architecture layer between specification-driven development and code generation.

It captures:

- roles
- workflows
- capabilities
- interfaces
- components
- modules
- entities
- state machines
- events
- decisions

It should not try to own:

- full product requirements
- complete RFC prose
- user stories
- acceptance criteria in prose form
- wire contracts
- payload schemas
- implementation instructions
- framework choices

Those belong in source specs, SDD artifacts, implementation guidance, or technical contracts.

---

## Why BehavioML is useful in the middle

Source specifications are usually rich but ambiguous for tooling.

They often contain:

- goals
- requirements
- constraints
- non-goals
- examples
- RFC sections
- acceptance criteria
- product behavior descriptions

But they often do not provide a compact, navigable model of:

- who interacts with whom
- which behavior is observable
- which responsibilities exist
- which state changes are meaningful
- which events matter
- which architectural boundaries emerge
- which decisions were made and why

BehavioML fills that gap.

It makes the behavioral architecture explicit without becoming the full source specification.

---

## Relationship to model exploration

A BehavioML explorer should primarily be a model explorer.

Its first responsibility is to help users inspect, navigate, validate, and understand a BehavioML model:

- model entities
- references
- backlinks
- workflows
- capabilities
- state machines
- diagnostics
- generated views
- decisions

It should not initially become a full requirements management tool or visual editor.

However, integration with SDD tools or external specification sources is valuable.

The explorer may eventually show traceability between source specifications and BehavioML model elements, but that should remain an integration layer around the model, not a reason to turn BehavioML into a requirements language.

---

## Possible workspace shape

A project using BehavioML in an SDD pipeline may look like this:

```text
project/
├── specs/
│   ├── product.md
│   ├── requirements.md
│   └── protocol-notes.md
├── model/
│   ├── workflows/
│   ├── capabilities/
│   ├── entities/
│   └── ...
├── implementation/
│   ├── README.md
│   ├── AGENTS.md
│   ├── codegen-profile.yaml
│   └── contracts/
│       └── openapi.yaml
└── generated/
    └── mermaid/
```

The `specs/` directory contains source specification material.

The `model/` directory contains the BehavioML behavioral model.

The `implementation/` directory contains guidance and contracts for code generation or implementation.

The `generated/` directory contains derived views.

---

## Traceability

Traceability from source specifications to BehavioML model elements may be useful.

A possible future direction is a lightweight reference from model elements back to source material:

```yaml
derived_from:
  - specs:requirements.md#session-creation
```

or:

```yaml
based_on:
  - specs:whip-rfc.md#section-4.1
```

This is not adopted yet.

Traceability should not make BehavioML responsible for representing the whole source specification.

It should only explain where a model element came from, or which external specification section it helps operationalize.

---

## Integration with SDD tools

BehavioML may integrate with SDD tools such as Spec Kit or similar systems.

A useful integration would map:

```text
requirements / spec sections / acceptance criteria
        -> BehavioML workflows, capabilities, entities, state machines, and decisions
        -> implementation tasks and codegen guidance
```

The integration should preserve separation of concerns:

- SDD tools own source requirements and product specification workflow.
- BehavioML owns the behavioral architecture model.
- implementation guidance owns agent/codegen constraints and technical choices.
- contract languages own wire schemas and APIs.

BehavioML should not absorb the entire SDD layer.

---

## Implications for generation

Code generation should not consume BehavioML alone as if it were a complete implementation specification.

A more realistic generation input is:

```text
source specs + BehavioML model + implementation guidance + technical contracts
```

BehavioML can guide:

- architecture scaffolding
- workflow handlers
- capability boundaries
- test outlines
- diagram generation
- TODO/task decomposition
- consistency checks

But technical details such as data schemas, API payloads, persistence, framework wiring, deployment, and runtime policy belong elsewhere.

---

## Current decisions

BehavioML remains behavior-first.

BehavioML is not the complete source specification.

BehavioML is not an SDD replacement.

BehavioML is the structured behavioral model between SDD/source specs and code generation.

A future explorer should start as a BehavioML model explorer.

SDD/spec integration is valuable, but should be layered around the model rather than embedded into every core concept prematurely.

---

## Open questions

- Should BehavioML define a standard workspace layout including optional `specs/`?
- Should model elements support `derived_from` or `based_on` references?
- Should traceability references be core model fields, implementation guidance, or explorer metadata?
- How should BehavioML integrate with Spec Kit or similar SDD tools?
- What coverage reports are useful between source specs and BehavioML models?
- Should code generators require implementation guidance/contracts in addition to BehavioML?
