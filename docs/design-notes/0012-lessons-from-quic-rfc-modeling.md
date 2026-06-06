# 0012 - Lessons from QUIC RFC semantic top-down modeling

## Status

Proposed.

This note follows `0010 - Afterthought: semantic-first RFC modeling` and
`0011 - Semantic areas and progressive modeling`.

Those notes established that source sections are evidence rather than model
structure, and that semantic areas should organize workflows. This note captures
lessons from applying the semantic top-down process to a broad QUIC corpus based
on RFC 9000 and RFC 9001.

---

## Context

A QUIC model was derived from RFC 9000 and RFC 9001 using the semantic top-down
modeling skill.

The model was built progressively:

```text
source survey
  -> semantic areas
  -> vocabulary
  -> workflow candidates
  -> accepted workflows
  -> capabilities
  -> events, lifecycle, decisions
  -> external traceability and report
```

The goal was not to replace the RFCs.

The goal was to create a reviewable behavior-first model that helps humans and
tools discuss QUIC behavior, diagram scenarios, identify lifecycle constraints,
classify gaps, and plan downstream implementation or audit work.

The experiment was useful, but it also exposed limits and places where the
process and tooling should be tightened.

---

## Summary

BehavioML worked best as a semantic review layer between RFC prose and downstream
implementation work.

It was useful for:

- organizing QUIC behavior into semantic areas;
- identifying role-aware workflow spines;
- separating workflows from local capabilities;
- making lifecycle-changing protocol occurrences explicit as events;
- constraining state-machine transitions;
- recording modeling boundaries through decisions;
- keeping RFC evidence in external traceability rather than model files;
- classifying modeling, contract, test, implementation-guidance, and out-of-scope
  gaps.

It was not useful as, and should not become:

- a replacement for the RFC;
- a packet/frame grammar;
- a TLS or cryptographic algorithm model;
- a recovery or congestion-control algorithm model;
- an implementation design document;
- a conformance test suite.

The RFC remains the normative source. The BehavioML model is a behavior-first
review, navigation, diagramming, and planning artifact.

---

## What worked well

### Phase discipline

The phased process reduced section-shaped modeling.

Starting with a whole-corpus source survey made it possible to identify semantic
areas before creating workflows, capabilities, or events. That prevented many
obvious anti-patterns:

```text
one RFC section -> one workflow
one normative paragraph -> one capability
one frame type -> one workflow
one transport parameter -> one entity
```

For a protocol such as QUIC, this is critical. RFC 9000 and RFC 9001 contain
interaction behavior, lifecycle constraints, wire formats, local endpoint
obligations, security considerations, and cryptographic integration details.
Those source concerns do not map one-to-one onto BehavioML concepts.

### Semantic areas as review boundaries

Semantic areas provided useful behavior-first navigation.

Examples that worked well for QUIC include:

```text
connection establishment and handshake
version negotiation
transport parameters
TLS integration and encryption levels
packet protection and protected receive
0-RTT use
key lifecycle and update
connection lifecycle and termination
connection ID lifecycle and routing
path validation
connection migration
packet number spaces and reliability signals
stream and flow control
datagram size and path MTU
```

These areas are not a copy of the RFC table of contents. They describe coherent
behavior areas that survive source-document reorganization.

### Workflow candidate review

The workflow candidate gate was one of the most valuable parts of the process.

It forced each candidate to answer:

```text
Who does what, with whom, in what observable or behaviorally meaningful order?
```

That helped demote or defer local mechanics such as packet parsing, TLS library
operation, ECN validation, key discard, PMTU probing, ICMP feedback, and recovery
algorithms.

The model became most useful when workflows were limited to high-confidence
interaction or lifecycle-changing scenarios.

### Capabilities after workflows

Creating capabilities after workflow spines were understood avoided premature
responsibility decomposition.

Minimal capability stubs were initially necessary so workflow step references
could resolve. Later refinement improved descriptions under workflow context
without adding `uses` where ordered internal decomposition was not clearly
justified.

