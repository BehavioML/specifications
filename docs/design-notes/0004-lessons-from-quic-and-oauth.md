# 0004 - Lessons from QUIC and OAuth

## Status

Accepted as current design observation.

This note captures what we have learned from modeling two different domains with the same exploratory BehavioML concepts:

- QUIC connection lifecycle
- OAuth 2.0 Authorization Code Flow

It does not introduce new schema rules.

---

## Why this comparison matters

The QUIC and OAuth examples stress different parts of BehavioML.

QUIC is mostly about protocol lifecycle, endpoints, transport events, timeouts, and connection state.

OAuth is mostly about business/security behavior, human and system roles, redirects, consent, token issuance, and authorization artifacts.

If the same core concepts can model both domains without adding domain-specific schema, the metamodel is probably general enough to continue evolving incrementally.

So far, the same basic concepts have worked across both examples.

That is a useful signal.

---

## Concepts that worked in both examples

### Workflow

`Workflow` works well as a behaviorally meaningful scenario.

In QUIC, workflows describe scenarios such as establishing a connection, handling handshake failure, closing, draining, or idle timeout handling.

In OAuth, workflows describe scenarios such as starting authorization, handling an authorization request, issuing an authorization code, exchanging a code for tokens, calling a resource server, denying authorization, or rejecting an invalid code.

The important observation is that workflows stayed readable when they represented one scenario rather than a complete executable graph.

Failure and recovery paths worked better as separate workflows than as inline branches.

---

### Role

`Role` works as a functional participant rather than an implementation component.

In QUIC, roles such as client, server, and endpoint capture protocol participation without implying modules or classes.

In OAuth, roles such as resource owner, client, authorization server, resource server, and user agent capture the different participants in the flow.

The OAuth example is especially useful because `user_agent` is behaviorally relevant even though it is not an OAuth endpoint in the same sense as the authorization server or client.

Modeling the user agent as a role worked without requiring a new participant type.

---

### Capability

`Capability` works as a responsibility boundary.

In QUIC, capabilities describe responsibilities such as sending initial data, performing a handshake, validating peer state, entering closing, or discarding connection state.

In OAuth, capabilities describe responsibilities such as building authorization requests, obtaining consent, validating redirect URIs, issuing authorization codes, validating authorization codes, issuing tokens, validating access tokens, and returning protected resources.

This reinforces the idea that capabilities are not methods, classes, or implementation functions.

They are model-level responsibilities that workflows can step through and components can implement.

---

### Event

`Event` works as an observable occurrence that can connect capabilities, workflows, and state machines.

In QUIC, events represent protocol lifecycle observations such as handshake completion, handshake failure, close frames, idle timeout, or transition triggers.

In OAuth, events represent business/security observations such as authorization requested, consent granted, consent denied, authorization code issued, token request received, tokens issued, and protected resource returned.

The same event concept works for both transport-level and business-level behavior.

This is a strong sign that `Event` should remain generic and not be restricted to technical protocol events.

---

### Entity

`Entity` works as the owner of behaviorally relevant state.

In QUIC, `connection` is a natural entity because it owns lifecycle state.

In OAuth, `authorization_code`, `access_token`, and `consent_grant` are behaviorally relevant artifacts with state, lifetime, and security meaning.

The OAuth example is important because it shows that entities are not only long-running runtime objects such as connections.

They can also be business/security artifacts.

---

### StateMachine

`StateMachine` works as the owner of lifecycle transitions.

In QUIC, state machines describe connection lifecycle.

In OAuth, the authorization code lifecycle uses states such as requested, issued, redeemed, expired, and rejected.

This confirms that state machines are useful outside transport protocols.

The QUIC example also revealed that `transitions[].from` should allow a non-empty array of source states when the same event causes the same transition to the same target state from multiple origins.

The target state remains scalar.

---

### Component and Module

`Component` and `Module` work as implementation and ownership mapping, not as behavior owners.

In both examples, workflows step through capabilities rather than components.

Components implement capabilities and interfaces.

Modules provide ownership, packaging, or organizational boundaries.

This separation has held up well so far.

It helps prevent the model from becoming an implementation class diagram.

---

### Decision

`Decision` works as the place to preserve rationale.

Both examples surfaced modeling choices that are not obvious from YAML structure alone.

Examples include:

- modeling workflows as scenarios instead of executable graphs
- modeling `user_agent` as a role
- modeling authorization code as an entity
- modeling consent as both persisted state and observable events
- allowing multiple `from` states in state-machine transitions

Decision records are useful because they explain why the model looks the way it does.

---

## Lessons from QUIC

QUIC stressed lifecycle modeling.

The most useful lessons were:

1. State machines are useful for protocol lifecycle.
2. Failure and timeout behavior should usually be separate workflows rather than inline workflow branches.
3. Workflows should not become executable graphs.
4. `transitions[].from` needs to support multiple equivalent source states.
5. `transitions[].to` should remain scalar to avoid hidden conditional branching.
6. Validator feedback can reveal modeling decisions, not just mistakes.

The array-valued `from` case is the clearest example.

The validator initially treated array-valued source states as invalid.

The real model showed that this was too strict.

The rule was refined to allow:

```yaml
from:
  - handshaking
  - connected
on: connection_close_received
to: closing
```

This compactly represents equivalent transitions without introducing branching semantics.

---

## Lessons from OAuth

OAuth stressed business/security behavior.

The most useful lessons were:

1. Human and mediation roles can be modeled as roles when behaviorally relevant.
2. Consent can be both persistent state and observable events.
3. Authorization code is a good entity/state-machine example outside transport protocols.
4. Root or externally initiated workflows remain an open question.
5. `triggered_by` works for event-triggered workflows, but should remain optional.
6. The model did not need OAuth-specific schema to be useful.

The `user_agent` role is especially informative.

OAuth redirects depend on browser mediation.

Treating the user agent as a role captured that behavioral participation without creating a new concept.

Consent is also informative.

The model can represent:

```text
entities/consent_grant.yaml
```

for persisted authorization state, while also representing:

```text
events/consent_granted.yaml
events/consent_denied.yaml
```

for observable outcomes.

This separation worked naturally with the current rules.

---

## What we did not need to add yet

After modeling QUIC and OAuth, we still have not needed to introduce:

- `Scenario`, `UseCase`, or `Journey` as a first-class entity
- an `Actor` versus `Role` split
- a separate `Artifact` entity type
- inline workflow branching
- executable workflow graphs
- a workflow `kind` enum
- a generic `trigger` object
- architecture as a source-of-truth entity
- classes, objects, methods, inheritance, or implementation patterns

This matters because each avoided concept keeps the metamodel smaller.

The current model is not complete, but it has avoided premature specialization.

---

## Open metamodel questions

### Root and externally initiated workflows

Both examples include workflows without `triggered_by`.

In QUIC, some workflows are naturally root or externally initiated.

In OAuth, `client/start_authorization.yaml` represents an externally initiated user or application action.

This raises the question:

```text
Should BehavioML explicitly distinguish root, external, actor-initiated, and event-triggered workflows?
```

Current position:

- do not add `kind`
- do not add `entry: true`
- do not add a generic `trigger` object yet
- keep `triggered_by` event-specific and optional
- use neutral validator wording such as `workflows without explicit trigger`

---

### Lifecycle states without modeled transitions

OAuth includes lifecycle states such as `expired` even when the example does not model the timeout scenario that reaches the state.

This raises the question:

```text
Should a declared but currently unreached state be a warning, accepted future behavior, or both?
```

Current position:

- coverage findings should remain informational
- examples should not invent fake events just to satisfy coverage
- future scenarios can add the missing transitions when the behavior is in scope

---

### Duplicate event declarations

Some events may be declared by more than one capability.

This can mean intentional shared observability.

It can also indicate ambiguity about where an observable occurrence is owned.

Current position:

- do not reject duplicate event declarations
- treat events as shared observable occurrences
- revisit ownership only if examples show confusion

---

### Consent lifecycle

OAuth models consent as both an entity and events.

A larger model might add a consent lifecycle state machine.

Current position:

- consent does not need a lifecycle state machine in the small OAuth example
- add one only when the model scope includes grant revocation, expiry, re-consent, or policy changes

---

## Validator feedback

The validator has become part of the design loop.

The loop is:

```text
model
  -> validate
  -> inspect coverage
  -> discover metamodel questions
  -> refine rules or examples
```

Examples so far:

- QUIC revealed that `transitions[].from` should allow multiple source states.
- OAuth reinforced that workflow initiation semantics are still unresolved.
- Coverage output helps identify gaps without forcing schema changes.

The validator should remain descriptive before it becomes prescriptive.

Errors should catch structural inconsistency.

Coverage should expose model shape and possible gaps.

Coverage should not force authors to add fake events, fake transitions, or artificial metadata.

---

## Current position

The current metamodel is holding up across both examples.

That does not mean it is final.

It means the next work should focus on:

- generating useful views from the model
- refining workflow initiation semantics carefully
- keeping coverage informational
- adding more examples only when they stress genuinely new domains
- avoiding premature schema expansion

The next useful stress test is likely not another protocol example.

A future example should probably involve human approval, business lifecycle, or collaboration workflows.

Before that, generated views may reveal whether the relationships already present in the model are understandable to humans.
