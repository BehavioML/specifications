# Workflow candidate gate

## Purpose

Use this gate before creating BehavioML workflow files.

The gate helps decide whether a behavior should become a workflow or should be demoted to a capability, decision, traceability note, state/event review, contract gap, implementation guidance gap, test gap, or out-of-scope note.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0005-sequence-diagrammable-workflows.md`
- `docs/design-notes/0006-behavioml-and-uml-boundary.md`
- `skills/semantic-top-down-modeling/PLAN.md`

This gate does not redefine workflow semantics.

## Core question

A workflow should answer:

```text
Who does what, with whom, in what observable or architecturally meaningful order?
```

If that question cannot be answered clearly, do not create a workflow yet.

## Create a workflow only when

Create a workflow only if at least one of these is strongly true:

- it is an observable role-to-role interaction;
- it changes which role acts or receives in a behaviorally meaningful order;
- it represents a system-level failure, rejection, recovery, timeout, or cancellation scenario;
- it changes, constrains, or explains lifecycle state;
- omitting it would make sequence diagrams or human review misleading;
- it is needed to make a semantic area's behavior understandable.

## Do not create a workflow when

Do not create a workflow if the behavior is only:

- local processing by one role;
- reusable response preparation;
- generic client-side handling;
- generic server-side handling;
- payload parsing;
- schema validation;
- status-code handling without domain/protocol-specific behavior;
- implementation algorithm;
- source section heading;
- normative sentence;
- capability decomposition;
- traceability evidence;
- test obligation.

## Confidence levels

### High confidence

Create the workflow only when all of these are true:

- clear semantic area owner;
- clear primary role;
- clear participants;
- clear ordered scenario spine;
- clear observable interaction or lifecycle impact;
- not merely local algorithmic behavior;
- not generic status or payload handling;
- not source-section-shaped.

### Medium confidence

Do not create the workflow yet.

Record it as `needs review` when:

- it may be a workflow or capability;
- it may duplicate another workflow;
- it may be too generic;
- it may be a reusable concern rather than a scenario;
- it may over-expand the semantic area;
- the lifecycle impact is unclear;
- the role boundary is unclear.

### Low confidence

Do not create the workflow.

Demote it and record the reason.

## Demotion rules

### Demote to capability

Demote to capability when:

- behavior happens inside an already modeled request/response workflow;
- it is ordered internal responsibility under a parent capability;
- it is local processing by one role with no separate role boundary;
- it is reusable response preparation;
- it names payload content without changing the scenario spine.

### Demote to decision

Demote to decision when:

- the important information is why a behavior is modeled or excluded;
- the source requires a boundary choice;
- the model intentionally avoids protocol grammar, implementation detail, hidden inference, or source-section coupling.

### Demote to traceability or audit note

Demote to traceability or audit note when:

- the source requires behavior but it creates no separate observable workflow;
- the behavior is local source-defined processing;
- it is important for conformance but not for the BehavioML scenario spine.

### Demote to state/event review

Demote to state/event review when:

- the behavior is primarily lifecycle change;
- the behavior is better represented as an event-triggered transition;
- the event discipline needs review before modeling it.

### Mark as contract gap

Mark as contract gap when:

- behavior exists but the missing detail is route, payload, schema, message, protocol field, status-code mapping, or wire contract detail.

### Mark as implementation guidance gap

Mark as implementation guidance gap when:

- behavior exists but missing detail is runtime, framework, storage, deployment, scheduling, retry policy, security policy, or implementation choice.

### Mark as out of scope

Mark as out of scope when:

- the behavior belongs outside the intended model boundary;
- the source describes external protocol internals;
- the source describes implementation, deployment, media pipeline, browser API, storage, or framework details.

## Candidate review table

Record candidates in a progress or review report before materializing workflows.

Use this format:

| Candidate workflow | Semantic area | Decision | Reason |
| --- | --- | --- | --- |
| `client/create_session` | `session-establishment` | accept | Observable setup exchange and created response define the area. |
| `client/handle_problem_response` | `problem-response-handling` | demote | Generic failed-response handling; better as capability, decision, or traceability unless tied to a concrete rejection workflow. |
| `candidate_silently_discarded` | `ice-candidate-trickle` | demote | Local source-defined processing; no separate observable workflow, event, or state. |

For each accepted or needs-review candidate, also record:

- primary role;
- participants;
- proposed steps;
- lifecycle impact, if any;
- why this is not merely a capability;
- why this is not merely traceability;
- risk of being too generic, too local, or too source-section-shaped.

## Materialization rule

Only high-confidence accepted workflows should be materialized automatically.

Medium-confidence candidates must remain in the report as `needs review` unless the user explicitly approves them.

Low-confidence candidates must not be materialized.

## Review checklist

Before creating or finalizing workflow files, check:

- Does each workflow have exactly one semantic area owner?
- Is the workflow behaviorally meaningful without reading the source section?
- Would a generated sequence diagram be useful?
- Are all role interactions explicit?
- Are local actions important enough to be shown?
- Are any steps actually capability decomposition?
- Are any workflows just generic status or error handling?
- Are any workflows just payload or schema handling?
- Are any workflows source-section-shaped?
- Are ambiguous candidates recorded instead of materialized?
- Are demoted candidates explained?
