# Behavio Manifest

`behavio.yaml` is a repository or documentation-workspace manifest for BehavioML-based spec-driven development.

It is not part of the BehavioML model and does not define behavior.

The BehavioML model remains the source of truth for workflows, roles, capabilities, interfaces, components, modules, events, entities, state machines, decisions, semantic areas, and aggregated workflows.

## Location

A behavior workspace entry point is normally located at:

```text
docs/behavioml/behavio.yaml
```

Nested manifests may be placed under module or domain directories:

```text
docs/behavioml/quic/behavio.yaml
docs/behavioml/moqt/behavio.yaml
```

All relative paths are resolved from the directory containing the manifest that declares them.

## Model manifest

A model manifest points to the authored layers of a single spec-driven development pipeline.

```yaml
id: quic
description: QUIC behavior model for Quiver.

paths:
  specs: specs
  model: model
  design: design
  implementation: implementation
```

### Paths

| Path | Purpose |
| --- | --- |
| `specs` | Source specifications such as RFCs, SDDs, product specs, architecture guidelines, and source notes. |
| `model` | BehavioML behavior model root. |
| `design` | Software design artifacts derived from the behavior model. |
| `implementation` | Implementation guidance, codegen profiles, technical contracts, and agent instructions. |

The manifest should not list generated artifacts, review views, diagrams, reports, or transient outputs.

## Aggregate manifest

An aggregate manifest points to other manifests.

```yaml
id: quiver
description: Quiver behavior workspace.

include:
  quic: quic/behavio.yaml
  moqt: moqt/behavio.yaml
```

`include` is a map from manifest id to manifest path.

A manifest should define either `paths` or `include`, not both.

## Boundaries

A `behavio.yaml` manifest:

- locates specs, model, design, and implementation layers
- may aggregate nested manifests
- does not define behavior
- does not duplicate BehavioML model content
- does not contain validator or generator commands
- does not list generated artifacts

Tools may use the manifest to discover the model root, but model semantics remain owned by the files under `paths.model`.