That was the right default. Adding `Capability.uses` too early would have risked
hiding role-to-role interactions, callbacks, responses, retries, or protocol
follow-ups inside capabilities.

### Events and lifecycle review

QUIC has many lifecycle-significant occurrences that are not merely messages:

```text
handshake confirmed
idle timeout expired
stateless reset detected
keys available
keys discarded
path validated
0-RTT accepted or refused
packet number space discarded
stream final size known
```

Representing these as events and state-machine transitions made implicit
protocol moments reviewable.

The review process also found and corrected semantic mistakes. For example:

- idle timeout was corrected from a conditional peer-directed close into local
  lifecycle expiration;
- 0-RTT acceptance/refusal was modeled as lifecycle events rather than a
  synthetic server-to-client outcome message;
- stream send-side lifecycle was changed to use acknowledgment events instead of
  receive-side events;
- stream receive-side lifecycle was changed to distinguish generic data arrival
  from all required data being received;
- connection ID issuance was changed from a no-op transition into a meaningful
  lifecycle transition.

These corrections show that state machines and events are useful precisely
because they make hidden assumptions visible.

### External traceability

Keeping source traceability outside `model/` was the right architectural choice.

Traceability should answer:

```text
Which source text supports this model element?
```

It should not answer:

```text
Which model file did this source heading create?
```

This allowed RFC sections to remain evidence anchors without becoming model
structure.

---

## What was difficult

### RFCs are not behavior-first

Protocol RFCs are organized for specification and conformance. They are not
organized as semantic workflows.

In QUIC, one source section may contain several kinds of material:

- role-to-role protocol exchange;
- local endpoint obligation;
- lifecycle transition;
- packet or frame grammar;
- error condition;
- security analysis;
- pseudocode or algorithmic guidance;
- traceability-only evidence.

The hard modeling question was usually not how to write YAML. It was deciding
whether a source concept should become:

```text
workflow
capability
event
state-machine transition
decision
external traceability
contract gap
implementation guidance gap
test gap
out of scope
```

That decision requires semantic judgment.

### Events are easy to make misleading

Event names are not the main issue. The issue is whether an event represents a
meaningful occurrence that happened in the modeled system.

The QUIC pass showed that generic event names can be ambiguous. For example,
`stream_data_received` can mean:

- some stream data arrived;
- all stream data required by the receive lifecycle arrived;
- the send side received acknowledgment from the peer.

Those are different lifecycle meanings and should not share one event.

The fix was not to ban event-name patterns. The fix was to use more precise
events where lifecycle semantics required precision, such as:

```text
stream_all_data_received
stream_data_acknowledged
stream_reset_acknowledged
```

### Some capabilities remain thin until later review

Phase 04 required capability stubs for workflow references. Some of those stubs
look thin until Phase 05 refines their descriptions.

That is acceptable if they remain stable behavior-level responsibilities. It is
preferable to premature decomposition that encodes implementation or hides
interactions.

### Traceability is valuable but manual

The traceability map was useful, but it is expensive to maintain manually.

Without tooling, traceability can drift:

- model references can become stale;
- source anchors can become inconsistent;
- gaps can be misclassified;
- reviewers may not know whether coverage is complete or merely plausible.

---

## Position

Semantic top-down modeling is appropriate for large protocol RFCs, but only when
BehavioML is treated as a behavior-first review layer.

The preferred relationship is:

```text
RFC / source specification
  -> semantic top-down BehavioML model
  -> diagrams, lifecycle review, gap analysis, generation planning
  -> external contracts / implementation guidance / tests / code
```

Do not collapse these layers.

BehavioML owns behavior, responsibilities, lifecycle constraints, and modeling
rationale.

RFCs own normative protocol text.

External contract languages own wire schemas and technical contracts.

Implementation guidance owns code-facing decisions outside the model.

Tests own executable conformance checks.

---

## Protocol RFC modeling guidance

When modeling a protocol RFC, use the following guidance.

### Workflow candidates

