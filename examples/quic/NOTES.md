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

The model uses one file per model entity and path-based identity. Workflows involve roles, step through capabilities, and can emit contextual events. Capabilities can declare intrinsic events. The connection state machine owns lifecycle transitions.

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

The separation between workflows, capabilities, observable events, and state-machine-owned transitions feels natural for connection lifecycle behavior. It lets workflows describe protocol activity while capabilities identify intrinsic lifecycle events and the state machine remains the source of truth for valid lifecycle movement.

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

## Capability-level events

This variant tests whether events should be declared by capabilities rather than workflows. When an event is intrinsic to a capability, workflows can stay focused on sequencing behavior and causal relationships can be derived from:

```text
workflow step → capability → observable events
```

For this exploratory pass, connection establishment and connection-close signal events moved to the capabilities that perform those protocol actions. Timeout events remain workflow-level because the current capability model only says `connection/discard_connection_state` discards state for a closed or expired connection; it does not clearly model the timer or idle-timeout source that causes the discard. Assigning both `connection_close_timer_expired` and `idle_timeout_expired` to that one capability would make them possible-context outcomes rather than clearly intrinsic emissions.

Open questions:

- Can the same capability emit different events in different workflow contexts?
- Should capability `events` describe possible events or guaranteed events?
- Should workflows be able to override, filter, or contextualize emitted events?
- How should failure events be modeled?
- Can one capability declare multiple lifecycle events, or should that indicate the capability is too broad?

## Workflow per scenario

This variant avoids turning workflows into declarative code.

Instead of modeling success, failure, timeout, retry, and recovery branches inside one large workflow, each coherent behavioral scenario can be represented as a separate workflow.

Events can trigger follow-up workflows through `triggered_by`.

This keeps workflows readable, diff-friendly, and focused.

Open questions:

- When should behavior be a branch inside a workflow versus a separate workflow?
- Should `triggered_by` accept only events?
- Can a workflow be triggered by multiple alternative events?
- Should workflows declare preconditions separately from triggers?
- How should related workflows be grouped into a larger story or use case?
- Do we need a higher-level entity above Workflow, such as Scenario, Use Case, or Story?

## Sequence-diagrammable workflow object steps

The QUIC workflows were converted from legacy string steps to object workflow steps as an experiment in applying the sequence-diagrammable workflow shape to a protocol lifecycle model.

The best fit is the connection-establishment path. `client/establish_connection` and `server/accept_connection` now read as observable client/server scenario spines: the Initial packet crosses from client to server, followed by a compact Handshake exchange step. This keeps the workflow useful as a human-facing sequence diagram without expanding TLS, packet validation, key derivation, or transport parameter mechanics into the workflow.

The close and failure paths are a mixed fit. `client/handle_handshake_failure` works reasonably well because the client sends a Connection Close to the server and then discards local connection state. The generic endpoint workflows (`endpoint/close_connection`, `endpoint/drain_connection`, and `endpoint/handle_idle_timeout`) remain more lifecycle-oriented. They use `from: endpoint` local steps because the current role model has `client`, `server`, and generic `endpoint`, but no generic `peer` role. That avoids inventing a new participant solely to make a sequence diagram look more complete.

`from + to` works well for QUIC packets when the roles are concrete (`client` and `server`). It is less natural for generic endpoint lifecycle workflows because a packet may cross a network boundary even though the model intentionally abstracts away the opposite endpoint. In those cases, `from`-only steps are still useful for showing the endpoint responsibility, but they should not be read as a complete packet-level trace.

Several capabilities felt too internal for `Workflow.steps`. Peer validation is already part of `connection/perform_handshake` through `Capability.uses`, so the server acceptance workflow no longer carries `connection/validate_peer` as a separate scenario step. Other internal mechanics such as packet parsing, key derivation, connection-id selection, transport parameter recording, ACK handling, and detailed state updates remain intentionally outside the workflow spine.

The conversion did not suggest an immediate change to design note 0005 or 0006. Instead, it reinforces their boundary: workflows are useful as ordered observable scenario spines, while lifecycle legality remains the state machine's job and internal decomposition belongs in capabilities. QUIC also highlights one unresolved modeling awkwardness: generic endpoint workflows may need either an explicit peer role in a future pass or acceptance that some endpoint lifecycle workflows are not meant to produce complete role-to-role sequence diagrams.
