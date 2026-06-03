# QUIC Connection Lifecycle Modeling Notes

This is an exploratory BehavioML example, not a finalized language specification or final YAML schema.

## What was modeled

The model covers a small QUIC connection lifecycle slice:

- client-initiated connection establishment
- server-side acceptance of a connection attempt
- handshake completion as a lifecycle event
- endpoint-initiated connection close
- peer-initiated draining
- idle timeout
- connection lifecycle states from `initial` through `closed`

The model uses one file per model entity and path-based identity. Workflows involve roles, step through capabilities, and emit events. The connection state machine owns lifecycle transitions.

## What was intentionally not modeled

This example intentionally does not model:

- QUIC packet formats
- QUIC frame formats
- stream internals
- congestion control
- transport parameters
- TLS internals
- generated architecture diagrams
- implementation classes or method-level behavior

Those concerns are outside the connection lifecycle scope for this first validation example.

## Why Role was added

QUIC lifecycle behavior naturally uses participants such as client, server, and endpoint. These participants are not components, modules, entities, or implementations.

Role was added as a first-class exploratory entity to represent functional participants in workflows without forcing protocol participants into implementation-oriented concepts.

## Where the model feels natural

The separation between workflows, emitted events, and state-machine-owned transitions feels natural for connection lifecycle behavior. It lets workflows describe protocol activity while the state machine remains the source of truth for valid lifecycle movement.

Capabilities also feel useful as a bridge between workflows and implementation. They allow workflow files to avoid direct component references while still making implementation responsibilities visible through components.

## Where BehavioML needs further design

This example leaves several modeling details intentionally unresolved:

- whether `roles` should use bare path identities such as `client` or a typed reference form
- whether events should declare which entity or state machine consumes them
- whether capabilities should distinguish peer-visible protocol actions from internal lifecycle responsibilities
- whether interfaces should remain semantic dependency points or eventually include operations
- whether components should implement capabilities that are partly coordinated by other components
- how generated views should present role-to-capability-to-component relationships

## Open questions discovered while modeling QUIC

- Should a state machine transition support multiple possible source states using the current list syntax, or should that become a more explicit construct?
- Should `connection_close_timer_expired` represent both closing and draining timeout completion, or should draining have a separate timer event?
- Should idle timeout be modeled as a workflow, an event source, or a timer-driven state-machine concern?
- Should `client` and `server` be specializations of `endpoint`, or should role inheritance/composition be avoided?
- Should an event be namespaced by the entity it affects, for example `connection/handshake_completed`, or remain a flat path under `events/` for now?
- How much lifecycle detail is enough before the model starts becoming a protocol specification rather than a behavior model?