A protocol behavior is a strong workflow candidate when it has at least one of
these properties:

- observable role-to-role protocol exchange;
- meaningful change in which role acts or receives;
- system-level failure, rejection, timeout, recovery, or cancellation scenario;
- lifecycle impact that would make diagrams misleading if omitted;
- behavior needed to make a semantic area understandable.

Do not create a workflow merely because:

- an RFC section exists;
- a normative sentence exists;
- a frame type exists;
- a packet format exists;
- a local algorithm is specified;
- a parser or validator branch exists;
- a test obligation exists.

### Capabilities

Capabilities should describe stable responsibilities under workflow context.

Use `Capability.uses` only when the parent capability and workflow context make
ordered internal decomposition clear.

Do not use `uses` to hide:

- role-to-role interactions;
- callbacks;
- responses;
- retries;
- redirects;
- protocol follow-ups;
- data flow;
- scheduling;
- exception handling;
- local algorithms.

### Events

Events should represent meaningful occurrences that happened in the modeled
system.

Do not create events merely as:

- return values;
- branch names;
- helper completions;
- generic success or failure labels;
- status-code aliases;
- local exception names;
- implementation outcomes.

Prefer event review questions over naming heuristics:

```text
Did this occurrence happen in the protocol or system?
Does it drive or constrain lifecycle?
Would omitting it make state-machine review misleading?
Is it more than a helper return value or branch label?
Is the event precise enough for the lifecycle transition it drives?
```

Avoid validator rules that rely on event-name suffixes alone. Names such as
`accepted`, `refused`, `validated`, or `confirmed` can be valid when they denote
observable lifecycle occurrences. They can also be wrong when they are merely
outcome labels. The distinction is semantic, not lexical.

### State machines

State-machine transitions should be lifecycle constraints, not executable control
flow.

Review transitions for:

- events that resolve;
- source and target states that are declared;
- no accidental no-op transitions;
- no reuse of an event across incompatible lifecycle meanings;
- no algorithmic loops, retries, or scheduling encoded as transitions.

A no-op transition such as:

```text
available -> available
```

should usually be removed or replaced with a meaningful prior state if the event
matters.

### Decisions

Use decisions for modeling boundaries and rationale.

Good decision subjects include:

- why wire grammar is out of the core model;
- why a lifecycle was deferred;
- why an occurrence is an event rather than a workflow message;
- why an algorithm belongs to another RFC or downstream artifact;
- why behavior remains traceability-only.

Do not use decisions to restate RFC requirements.

---

## Traceability guidance

External traceability should be a first-class artifact for RFC-backed models.

It should remain outside the source-of-truth model root.

A traceability map should answer:

```text
Which source text supports this model element?
```

It should not answer:

```text
Which model file was generated from this source heading?
```

### Prefer navigable source anchors

Textual section labels are useful for humans, but tooling should prefer stable,
navigable anchors.

For RFC sources, prefer source artifacts that preserve section anchors, such as
HTML or normalized Markdown, and traceability entries shaped around anchor IDs.

Example direction:

```yaml
sources:
  rfc9000:
    title: "RFC 9000 - QUIC: A UDP-Based Multiplexed and Secure Transport"
    artifact: docs/behavioml/quic/rfcs/rfc9000.html
    canonical_url: https://www.rfc-editor.org/rfc/rfc9000.html

traceability:
  - model_elements:
      - workflows:client/establish_connection
    supported_by:
      - source: rfc9000
        anchors:
          - id: "#section-7"
            title: "Cryptographic and Transport Handshake"
          - id: "#section-17.2.2"
            title: "Initial Packet"
```

Plain text artifacts can still be used, but they are weaker for generated
review, explorer navigation, and anchor validation.

### Traceability validation

Traceability should eventually have validation separate from core model shape
validation.

Useful checks include:

- every traceability model element resolves;
- every source ID resolves;
- every anchor exists in the referenced source artifact;
- every gap category is from an allowed taxonomy;
- every model element is either traced or explicitly listed as a gap, deferred,
  or out of scope;
