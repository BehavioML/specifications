# 0008 - Lessons from WHIP

## Status

Proposed.

This note captures modeling lessons from adding a WHIP example.

WHIP was useful because it exercised a protocol shape not fully covered by the previous OAuth and QUIC examples:

- HTTP-created resources
- Location-based follow-up requests
- PATCH updates with different protocol meanings
- ICE trickle
- ICE restart
- bearer-token authorization
- 307 redirect follow-up
- problem/error workflows
- session/resource lifecycle state

---

## What WHIP validated

WHIP mapped naturally to the current BehavioML pattern:

```text
Workflow.steps  = observable protocol exchange
Capability.uses = ordered internal responsibility
State machines  = lifecycle validity
Decisions       = modeling boundary explanations
```

Observable HTTP requests and responses are good workflow steps because they define role interactions.

Endpoint-side work such as authorization, SDP validation, session allocation, resource creation, SDP answer generation, ICE candidate handling, and resource deletion fits well as ordered `Capability.uses` when the parent workflow step provides clear context.

ICE restart was especially useful because it showed that a PATCH request can carry behaviorally distinct semantics. The model should not collapse ICE restart into generic PATCH handling; candidate replacement is a meaningful responsibility.

---

## Boundary with implementation contracts

WHIP also validated the implementation-guidance boundary.

The BehavioML model should name behavioral responsibilities such as:

- validate SDP offer
- include Location information
- include ICE server links
- return problem response
- replace remote ICE candidates

But it should not expand into:

- full SDP grammar
- full ICE candidate grammar
- HTTP header schemas
- RFC 9457 problem-details schemas
- OpenAPI operation definitions
- media pipeline implementation
- STUN/TURN behavior
- browser API details

Those belong in implementation guidance, technical contracts, or generated/handwritten code.

---

## Entity relationships

WHIP exposed a gap around relationships between entities.

The model can define both:

```text
whip_session
whip_resource
```

but it has no first-class way to say that a WHIP resource represents, addresses, controls, or is the protocol handle for a WHIP session.

Today that relationship is implied through descriptions, workflow order, and shared events.

That is workable, but weaker than ideal for protocols where resource identity is behaviorally important.

A future lightweight relationship mechanism may be useful:

```yaml
relationships:
  - type: represents
    target: whip_session
```

This should not become an ERD or database schema mechanism.

It should describe behaviorally relevant conceptual relationships between model entities.

---

## Event semantics

WHIP also made event granularity harder to manage.

A complete behavioral model can naturally accumulate many events:

- request received
- authorization succeeded
- authorization failed
- resource created
- session established
- candidate received
- candidate applied
- restart requested
- candidates replaced
- problem response returned
- request rejected

Events are useful for workflows, state machines, and generated inspection views.

However, the current `Capability.events` field is intentionally neutral and can mean several things depending on context:

- event emitted on success
- event emitted on failure
- event observed by another role
- event internal to one role
- event used as a workflow trigger
- event used as a state-machine transition
- event naming a branch outcome

That neutrality has been useful while the language is exploratory, but WHIP shows that larger models may need clearer event semantics.

Possible future directions include distinguishing categories such as:

```text
emits
may_emit
observes
triggers
outcomes
```

or grouping capability events by outcome:

```yaml
events:
  success:
    - session_established
  failure:
    - authorization_failed
```

No change is adopted yet.

This needs a separate design discussion because it affects the core metamodel.

---

## Error workflows

WHIP error handling worked well when modeled as separate workflows:

- unauthorized request
- invalid offer
- unknown resource

This keeps failure behavior explicit and avoids hiding important branches inside happy-path workflows.

The cost is repetition:

```text
request arrives
validation fails
problem response is returned
```

For WHIP this is acceptable.

For larger protocols, BehavioML may need better conventions for error families or reusable rejection patterns.

That should not be solved by adding generic workflow control flow prematurely.

---

## Protocol-exchange metadata

WHIP showed that sequence diagrams could benefit from lightweight protocol metadata.

Useful behaviorally relevant hints include:

```text
method: POST / PATCH / DELETE
status: 201 / 204 / 200 / 307 / 401 / 403 / 404
payload kind: SDP offer / SDP answer / ICE fragment / problem response
resource effect: creates / updates / terminates
```

This information can improve diagrams, validation, and consistency.

However, it is close to OpenAPI territory.

A future mechanism, if introduced, should describe only behaviorally meaningful exchange metadata and must not become a full wire-contract schema.

Example direction:

```yaml
exchange:
  protocol: http
  method: POST
  payload: sdp_offer
  creates: whip_resource
```

This is not adopted yet.

---

## Generator implications

WHIP exposed a generator-view issue around expanded `Capability.uses`.

When a workflow step is a response:

```yaml
- from: whip_endpoint
  to: whip_client
  capability: whip/return_created_response
```

expanded uses are often response-preparation work performed by the sender.

A generator that places expanded uses over the receiver can make diagrams misleading.

For expanded uses, a better default may be:

```text
render uses over the parent step's actor/sender (`from`)
```

rather than always over the receiver (`to`).

This is a generator issue, not a model issue.

The model should not move response-preparation responsibilities to request-receipt capabilities merely to compensate for a renderer limitation.

---

## Tooling implications

WHIP also showed that authoring complete examples is mechanically verbose.

The one-file-per-entity rule remains useful, but examples like WHIP require many small YAML files.

Useful future tooling:

- model scaffolding commands
- workflow templates
- capability templates
- entity + state-machine templates
- generated README updates
- repository-level generation scripts such as `generate:examples`

These are tooling improvements, not metamodel changes.

---

## Current decisions

WHIP does not invalidate the current BehavioML model.

It strengthens the current core pattern:

```text
Workflow.steps  = ordered scenario spine with explicit role context
Capability.uses = ordered internal decomposition under the parent capability context
State machines  = lifecycle constraints
Decisions       = rationale and boundary explanation
```

The following remain out of core for now:

- full protocol payload schemas
- OpenAPI-style operation contracts
- implementation storage details
- media pipeline internals
- browser/runtime API details

The main follow-up areas are:

1. lightweight entity relationships
2. clearer event semantics
3. protocol-exchange metadata exploration
4. generator expanded-uses placement
5. generation scripts and scaffolding

---

## Open questions

- Should entity relationships be added as a common top-level field on entities?
- Which relationship types should be allowed, if any?
- Should event categories be part of `Capability.events`, or should event intent remain defined by workflow/state-machine usage?
- Can lightweight protocol metadata be added without becoming OpenAPI?
- Should expanded `Capability.uses` render over the sender by default, or should the generator support placement modes?
- How much authoring scaffolding should live in the generator versus a future editor?
