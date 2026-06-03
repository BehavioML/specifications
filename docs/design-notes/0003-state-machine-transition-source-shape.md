# 0003 - State machine transition source shape

## Status

Accepted as current exploratory direction.

---

## Context

The validator shape-rules PR tested the current rules against the real QUIC model in `BehavioML/specifications`.

The validation found that the QUIC lifecycle state machine uses array-valued `transitions[].from` entries.

Example:

```yaml
from:
  - handshaking
  - connected
on: connection_close_received
to: closing
```

The initial proposed rule required `transitions[].from` to be a scalar string.

That rule was too strict for the model we already had.

---

## Decision

`StateMachine.transitions[].from` may be either:

- a single state string
- a non-empty array of state strings

`StateMachine.transitions[].to` remains scalar-only.

`StateMachine.transitions[].on` remains an event reference.

---

## Rationale

Multiple source states are useful when the same event causes the same transition to the same target state from several origins.

This is a compact way to express equivalent transitions without duplicating transition objects.

Example:

```yaml
transitions:
  - from:
      - handshaking
      - connected
    on: connection_close_received
    to: closing
```

This is equivalent to writing:

```yaml
transitions:
  - from: handshaking
    on: connection_close_received
    to: closing

  - from: connected
    on: connection_close_received
    to: closing
```

The compact form is easier to maintain when the event and target state are identical.

---

## Why `to` remains scalar

Multiple target states would introduce a different semantic problem.

Example:

```yaml
from: connected
on: connection_close_received
to:
  - closing
  - draining
```

This implies conditional branching or nondeterminism.

BehavioML should not encode that implicitly in the transition shape.

If multiple targets are needed, the condition or distinction should be modeled explicitly rather than hidden inside an array-valued `to` field.

Therefore:

```text
from: string | non-empty string[]
to: string
```

---

## Validator implications

The validator should accept:

```yaml
from: connected
```

and:

```yaml
from:
  - handshaking
  - connected
```

It should reject:

```yaml
from: []
```

and:

```yaml
from:
  - handshaking
  - 42
```

It should also reject array-valued `to`:

```yaml
to:
  - closing
  - draining
```

When `states` is declared, every source state listed in `from` should reference a declared state.

The target state in `to` should also reference a declared state.

---

## Consequences

This keeps state machines compact without turning transitions into hidden branching logic.

The model supports many source states for one transition, but not many target states for one transition.

That distinction is intentional:

- multiple `from` states collapse equivalent transitions
- multiple `to` states imply different outcomes

---

## Open questions

- Should repeated transition groups be normalized in generated diagrams?
- Should generated views expand array-valued `from` into individual edges?
- Should validators warn when too many source states are grouped in one transition?
- Should future transition conditions be modeled explicitly if multiple targets are needed?
