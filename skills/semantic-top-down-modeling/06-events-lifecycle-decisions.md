# Phase 06 — Events, lifecycle, and decisions

## Purpose

Add meaningful observable events, lifecycle transitions, and decisions after semantic areas, vocabulary, workflows, and capabilities are stable.

This phase constrains behavior without turning workflows into executable control flow.

## Sources of truth

Follow:

- `docs/model-rules.md`
- `docs/semantic-top-down-modeling.md`
- `docs/design-notes/0006-behavioml-and-uml-boundary.md`
- `docs/design-notes/0007-implementation-guidance-boundary.md`
- `docs/design-notes/0008-lessons-from-whip.md`
- `skills/semantic-top-down-modeling/PLAN.md`

## Preconditions

Phase 05 must be complete.

Workflows and capabilities should be stable enough to reveal meaningful occurrences, lifecycle transitions, and modeling decisions.

If workflows or capabilities are unstable, stop and return to the relevant earlier phase.

## Inputs to inspect

Inspect:

- source corpus;
- progress report;
- `model/semantic-areas/`;
- `model/workflows/`;
- `model/capabilities/`;
- `model/entities/`;
- `model/state-machines/`, if present;
- existing `model/events/`, if any;
- existing `model/decisions/`, if any;
- `docs/model-rules.md`;
- `docs/semantic-top-down-modeling.md`.

## Allowed changes

Allowed:

- create or update events;
- create or update state-machine transitions;
- create or update decisions;
- update progress report;
- make small workflow or capability corrections only if needed to fix a clear semantic inconsistency found during review.

Forbidden:

- adding events as generic success/failure labels;
- adding events as branch names;
- adding events as return values;
- adding events as helper completions;
- adding state machines for miscellaneous status labels;
- adding executable control flow;
- adding implementation exceptions;
- adding components or modules unless explicitly approved;
- adding technical contracts;
- adding traceability maps unless the user explicitly merges this phase with traceability.

## Event rules

Events represent meaningful observable occurrences that happened in the system.

Good event candidates:

- occurrences that trigger workflows;
- occurrences that trigger lifecycle transitions;
- protocol or domain occurrences relevant to audit, monitoring, recovery, or coordination;
- failures, timeouts, cancellations, or recovery signals that matter at system behavior level.

Bad event candidates:

- successful return;
- failed return;
- branch name;
- generic outcome;
- helper completion;
- status-code label;
- local implementation exception;
- payload validation result unless it is behaviorally meaningful and observable.

When unsure, prefer a capability, decision, traceability note, test gap, or out-of-scope note instead of creating an event.

## State-machine rules

State machines describe lifecycle constraints for coherent entities.

Transitions should use meaningful events.

Do not encode branching, algorithms, local exception handling, retry loops, or implementation scheduling in state machines.

If a transition needs multiple possible targets, model the alternatives explicitly rather than using multi-target transitions.

## Decision rules

Decisions explain rationale.

Use decisions for:

- modeling boundaries;
- tradeoffs;
- exclusions;
- why behavior is represented in one layer and not another;
- why source details are intentionally left to contracts, implementation guidance, tests, or traceability.

Do not use decisions to restate requirements.

## Procedure

1. Review workflows and capabilities for meaningful observable occurrences.
2. Create events only when they pass event discipline.
3. Review entity lifecycle skeletons.
4. Add state-machine transitions only for meaningful lifecycle constraints.
5. Add decisions for modeling boundaries and exclusions.
6. Demote suspicious event candidates to notes, decisions, traceability, tests, or out-of-scope findings.
7. Update the progress report.

## Output

- `model/events/**/*.yaml`
- updated `model/state-machines/**/*.yaml`
- `model/decisions/**/*.yaml`
- progress report update

## Validation and checks

Run repository validation if available.

Report unused events or missing transition warnings honestly.

Do not implement local validation.

## Commit

Suggested commit message:

```text
docs: refine events lifecycle and decisions
```

## Stop condition

Stop after committing this phase.

Do not add traceability or final reporting until the user confirms the next phase.
