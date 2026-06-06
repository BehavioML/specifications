# WHIP Example

This WHIP example has been rebuilt from RFC/source behavior using the semantic top-down modeling process.

The previous WHIP BehavioML source model and generated Mermaid views were intentionally removed so the replacement model could be derived from RFC 9725 rather than refactored from the old model.

## Source material

- Local RFC source: [`sources/rfc9725.md`](sources/rfc9725.md)
- Traceability map: [`traceability/source-map.yaml`](traceability/source-map.yaml)
- Final remodel report: [`generated/reports/semantic-top-down-remodel-report.md`](generated/reports/semantic-top-down-remodel-report.md)
- Phase progress tracker: [`generated/reports/semantic-top-down-remodel-progress.md`](generated/reports/semantic-top-down-remodel-progress.md)

## Model structure

The rebuilt source model is under [`model/`](model/):

```text
model/
├── capabilities/whip/
├── decisions/
├── entities/
├── events/
├── roles/
├── semantic-areas/
├── state-machines/
└── workflows/
```

Semantic areas own workflows directly. Components, modules, interfaces, implementation guidance, payload schemas, and generated diagrams are intentionally absent from this rebuild stage.

## Semantic areas

- Session establishment
- Session resource lifecycle
- ICE candidate trickle
- ICE restart
- Authorization and rejection
- Redirect and overload handling

Standalone ICE server discovery and generic problem-response handling are not modeled as workflow-owning semantic areas. They are handled as setup-response/rejection capability refinement and traceability concerns.

## Intentional exclusions

This core behavioral model does not model:

- SDP grammar or JSEP internals
- ICE candidate or SDP fragment grammar
- HTTP route/header schemas or OpenAPI
- RFC 9457 problem-details schema
- STUN/TURN protocol behavior or TURN credential generation
- browser/WebRTC API calls
- media pipeline internals, codecs, RTP/RTCP packet behavior, SRTP details, or deployment topology
- implementation components/modules/interfaces

## Validation

From the repository root, run:

```bash
npm run validate:models
```

Generated Mermaid views remain removed until the rebuilt model is ready for regeneration.
