# 0007 - Implementation guidance boundary

## Status

Proposed.

This note defines how implementation-oriented guidance may live beside a BehavioML model without becoming part of the behavior-first source model.

---

## Context

BehavioML models behaviorally relevant responsibilities, interactions, events, lifecycle constraints, ownership boundaries, and rationale.

It intentionally does not model every implementation detail needed to generate production code.

Examples of details that are often necessary for implementation but should not normally be part of the BehavioML source model:

- HTTP route syntax
- request and response payload schemas
- OAuth error payload completeness
- JWT versus opaque token format
- database schemas
- framework choices
- runtime choices
- deployment topology
- logging and metrics
- concrete cryptographic algorithms
- UI screens

A code generator or implementation agent may still need those details.

The question is where they should live.

---

## Position

Implementation guidance may live beside a BehavioML model.

It is not part of the behavior-first source model.

The BehavioML model remains the source of truth for behavior.

Implementation guidance may configure, constrain, or instruct implementation work, but it must not define missing behavior or contradict the model.

If behavior is required for correctness, it belongs in the BehavioML model.

---

## Layering

A useful mental model is:

```text
Layer 1: BehavioML model
         behavior, responsibilities, roles, events, state machines, decisions

Layer 2: Implementation guidance
         technology choices, contracts, codegen instructions, policies, profiles

Layer 3: Generated or handwritten implementation
         source code, tests, configs, deployments
```

The layers may reference downward or sideways, but behavior should not be hidden in lower layers.

---

## Recommended directory shape

Implementation guidance should live outside `model/`.

Example:

```text
example/
├── model/
├── generated/
└── implementation/
    ├── README.md
    ├── AGENTS.md
    ├── codegen-profile.yaml
    └── contracts/
        └── openapi.yaml
```

### `README.md`

Explains the implementation guidance package to humans.

It should say what the guidance is for and remind readers that the behavior source of truth remains `../model/`.

### `AGENTS.md`

Instructs code-generation agents.

It may describe:

- how to use the BehavioML model
- what not to infer
- what commands to run
- what files to inspect
- what style to follow
- how to report modeling gaps

It must not define new behavior that is absent from the model.

### `codegen-profile.yaml`

Captures structured implementation choices.

Examples:

```yaml
target:
  language: typescript
  runtime: node
  framework: express

contracts:
  openapi: ./contracts/openapi.yaml

tokens:
  access_token:
    format: opaque
  refresh_token:
    issuance: optional_by_policy

generation:
  allowed:
    - scaffold_components
    - scaffold_endpoints
    - scaffold_tests
  forbidden:
    - invent_missing_workflows
    - infer_callbacks
    - implement_production_crypto
```

### Technical contracts

Contracts such as OpenAPI, AsyncAPI, JSON Schema, protobuf, Avro, or Smithy may define technical interface details.

They may describe:

- HTTP endpoints
- methods
- request schemas
- response schemas
- message schemas
- transport contracts
- status codes

They should complement the BehavioML model, not replace it.

---

## Source-of-truth rule

Implementation guidance must not become a hidden behavior model.

For example, this is suspicious if invalid redirect URI behavior is absent from the BehavioML model:

```yaml
invalid_redirect_uri:
  response_status: 400
  response_body: invalid_request
```

The response shape may belong in implementation guidance, but the behavior itself should be modeled first:

- an event such as `redirect_uri_rejected`
- a workflow for authorization-request rejection
- a capability responsible for the rejection response

Then implementation guidance may bind that modeled behavior to HTTP details.

---

## Agent instructions boundary

`AGENTS.md` is useful for code generation because it can tell an agent how to work with the model.

Good agent instruction:

```text
Use the BehavioML model as the behavioral source of truth.
Do not infer omitted callbacks or failure paths.
If required behavior is missing, stop and report a modeling gap.
Use codegen-profile.yaml for implementation choices.
```

Bad agent instruction:

```text
If the redirect URI is invalid, return 400 and stop the flow.
```

unless that behavior is already represented in the model.

The first instruction constrains generation.

The second instruction defines behavior.

Behavior belongs in the model.

---

## Code generation readiness

A BehavioML model may be ready for different kinds of generation:

| Readiness | Meaning |
| --- | --- |
| Behavioral scaffold | Generate roles, components, endpoints, handler skeletons, TODOs, and tests aligned with workflows |
| Architecture scaffold | Generate module/component/interface boundaries and dependency skeletons |
| Contract scaffold | Generate or bind technical contracts such as OpenAPI or AsyncAPI |
| Full implementation | Generate executable behavior with few human decisions |

BehavioML alone may be enough for behavioral or architecture scaffolding.

Full implementation usually requires implementation guidance and technical contracts.

That does not mean the BehavioML model is incomplete.

It means implementation-specific details live in a different layer.

---

## How to handle missing detail

When a generator or reviewer finds missing information, classify it as one of:

### Modeling gap

Behavior required for correctness is missing.

Examples:

- missing failure workflow
- missing observable event
- missing role interaction
- missing state transition
- unclear owner role

Fix by updating the BehavioML model.

### Implementation guidance gap

The behavior is modeled, but technical implementation choices are missing.

Examples:

- HTTP route
- payload schema
- token format
- database choice
- framework

Fix by updating implementation guidance or technical contracts.

### Out of scope

The behavior or implementation detail is intentionally excluded from the example or profile.

Fix by documenting the exclusion clearly.

---

## Validator boundary

The core BehavioML validator should validate the behavior model.

It should not initially validate implementation guidance.

Future tooling may add optional validators for:

- implementation profiles
- contract bindings
- code generation profiles
- AGENTS.md conventions

Those should remain separate from the core model validator unless the boundary changes deliberately.

---

## Current position

Keep BehavioML small and behavior-first.

Allow implementation guidance beside the model.

Prefer existing standards for technical contracts.

Use `AGENTS.md` for agent/codegen instructions.

Use `codegen-profile.yaml` for structured implementation choices.

Do not let implementation guidance define hidden behavior.

If behavior matters, model it in BehavioML.
