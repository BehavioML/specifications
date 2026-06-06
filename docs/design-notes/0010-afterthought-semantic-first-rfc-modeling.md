# 0010 - Afterthought: semantic-first RFC modeling

## Status

Proposed.

This note is an afterthought to `0009 - Lessons from Quiver QUIC RFC audit`.

The Quiver QUIC audit showed that modeling an RFC by splitting it directly along textual section boundaries can lead to overly atomic BehavioML models. This note captures a better workflow for future RFC-backed modeling work.

---

## Problem

The initial Quiver workflow was roughly:

```text
RFC section
  -> extracted source artifact
  -> BehavioML model slice
  -> traceability
  -> audit report
```

This worked operationally, but it biased the model toward the shape of the RFC document.

That was useful for small, focused audits, but it also produced problems:

- workflows became very small and local;
- diagrams were often too atomic to be useful;
- capabilities sometimes mirrored algorithmic paragraphs rather than higher-level behavior;
- related protocol concepts were spread across several PRs because the RFC text was structured that way;
- implementation/test audit remained useful, but the model did not always reveal the broader architecture first.

The mistake was treating RFC sections as the primary decomposition unit.

RFC sections are source structure. They are not necessarily behavior structure.

---

## Preferred workflow

For a new RFC-backed BehavioML model, start top-down.

Do not immediately split the RFC into independent section-level modeling tasks.

Instead, first inspect the RFC as a whole and derive a semantic map.

Suggested workflow:

```text
1. Read / survey the RFC
2. Identify semantic domains or protocol fields
3. Identify major entities and state owners
4. Identify relationships between domains
5. Identify major roles and protocol participants
6. Identify lifecycle/state-machine constraints
7. Identify behaviorally meaningful workflows
8. Only then decompose into capabilities
9. Use RFC sections as source evidence and traceability anchors
```

This reverses the initial Quiver approach.

Instead of:

```text
RFC section -> local BML slice -> later composition
```

prefer:

```text
RFC overview -> semantic map -> model skeleton -> workflows -> capabilities -> RFC traceability
```

---

## Semantic domains before section slices

For QUIC, a semantic-first pass might identify domains such as:

```text
connection identity
packet number spaces
initial key derivation
packet protection
header protection
protected packet receive path
0-RTT key usage
key update
transport parameter negotiation
loss detection / recovery
connection migration
connection termination
```

These domains do not necessarily match RFC section boundaries exactly.

Some RFC sections contain several behaviors.

Some behaviors are distributed across multiple sections.

Some sections are mostly algorithmic detail and should become capability decomposition or audit evidence rather than standalone workflows.

---

## Modeling order

A useful order for RFC-backed modeling is:

### 1. Semantic map

Create a lightweight map of protocol areas and how they relate.

This can initially live as documentation or a generated exploration report. It does not need to be a formal BehavioML metamodel construct yet.

The goal is to avoid blindly mirroring the RFC table of contents.

### 2. Entities and state owners

Identify behaviorally relevant domain concepts early.

Examples:

```text
connection_id
packet_number_space
packet_number
initial_secret
packet_protection_key
protected_packet
quic_connection
```

This helps avoid creating isolated capability fragments without shared concepts.

### 3. Relationships between domains

Before workflows, understand conceptual dependencies.

Example:

```text
packet protection depends on packet number spaces, packet protection keys, AEAD nonce construction, and protected packet encoding
```

BehavioML does not currently have a first-class entity relationship mechanism, and this note does not propose adding one immediately.

However, the modeling process should still discover these relationships before generating detailed workflows.

### 4. Workflows

Define workflows only when there is a behaviorally meaningful scenario.

Good workflow candidates answer:

```text
who does what, with whom, in what observable or architecturally meaningful order?
```

Algorithmic local mechanics should not automatically become workflows just because the RFC has a section for them.

### 5. Capabilities

Define capabilities after the higher-level behavior is understood.

Capabilities should express stable responsibilities. They can be decomposed with `uses` when the parent capability supplies enough execution context.

This avoids creating one top-level workflow step for every normative sentence.

### 6. RFC traceability

Use RFC sections as evidence after the semantic model has structure.

Traceability should answer:

```text
which source text supports this model element?
```

not:

```text
which model file did we create for this source heading?
```

---

## When section-level modeling is still useful

Section-level modeling is still useful when:

- the section is behaviorally coherent;
- the section describes one focused protocol mechanism;
- the goal is a narrow audit of a known implementation area;
- the model skeleton already exists and the section fills in detail;
- traceability needs to be tightened for a specific conformance claim.

In other words, section-level work is better as a deepening step than as the first decomposition step.

---

## Implication for skills and agents

RFC-to-BehavioML skills should not encourage agents to process an RFC as independent chunks from the beginning.

A better skill structure may be:

```text
rfc-survey
  -> identify semantic domains, entities, roles, lifecycle constraints, and candidate workflows

rfc-domain-to-bml
  -> model one semantic domain using multiple RFC sections as evidence

rfc-section-audit
  -> audit or deepen one specific source section once the model skeleton exists
```

The existing section-batch workflow is still useful, but should be framed as a later refinement tool, not the default first pass.

---

## Principle

BehavioML models behavior, not document structure.

RFC sections are source evidence.

Semantic domains, roles, entities, workflows, states, and responsibilities should drive the model structure.

A useful test is:

```text
If the RFC were reorganized without changing protocol behavior, would this BehavioML model still have mostly the same shape?
```

If the answer is no, the model is probably too coupled to the document structure.

---

## Recommendation

For future RFC-backed modeling:

1. Start with an RFC-wide semantic survey.
2. Build a coarse model skeleton before detailed source extraction.
3. Use RFC sections as traceability anchors, not as the primary model decomposition.
4. Deepen one semantic domain at a time.
5. Add workflows after roles, entities, and domain relationships are understood.
6. Add capabilities last, as stable responsibilities under the model skeleton.

This should produce less atomic diagrams, better composed capabilities, and a model that survives changes in source-document organization.
