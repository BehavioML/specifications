# 0009 - Lessons from Quiver QUIC RFC audit

## Status

Proposed.

This note captures lessons from using BehavioML to model and audit parts of the QUIC RFC 9001 behavior in the Quiver repository.

The work was not an example-only exercise. It used BehavioML as an audit layer between IETF RFC text, Quiver implementation files, tests, and conformance gaps.

---

## Context

The Quiver work created a BehavioML workspace for QUIC and modeled several focused RFC 9001 slices:

- Section 5.2, Initial Secrets
- Retry-related Initial secret behavior from Section 5.2
- Section 5.3, AEAD Usage
- Section 5.4, Header Protection

The workflow used:

```text
RFC extracted section
  -> BehavioML model slice
  -> external traceability
  -> implementation/test audit report
  -> gap issues
```

It also introduced supporting repository conventions:

- extracted RFC source artifacts instead of full RFC imports
- canonical validation through `BehavioML/validator`
- generic IETF skills for RFC-to-BehavioML modeling
- generated audit reports under `generated/reports/`
- gap issues for implementation/test follow-up work

The result was useful, but it exposed pressure in several areas.

---

## What worked well

### RFC source artifacts worked better than full RFC imports

Keeping one focused extracted RFC section per file made agent work more reliable.

It avoided asking an agent to reason over a whole RFC at once, and it gave traceability stable local anchors such as:

```text
docs/behavioml/quic/rfcs/rfc9001/5.3-aead-usage.md
```

This confirmed a useful source-artifact pattern:

```text
external specification remains authoritative
local extracted sections are scoped modeling inputs
BehavioML captures behavior derived from the selected sections
```

The extracted source artifact is not a requirement index. It is a local, focused copy of the source material being actively modeled.

### Small source slices made review manageable

Modeling one RFC section at a time initially helped keep PRs small and reviewable.

Later, batching two related sections in one PR became attractive, but only with strict separation:

- one extracted source file per RFC section
- one traceability source entry per RFC section
- one audit report per RFC section
- shared model elements reused where appropriate

This suggests that BehavioML can support batched source modeling, but the batch must not collapse distinct source sections into one artifact or one audit trail.

### Validator integration was essential

YAML-valid models were not enough.

Early generated workflows used fields such as:

```text
action
event
emits
uses
produces
```

inside workflow steps. That produced plausible YAML but violated the intended sequence-diagrammable workflow shape.

The shared validator became a necessary guardrail. Quiver should not implement local validation logic; validation belongs in `BehavioML/validator`.

This reinforces a core principle:

```text
A BehavioML ecosystem needs canonical validation before examples and audits can scale.
```

### Audit reports found real implementation/test gaps

The audit workflow found concrete follow-up issues, including:

- Retry-driven Initial secret rederivation gaps
- zero-length Retry-selected DCID handling uncertainty
- missing focused tests for DCID-change retention
- missing or unclear header protection coverage for some algorithms
- partial AEAD associated-data connection-path evidence
- missing focused AEAD authentication tag corruption tests

This was a strong positive signal. BehavioML was not only documenting what the implementation already did; it was helping expose gaps.

### Behavior-first naming mostly held

Using RFC/domain terminology worked better than mirroring implementation classes.

Examples that fit well as BehavioML concepts:

```text
connection_id
initial_secret
protected_packet
packet_header
aead_nonce
header_protection_sample
```

Implementation classes such as `QuicAead`, `QuicPacketHeader`, and `QuicInitialSecrets` fit better as components or audit evidence, not as the main behavioral vocabulary.

---

## What did not work well

### Diagrams became too atomic

The generated workflow diagrams for RFC slices were often extremely small:

```text
endpoint -> endpoint: construct AEAD nonce
endpoint -> endpoint: build associated data
endpoint -> endpoint: apply payload protection
```

or even a single-step local workflow.

This was not necessarily wrong, but it reduced the value of sequence diagrams as human-facing behavioral documentation.

There are two likely causes:

1. Some RFC sections describe very atomic protocol mechanisms.
2. The modeling workflow encouraged one local capability per normative behavior, without enough composition into higher-level scenarios.

The existing design note on sequence-diagrammable workflows already warns that workflows should not become overly atomic and that internal detail often belongs in `Capability.uses`. The Quiver audit confirms that this is not just theoretical; RFC-driven modeling can easily push models toward algorithm-step diagrams.

### Source-section shape leaked into model shape

A source section is not always a good workflow boundary.

RFC 9001 Section 5.3 is about AEAD usage. It naturally contains several algorithmic responsibilities:

- construct nonce
- build associated data
- seal payload
- open payload

Those are valid capabilities, but a workflow for only those steps may be more of an algorithm outline than a behaviorally meaningful scenario.

A better distinction is needed:

```text
source slice: the RFC section being modeled
behavior slice: the BehavioML behavior worth adding
view slice: the generated diagram or audit view worth showing
```

These are related, but they are not the same thing.

### Traceability became overloaded

External traceability was useful in theory and helpful in practice, but the `source-map.yaml` started carrying several different responsibilities:

- source section to model mapping
- model to implementation-file mapping
- model to test-file mapping
- evidence status
- audit coverage hints

The source-to-model mapping felt clearly useful.

The implementation/test mappings were more ambiguous. They helped produce audit reports and gap issues, but they also risk turning `source-map.yaml` into a hand-maintained coverage matrix.

The better direction may be:

```text
traceability/source-map.yaml
  stable source artifact -> BehavioML model mappings

generated audit reports
  implementation/test evidence, coverage status, gaps, uncertainty
```

Implementation and test files can still be referenced in traceability if useful, but they should be treated as audit evidence, not as core model traceability.

