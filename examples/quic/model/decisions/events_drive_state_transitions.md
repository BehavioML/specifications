# Events drive state transitions

## Decision

Workflows emit events, and the connection lifecycle state machine owns transitions triggered by those events.

## Rationale

This keeps workflow behavior separate from lifecycle validity. Workflows describe what participants do; the state machine defines which state transitions are allowed.

## Consequences

Workflow files do not contain `from` or `to` state transitions. State transition information appears only in the connection lifecycle state machine.
