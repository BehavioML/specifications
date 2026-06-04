# WHIP Example

This exploratory BehavioML example models WHIP, the WebRTC-HTTP Ingestion Protocol, at a behavioral level.

WHIP lets a client publish WebRTC media into an ingestion endpoint using HTTP-created resources. A client posts an SDP offer to a WHIP endpoint, the endpoint creates a WHIP resource and returns an SDP answer, and the client later uses that resource for PATCH updates such as trickle ICE or ICE restart and for DELETE termination.

The purpose of this example is not to teach the complete RFC or define an implementation contract. The purpose is to stress-test BehavioML against a protocol where HTTP exchanges create and mutate lifecycle-bearing resources while WebRTC negotiation behavior remains relevant.

## Why WHIP is included

WHIP complements the existing OAuth Authorization Code and QUIC examples by exercising a different modeling shape:

- OAuth stresses redirects/callbacks/auth semantics.
- QUIC stresses lifecycle and transport state.
- WHIP stresses HTTP-created resources, PATCH updates, ICE trickle/restart, and media-ingest session lifecycle.

This makes WHIP useful for checking that BehavioML can keep externally observable protocol interactions visible while still representing endpoint-side validation, allocation, persistence, and response preparation as ordered internal decomposition.

## What this example models

The model covers these behaviorally meaningful WHIP concerns:

1. Session/resource creation with HTTP POST.
2. SDP offer/answer exchange at a behavioral level.
3. WHIP resource creation and Location-based follow-up requests.
4. Trickle ICE with HTTP PATCH.
5. ICE restart with HTTP PATCH.
6. ICE restart remote-candidate replacement semantics.
7. Session/resource termination with HTTP DELETE.
8. Bearer-token authorization and authorization failures.
9. HTTP 307 Temporary Redirect handling with explicit client follow-up.
10. ICE server discovery via `Link: rel=ice-server`.
11. Error/problem response behavior.
12. Unsupported or invalid request rejection.
13. Basic WHIP session and resource lifecycle state.

## What this example intentionally does not model

This example intentionally excludes:

- full SDP grammar
- full ICE candidate grammar
- full HTTP header schema
- full RFC 9457 problem details schema
- media pipeline internals
- STUN/TURN behavior
- browser-specific WebRTC APIs
- deployment topology
- OpenAPI or other HTTP contract documentation
- implementation guidance

Payload-level contracts and implementation-specific details belong outside this core behavioral model. Capabilities such as `validate_sdp_offer`, `validate_ice_candidate_fragment`, `include_location_header`, and `return_problem_response` name the behavioral responsibility without expanding the underlying wire-format schema.

## Roles

The model uses two functional protocol roles:

- `whip_client` — sends WHIP HTTP requests and stores ICE server discovery metadata.
- `whip_endpoint` — owns the WHIP HTTP protocol surface for session creation, resource updates, redirects, errors, and termination.

Bearer-token validation and media allocation are modeled as capabilities and interfaces rather than extra roles because they do not materially participate as separate scenario actors in these workflows.

## Model structure

The source-of-truth model is under `model/`:

```text
model/
├── capabilities/whip/
├── components/
├── decisions/
├── entities/
├── events/
├── interfaces/
├── modules/
├── roles/
├── state-machines/
└── workflows/
```

Key behavioral workflows are grouped by primary role:

- `workflows/client/create_session.yaml`
- `workflows/client/follow_redirect.yaml`
- `workflows/client/trickle_ice_candidate.yaml`
- `workflows/client/restart_ice.yaml`
- `workflows/client/terminate_session.yaml`
- `workflows/client/discover_ice_servers.yaml`
- `workflows/endpoint/reject_unauthorized_request.yaml`
- `workflows/endpoint/reject_invalid_offer.yaml`
- `workflows/endpoint/reject_unknown_resource.yaml`

## Workflow modeling notes

All observable WHIP HTTP requests and responses are represented as `Workflow.steps` with explicit `from` and `to` role context. That keeps the scenario spine sequence-diagrammable and prevents role interactions from being hidden inside internal decomposition.

Internal endpoint work is represented with ordered `Capability.uses`. Examples include bearer-token extraction and validation, SDP offer validation, ingest session allocation, WHIP resource creation, SDP answer generation, resource Location validation, remote candidate application, ICE restart application, and resource deletion.

The HTTP 307 redirect workflow makes the follow-up request explicit. The model uses the same `whip_endpoint` role for both the original and redirected endpoints because this example does not distinguish concrete endpoint instances.