### Generated reports were useful but not source of truth

Generated audit reports were valuable because they captured review context, implementation observations, test gaps, and next steps.

However, they must remain derived artifacts.

A report can say:

```text
Retry rederivation appears missing.
```

but it should not define new behavior.

If the behavior matters, it belongs in:

- the RFC source artifact
- the BehavioML model
- a decision
- or a follow-up issue

This is consistent with the implementation-guidance boundary, but the Quiver audit shows the same boundary applies to audit reports.

### Gap issue creation became part of the workflow

The most useful output of the audit was often not another model file, but a concrete implementation or test issue.

That suggests a useful lifecycle:

```text
source section modeled
  -> audit report generated
  -> gaps opened as issues
  -> implementation/tests fixed
  -> traceability/audit report updated
  -> validator and CI rerun
```

This is different from normal documentation workflows and should be treated as a first-class audit pattern.

---

## Design pressure discovered

### Need composition or view-level aggregation

BehavioML may need better conventions for composing atomic capability-level behavior into higher-level scenario views.

This does not necessarily require a new metamodel field.

Possible directions:

1. Prefer higher-level workflow steps and move low-level algorithmic detail into `Capability.uses`.
2. Generate collapsed views by default, with optional expanded capability decomposition.
3. Introduce report/view conventions that group local steps into named phases without changing the source model.
4. Treat some RFC algorithm sections as capability-only slices when they do not describe a meaningful role scenario.

The immediate lesson is:

```text
Not every modeled source slice needs its own useful sequence diagram.
```

A sequence diagram is useful when the behavior has role ownership, observable ordering, or interactions. For purely local cryptographic mechanics, capability and audit views may be more useful than sequence diagrams.

### Need a stronger source/audit separation

The Quiver work suggests a three-part distinction:

```text
Source traceability
  What source artifacts justify which model elements?

Audit evidence
  What implementation and tests were inspected, and what do they show?

Gap tracking
  What concrete follow-up work closes discovered gaps?
```

Only the first is core traceability.

The second belongs in generated reports or audit metadata.

The third belongs in issues or project tracking.

Trying to keep all three in one YAML structure risks drift and manual bookkeeping overhead.

### Need canonical skills, not repository-local prompt drift

The Quiver workflow quickly accumulated long prompts with repeated rules.

Extracting generic IETF and BehavioML skills was the right move.

The skills should live canonically in the BehavioML ecosystem, not diverge per repository.

Repository-local guidance should only add context such as paths, scope, commands, and local constraints.

---

## Candidate principle updates

The existing principles mostly held. The Quiver audit does not require BehavioML to become broader, more UML-like, or more implementation-specific.

However, it suggests several refinements.

### 1. Source slices are not behavior slices

A source document section is an input boundary, not necessarily a model boundary.

BehavioML should not mirror RFC headings mechanically.

A model slice should represent behaviorally meaningful responsibilities, scenarios, lifecycle constraints, and decisions derived from the source.

### 2. Not every behavior slice deserves a sequence diagram

A workflow should be a meaningful scenario.

If the modeled behavior is purely local, algorithmic, and has no useful role interaction, a capability-only model plus audit report may be more appropriate than creating an atomic workflow just to make a diagram.

### 3. Traceability should stay focused

The strongest traceability relationship is:

```text
source artifact -> BehavioML model element
```

Implementation and test links are valuable, but they should usually be treated as audit evidence or coverage reporting, not as core model traceability.

If implementation/test evidence is stored in traceability files, it must be clearly marked as evidence, not source-of-truth behavior.

### 4. Audit reports are derived evidence

Audit reports can summarize inspected code, tests, coverage status, gaps, and uncertainty.

They must not define behavior missing from the model.

Resolving an audit gap should update the model, implementation guidance, traceability, tests, or decisions as appropriate, then regenerate or update the report.

### 5. Validator-first modeling

Generated BehavioML must be validated by the canonical validator before review.

Repository-local validators should be avoided because they fragment the language definition.

Validation gaps should be fixed upstream in `BehavioML/validator`.

### 6. Gap issues are an expected audit output

When BehavioML is used for conformance audit, implementation/test gap issues are a normal output.

Each gap issue should say what must be updated when resolved:

- implementation and/or tests
- external traceability
- generated audit report
- canonical validator and CI results

---

## Possible repository convention

For RFC-backed models, a useful directory shape is:

```text
behavioml-root/
├── model/
├── rfcs/
│   └── rfc9001/
│       ├── 5.2-initial-secrets.md
│       ├── 5.3-aead-usage.md
│       └── 5.4-header-protection.md
├── traceability/
│   └── source-map.yaml
├── implementation/
│   └── AGENTS.md
└── generated/
    └── reports/
```

With this convention:

- `rfcs/` contains focused source artifacts
- `model/` contains behavior-first source model
- `traceability/source-map.yaml` maps source artifacts to model elements
- `generated/reports/` contains audit evidence and gap summaries
- `implementation/` contains local agent guidance and implementation workflow notes

---

## Current recommendation

Do not add new BehavioML metamodel fields yet.

Instead:

1. Tighten modeling guidance around source slices versus behavior slices.
2. Prefer capability decomposition or audit reports over atomic workflows when the source section is algorithmic.
3. Keep source-to-model traceability distinct from implementation/test audit evidence.
4. Continue moving reusable agent instructions into canonical skills.
5. Strengthen `BehavioML/validator` as modeling rules become clearer.

The Quiver audit supports the original behavior-first direction, but it shows that conformance-audit usage needs stronger conventions around composition, traceability scope, and generated evidence.
