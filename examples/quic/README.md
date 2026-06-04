# QUIC Validation Example

This example exists to validate the BehavioML meta-model against a real specification.

The purpose is not to model all of QUIC.

The initial scope is intentionally limited to the QUIC connection lifecycle.

## Why QUIC?

QUIC is a useful validation target because it contains:

- explicit behavior
- events
- state transitions
- lifecycle constraints
- client/server interaction
- entities with independent state

Without requiring a large application architecture.

## Validation Goals

This example should help answer the following questions:

### Workflow

Can BehavioML describe protocol behavior naturally?

QUIC workflows now use sequence-diagrammable object steps where the scenario has a clear ordered spine. Client/server packet exchanges use explicit `from`/`to` role boundaries, while local endpoint processing uses `from`-only steps. Lifecycle legality remains primarily represented by the connection state machine rather than being forced into sequence-diagram control flow.

### Event

Can events act as the bridge between workflows and state transitions?

### State Machine

Can state machines own transitions without duplicating workflow information?

### Entity

Are Connection and Stream valid examples of entities?

### Roles

Do concepts such as Client and Server require new modeling constructs?

### YAML

What is the minimal YAML structure required to represent the model?

## Initial Scope

Model only:

```text
Connection Lifecycle
```

Examples:

```text
Initial
Handshake
Connected
Closing
Draining
Closed
```

Do not model:

- congestion control
- packet formats
- stream internals
- transport parameters
- TLS details

unless required by the validation.

## Expected Outcome

The example should produce:

1. A refined meta-model.
2. Candidate YAML structures.
3. A list of gaps discovered during modeling.

The example should drive the language.

The language should not be designed entirely in the abstract.

## Generated views

Generated Mermaid diagrams are available under:

```text
generated/mermaid/
```

These files are derived from the model and should be regenerated after model changes.