The ICE restart workflow explicitly includes `replace_remote_ice_candidates` and the `remote_ice_candidates_replaced` event. This models the semantic rule that an ICE restart replaces the previous remote candidate set rather than simply appending to it.

The ICE server discovery workflow is separate from session creation so the client responsibility to store `Link: rel=ice-server` metadata is visible. The creation workflow still shows that the endpoint includes ICE server links while preparing the creation response.

## State-machine summary

The model includes lifecycle state machines for:

- `whip_session/lifecycle` — tracks `new`, `creating`, `active`, `ice_restarting`, `terminating`, `terminated`, and `failed` session states.
- `whip_resource/lifecycle` — tracks the endpoint-created WHIP resource from absence through creation, active use, deletion, and failure/unknown-resource outcomes.

Successful POST offer processing creates the WHIP resource and establishes the session. DELETE drives the session toward termination. ICE restart temporarily moves the session from `active` to `ice_restarting` and back to `active`. Failed creation is represented by `session_creation_failed` transitions.

## Decisions

Important modeling decisions are captured under `model/decisions/`:

- `model_http_exchanges_as_workflow_steps.yaml` explains why WHIP HTTP requests and responses are workflow-visible role interactions.
- `keep_protocol_payloads_out_of_core_model.yaml` explains why SDP, ICE candidate, HTTP header, and problem-details schemas are not expanded in the core model.
- `model_ice_restart_candidate_replacement.yaml` explains why ICE restart remote-candidate replacement is explicit behavior.
- `model_redirect_followup_explicitly.yaml` explains why 307 follow-up is not inferred by generators.

## Generated diagrams

Generated Mermaid diagrams are available under:

```text
generated/mermaid/
```

Generated sequence diagrams show WHIP HTTP exchanges and selected local behavior. Generated state-machine diagrams show WHIP session/resource lifecycle. They are documentation views derived from the BehavioML model.

Primary documentation views:

- [`generated/mermaid/state-machines.mmd`](generated/mermaid/state-machines.mmd)
- [`generated/mermaid/workflow-sequence-client-create_session.mmd`](generated/mermaid/workflow-sequence-client-create_session.mmd)
- [`generated/mermaid/workflow-sequence-client-follow_redirect.mmd`](generated/mermaid/workflow-sequence-client-follow_redirect.mmd)
- [`generated/mermaid/workflow-sequence-client-trickle_ice_candidate.mmd`](generated/mermaid/workflow-sequence-client-trickle_ice_candidate.mmd)
- [`generated/mermaid/workflow-sequence-client-restart_ice.mmd`](generated/mermaid/workflow-sequence-client-restart_ice.mmd)
- [`generated/mermaid/workflow-sequence-client-terminate_session.mmd`](generated/mermaid/workflow-sequence-client-terminate_session.mmd)
- [`generated/mermaid/workflow-sequence-client-discover_ice_servers.mmd`](generated/mermaid/workflow-sequence-client-discover_ice_servers.mmd)
- [`generated/mermaid/workflow-sequence-endpoint-reject_unauthorized_request.mmd`](generated/mermaid/workflow-sequence-endpoint-reject_unauthorized_request.mmd)
- [`generated/mermaid/workflow-sequence-endpoint-reject_invalid_offer.mmd`](generated/mermaid/workflow-sequence-endpoint-reject_invalid_offer.mmd)
- [`generated/mermaid/workflow-sequence-endpoint-reject_unknown_resource.mmd`](generated/mermaid/workflow-sequence-endpoint-reject_unknown_resource.mmd)

Secondary inspection views:

- [`generated/mermaid/entity-state-machines.mmd`](generated/mermaid/entity-state-machines.mmd)
- [`generated/mermaid/workflow-capabilities.mmd`](generated/mermaid/workflow-capabilities.mmd)
- [`generated/mermaid/capability-events.mmd`](generated/mermaid/capability-events.mmd)

These files are derived artifacts and should be regenerated with `@behavioml/generator` after model changes.

## Relation to RFC diagrams

Generated sequence diagrams should resemble WHIP RFC flows at the HTTP-exchange level, but they are not intended to reproduce every RFC detail or replace OpenAPI/HTTP contract documentation.

The diagrams focus on observable WHIP role interactions and selected local behavior from the model. They intentionally omit payload grammar, full header contracts, STUN/TURN behavior, browser API details, and deployment topology.

## How to validate

From the repository root, run:

```bash
npm run validate:models
```

The validation script checks the QUIC, OAuth Authorization Code, and WHIP models.
