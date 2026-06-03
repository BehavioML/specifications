# Model connection lifecycle only

## Decision

This exploratory example models only the QUIC connection lifecycle.

## Rationale

The lifecycle is enough to exercise workflows, capabilities, events, entities, and state machines without turning the example into a full QUIC specification.

## Consequences

The model includes establishment, connected operation as a lifecycle state, closing, draining, idle timeout, and final state discard. It intentionally avoids streams, packet layout, congestion behavior, transport parameters, and TLS internals.
