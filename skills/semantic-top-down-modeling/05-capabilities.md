# Phase 05 — Capabilities

## Purpose

Refine capabilities under workflow context.

This phase turns minimal workflow capability stubs into stable behavior-level responsibilities and adds ordered internal decomposition only where the parent capability and workflow context make execution context clear.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0005-sequence-diagrammable-workflows.md`
- `skills/semantic-top-down-modeling/PLAN.md`

## Preconditions

Phase 04 must be complete.

Accepted workflows should exist and be owned by semantic areas.

If workflows are missing, stop and run Phase 04.

## Inputs to inspect

Inspect:

- source corpus;
- progress report;
- `model/semantic-areas/`;
- `model/workflows/`;
- existing `model/capabilities/`;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create or update capabilities;
- add `uses` only for ordered internal decomposition under clear parent context;
- add `requires` only when an architectural dependency boundary is behaviorally justified;
- update the progress report;
- add decisions only if a capability boundary or exclusion needs rationale and the user permits decisions in this phase.

Forbidden:

- creating new workflows except to fix a clearly broken Phase 04 omission with explicit user approval;
- adding role-to-role interactions inside capabilities;
- hiding callbacks, redirects, retries, protocol follow-ups, or responses inside `Capability.uses`;
- adding events unless the user explicitly moves event work into this phase;
- adding state-machine transitions;
- adding components or modules;
- adding traceability maps;
- adding wire schemas, payload grammar, OpenAPI, AsyncAPI, JSON Schema, protobuf, storage schemas, framework details, or implementation algorithms.

## Capability rules

Capabilities describe stable responsibilities.

A capability may be atomic or composite.

Use `Capability.uses` when:

- the parent capability and workflow-step context make execution context clear;
- the used capabilities are ordered internal responsibilities;
- no independent sender, receiver, observable message, callback, protocol exchange, or unclear role ownership is needed.

Do not use `Capability.uses` for:

- branching;
- loops;
- retries;
- concurrency;
- exception handling;
- data flow;
- transaction boundaries;
- runtime scheduling;
- role-to-role interactions.

If a sub-capability needs its own role interaction, it probably belongs in a workflow step, not in `uses`.

## Procedure

1. Review each workflow and its capability references.
2. Identify capabilities that are only stubs.
3. Improve descriptions so each capability states a stable responsibility.
4. Add `uses` only where ordered internal decomposition is clear and useful.
5. Avoid one capability per source sentence.
6. Avoid payload grammar and implementation mechanics.
7. Identify capability candidates that should instead be workflows, decisions, traceability notes, contract gaps, or out-of-scope notes.
8. Update the progress report with changes and demotions.

## Output

- refined `model/capabilities/**/*.yaml`
- optional decisions only when allowed and justified
- progress report update

## Validation and checks

Run repository validation if available.

Expected warnings about missing events, transitions, or traceability may be acceptable if those are intentionally deferred.

Do not implement local validation.

## Commit

Suggested commit message:

```text
docs: refine capabilities under workflow context
```

## Stop condition

Stop after committing this phase.

Do not add events, lifecycle transitions, or traceability until the user confirms the next phase.