- model files do not contain source references;
- traceability does not introduce model ownership.

---

## Gap classification guidance

Not every missing item should become model structure.

Classify gaps explicitly:

| Gap type | Meaning |
| --- | --- |
| Source gap | The source corpus is missing needed behavior evidence. |
| Modeling gap | The behavior is in scope but not modeled yet. |
| Contract gap | The missing artifact belongs in a technical contract or schema. |
| Implementation guidance gap | The missing artifact belongs outside the model as code-facing guidance. |
| Test gap | The missing artifact should become test planning or conformance coverage. |
| Out of scope | The item belongs to another RFC, artifact, or modeling pass. |

For QUIC, packet/frame grammar, transport-parameter encoding, cryptographic
payload details, and RFC 9002 recovery algorithms are not automatically modeling
gaps in a RFC 9000/RFC 9001 behavior model. They are contract, traceability,
implementation, test, or out-of-scope concerns depending on the task.

---

## Tooling implications

### Core validator

Core validators should continue to focus on structural model correctness:

- reference resolution;
- allowed fields;
- workflow step shape;
- role declaration and use;
- semantic-area workflow ownership;
- state reference resolution;
- transition event resolution;
- duplicate ownership checks;
- unsupported source refs in model files.

Avoid lexical event-name heuristics as validator rules. They will create false
positives and push modeling toward arbitrary naming conventions.

### Traceability validator

A separate traceability validator or report should check source maps, anchors,
coverage, and gap classifications.

This validator should not require traceability inside model files.

### Generated review views

Generated views are especially useful for protocol models:

- semantic area overview;
- semantic area to workflow table;
- sequence diagrams from workflows;
- state diagrams from state machines;
- event-to-transition tables;
- capability inventory by workflow context;
- traceability coverage report;
- gap/readiness report.

These are review artifacts. They should not become source of truth.

---

## Rejected directions

### Replace the RFC with BehavioML

Rejected.

The RFC remains the normative source. BehavioML is a semantic behavior model and
review layer.

### Model RFC sections directly

Rejected as the initial modeling strategy.

Source sections are evidence anchors. They can deepen or audit an existing
semantic model, but they should not create the initial model structure.

### Add event-name heuristic linting

Rejected for now.

The QUIC pass showed that event quality depends on semantic meaning, not suffix
patterns. Some names that look outcome-like can be valid lifecycle events. Some
names that look safe can be ambiguous or wrong.

Prefer semantic guidance, review gates, and structural checks.

### Include tool/session workflow problems in BehavioML design

Rejected.

Branch handling, PR stacking, and agent session setup are repository workflow
issues. They can be documented in project operations, but they are not BehavioML
language or metamodel concerns.

### Treat implementation audit as a core phase

Rejected.

Implementation audit is valuable when code is in scope, but it is not part of the
semantic top-down modeling skill itself. It should be a separate task that uses
the completed BehavioML model as an input.

---

## Current position

For large protocol RFCs, semantic top-down modeling should remain the preferred
BehavioML approach.

The process should be strengthened by:

1. protocol-specific modeling guidance;
2. explicit workflow candidate review gates;
3. stronger event and lifecycle review guidance;
4. external traceability with navigable source anchors;
5. traceability validation separate from model validation;
6. generated review views for workflows, state machines, events, semantic areas,
   and traceability coverage.

Do not strengthen the process by adding source-section-shaped model structure,
implementation leakage, or lexical event-name rules.

---

## Open questions

- Should the semantic top-down skill include a formal human approval checkpoint
  between workflow candidate classification and workflow materialization?
- Should traceability source artifacts prefer HTML snapshots, normalized Markdown,
  or both?
- What is the minimal stable schema for navigable source anchors in external
  traceability maps?
- Should traceability validation live in the core validator, a separate validator,
  or generated reports?
- Should no-op state transitions be forbidden by the validator or reported as
  warnings?
- How should generated views present model elements that are intentionally
  untraced because they are deferred, out of scope, or downstream gaps?
