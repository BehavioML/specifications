# WHIP Semantic Top-Down Remodel Progress

## Current phase status

- Current phase: Phase 5 — Refine capabilities under workflow context.
- Status: Complete.
- Summary: Capabilities were refined under the existing Phase 4 workflow context. Ordered `uses` decomposition was added only for internal endpoint/session responsibilities, protocol payload grammar and implementation mechanics remained outside the core model, and two decisions captured the capability-refinement boundaries.
- Next phase safe to run: Yes, after human confirmation. Phase 6 may refine events, state machines, and decisions once the capability responsibilities and workflow context are stable.

## Commits made

- Phase 0: `d5e1c72` — `docs(whip): reset model for semantic top-down rebuild`
- Phase 1: `f4acc6d` — `docs(whip): survey RFC for semantic top-down model`
- Phase 2: `e1ac969` — `docs(whip): add semantic area skeleton`
- Phase 3: `85f7281` — `docs(whip): add semantic vocabulary skeleton`
- Phase 4: `f2758cd` — `docs(whip): add semantic area workflows`
- Phase 4 review: `01372d0` — `docs(whip): adjust semantic workflow granularity`
- Phase 5: current commit — `docs(whip): refine capabilities under workflow context`

## Files changed per phase

### Phase 0 — Reset WHIP BehavioML model

Removed:

- `examples/whip/model/`
- `examples/whip/generated/mermaid/`

Updated:

- `examples/whip/README.md`
- `examples/whip/generated/README.md`
- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

### Phase 1 — RFC-wide semantic survey

Added:

- `examples/whip/sources/rfc9725.md`

Updated:

- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

No BehavioML model files were created in Phase 1.

### Phase 2 — Create semantic-area skeleton

Added:

- `examples/whip/model/semantic-areas/session-establishment.yaml`
- `examples/whip/model/semantic-areas/session-resource-lifecycle.yaml`
- `examples/whip/model/semantic-areas/ice-candidate-trickle.yaml`
- `examples/whip/model/semantic-areas/ice-restart.yaml`
- `examples/whip/model/semantic-areas/authorization-and-rejection.yaml`
- `examples/whip/model/semantic-areas/redirect-and-overload-handling.yaml`
- `examples/whip/model/semantic-areas/ice-server-discovery.yaml`
- `examples/whip/model/semantic-areas/problem-response-handling.yaml`

Updated:

- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

No workflows, capabilities, roles, entities, events, state machines, components, modules, decisions, or traceability files were created in Phase 2.

Semantic areas intentionally have empty `workflows` lists because Phase 3 must first establish the participant and entity vocabulary, and Phase 4 is the designated phase for creating workflow files and assigning workflow ownership.

### Phase 3 — Add roles, entities, and lifecycle skeleton

Added roles:

- `examples/whip/model/roles/whip_client.yaml`
- `examples/whip/model/roles/whip_endpoint.yaml`
- `examples/whip/model/roles/media_server.yaml`

Added entities:

- `examples/whip/model/entities/whip_session.yaml`
- `examples/whip/model/entities/whip_session_resource.yaml`
- `examples/whip/model/entities/ice_session.yaml`
- `examples/whip/model/entities/remote_ice_candidate_set.yaml`
- `examples/whip/model/entities/authorization_token.yaml`
- `examples/whip/model/entities/problem_response.yaml`
- `examples/whip/model/entities/ice_server_configuration.yaml`

Added lifecycle skeletons:

- `examples/whip/model/state-machines/whip_session/lifecycle.yaml`
- `examples/whip/model/state-machines/whip_session_resource/lifecycle.yaml`

Updated:

- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

No workflows, capabilities, components, modules, events, decisions, or traceability files were created in Phase 3. The state machines intentionally define states only; transitions are deferred until Phase 6 when meaningful events are introduced.

### Phase 4 — Add workflows owned by semantic areas

Added workflows:

- `examples/whip/model/workflows/client/create_session.yaml`
- `examples/whip/model/workflows/endpoint/reject_invalid_offer.yaml`
- `examples/whip/model/workflows/client/terminate_session.yaml`
- `examples/whip/model/workflows/client/trickle_ice_candidates.yaml`
- `examples/whip/model/workflows/session/reject_invalid_ice_patch.yaml`
- `examples/whip/model/workflows/client/restart_ice.yaml`
- `examples/whip/model/workflows/session/reject_failed_ice_restart.yaml`
- `examples/whip/model/workflows/endpoint/reject_unauthorized_request.yaml`
- `examples/whip/model/workflows/client/follow_setup_redirect.yaml`
- `examples/whip/model/workflows/endpoint/defer_overloaded_setup.yaml`

Added minimal capability stubs:

- `examples/whip/model/capabilities/whip/*.yaml`

Updated semantic area ownership:

- `examples/whip/model/semantic-areas/*.yaml`

Updated:

- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

No components, modules, interfaces, events, decisions, state-machine transitions, or traceability files were created in Phase 4.

Workflow ownership is explicit and direct from semantic areas. Silent discard of unusable Trickle ICE candidates remains local RFC-defined processing covered by the Trickle ICE capability description and later traceability, not a workflow, event, state transition, branch, guard, algorithmic step, or failure state.

### Phase 4 review — Adjust semantic workflow granularity

Reviewed and adjusted before Phase 5:

- `examples/whip/model/workflows/client/create_session.yaml` now stays focused on the WHIP HTTP POST / 201 Created setup exchange. The `media_server` participant and `whip/establish_media_transport` step were removed from this workflow. Media-plane establishment remains a lifecycle boundary or later modeling decision, not a role interaction in the setup workflow.
- Removed `examples/whip/model/workflows/client/handle_problem_response.yaml` because generic failed-response handling is not a standalone behavior spine. Problem details and generic HTTP fallback should be represented by rejection workflow capabilities, later decisions, or traceability.
- Removed `examples/whip/model/workflows/client/receive_ice_server_configuration.yaml` because ICE server configuration is better refined under successful setup response capabilities in Phase 5 than modeled as a standalone workflow.
- Removed empty workflow-owning candidate semantic areas `examples/whip/model/semantic-areas/problem-response-handling.yaml` and `examples/whip/model/semantic-areas/ice-server-discovery.yaml`.
- Removed now-unreferenced capability stubs that only existed for the removed workflows or removed media transport setup step.

No events, state transitions, decisions, components, modules, interfaces, or traceability files were created during the review.

### Phase 5 — Refine capabilities under workflow context

Updated capabilities:

- Added ordered internal decomposition to setup, Trickle ICE, ICE restart, rejection, overload, and setup-response capabilities where the parent workflow-step context is sufficient.
- Kept role-to-role protocol interactions in workflows rather than hiding them inside `Capability.uses`.
- Kept SDP grammar, ICE candidate grammar, SDP fragment grammar, HTTP header schemas, RFC 9457 problem-details schema, token internals, STUN/TURN behavior, and implementation mechanics out of capability decomposition.
- Reintroduced ICE server configuration only as setup-response capability refinement, not as a standalone workflow or semantic area.
- Represented generic failed-response handling as `whip/return_failed_response` used by concrete rejection/defer capabilities, not as a standalone workflow.

Added capabilities:

- `examples/whip/model/capabilities/whip/validate_sdp_offer.yaml`
- `examples/whip/model/capabilities/whip/generate_sdp_answer.yaml`
- `examples/whip/model/capabilities/whip/include_session_resource_location.yaml`
- `examples/whip/model/capabilities/whip/include_ice_session_tag.yaml`
- `examples/whip/model/capabilities/whip/include_ice_server_configuration.yaml`
- `examples/whip/model/capabilities/whip/validate_trickle_ice_patch.yaml`
- `examples/whip/model/capabilities/whip/update_remote_ice_candidates.yaml`
- `examples/whip/model/capabilities/whip/validate_ice_restart.yaml`
- `examples/whip/model/capabilities/whip/replace_remote_ice_candidates.yaml`
- `examples/whip/model/capabilities/whip/preserve_existing_ice_session.yaml`
- `examples/whip/model/capabilities/whip/evaluate_request_authorization.yaml`
- `examples/whip/model/capabilities/whip/return_failed_response.yaml`

Added decisions:

- `examples/whip/model/decisions/keep_protocol_payloads_out_of_capabilities.yaml`
- `examples/whip/model/decisions/refine_auxiliary_response_metadata_under_setup.yaml`

Updated:

- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

No workflows, semantic areas, roles, entities, events, state-machine transitions, components, modules, interfaces, or traceability files were created or changed in Phase 5.

## Source material available

- Local RFC source artifact: `examples/whip/sources/rfc9725.md`.
- Source retrieval command: `curl -L --fail --show-error https://www.ietf.org/rfc/rfc9725.txt -o examples/whip/sources/rfc9725.md`.
- Retrieved source identity: RFC 9725, `WebRTC-HTTP Ingestion Protocol (WHIP)`, March 2025, Standards Track.
- The removed WHIP BehavioML model was not used as behavioral source material for this survey.

## RFC-wide semantic survey

### Major protocol participants and roles

- WHIP client: the WebRTC media encoder or producer that initiates session setup, sends WHIP HTTP requests, can trickle ICE or request ICE restarts, can terminate the session, and may consume ICE server configuration returned by the endpoint.
- WHIP endpoint: the ingest HTTP entry point that receives the initial POST, creates a WHIP session resource, answers the offer, can redirect setup requests, can advertise supported extensions and ICE server links, and may require authentication.
- WHIP session: the allocated HTTP resource identified by the Location header after successful setup; it receives PATCH and DELETE requests for the active ingest session.
- Media server: the WebRTC peer that establishes ICE/DTLS/SRTP media transport with the WHIP client and receives media. This is behaviorally important but may not need to be a separate role in every core WHIP workflow unless the workflow explicitly describes media-plane interaction.
- Authorization authority/token issuer: relevant only as an external source of bearer-token meaning or distribution; the RFC keeps token syntax, semantics, and distribution outside WHIP core behavior.
- STUN/TURN server or provider: relevant to configuration discovery and credential provisioning but not a core WHIP protocol actor for most workflows.

### Behaviorally coherent candidate semantic areas

These are behavior-first areas, not RFC-section buckets. Names may still be refined in Phase 2.

1. Session establishment
   - Covers client offer submission, endpoint offer validation, session resource creation, SDP answer return, initial Location/ETag handling, and invalid setup rejection.
   - Candidate workflows: `client/create_session`, `endpoint/reject_invalid_offer`, possibly `endpoint/reject_unsupported_webrtc_constraints` if the rejection is clearer as a distinct scenario.

2. Session resource lifecycle
   - Covers the allocated session resource as the target for ongoing session mutation and termination, including explicit DELETE termination and non-graceful termination boundaries.
   - Candidate workflows: `client/terminate_session`, possibly `session/expire_on_consent_failure` only if later phases decide consent expiry is observable enough for the core model.

3. ICE candidate trickle
   - Covers PATCH-based addition of ICE candidates, buffering until the session URL and relevant ETag are known, entity-tag/conditional request participation, successful no-content response, unsupported/malformed PATCH rejection, and silent discard of unusable candidates.
   - Candidate workflows: `client/trickle_ice_candidates`, `session/reject_invalid_ice_patch`, possibly `session/reject_unsupported_patch_operation`.

4. ICE restart
   - Covers PATCH-based ICE restart, new ICE credentials, If-Match usage, ETag replacement, remote-candidate replacement, out-of-order response handling, failed restart behavior, retry/termination options, and consent-expiry consequences.
   - Candidate workflows: `client/restart_ice`, `session/reject_failed_ice_restart`, possibly `client/recover_from_ice_mismatch` only if the RFC behavior can be kept sequence-diagrammable without encoding local algorithmic control flow.

5. Authorization and request rejection
   - Covers HTTP authentication support, bearer-token request authentication, missing/invalid credentials, URL-token alternative, and generic request rejection behavior.
   - Candidate workflows: `endpoint/reject_unauthorized_request`, `session/reject_unauthorized_request` if endpoint/session authorization behavior materially differs.

6. Redirect and overload handling
   - Covers setup redirection support, the prohibition on 301/302 for redirected POST, preference for 307 Temporary Redirect, absence of required PATCH/DELETE redirects, and 503 overload with optional Retry-After.
   - Candidate workflows: `client/follow_setup_redirect`, `endpoint/reject_or_defer_overloaded_setup` if overload response is modeled as a behaviorally meaningful endpoint scenario.

7. ICE server discovery
   - Covers return of STUN/TURN Link headers in a successful setup response, optional pre-POST OPTIONS-based discovery for constrained clients, CORS/preflight limitations, and externally supplied STUN/TURN configuration.
   - Candidate workflows: `client/receive_ice_server_configuration`, possibly `client/discover_ice_servers_before_offer` if Phase 2 keeps the non-recommended OPTIONS path as an explicit candidate area.

8. Problem response handling and generic HTTP fallback
   - Covers client handling of unknown status codes using generic n00 semantics and optional RFC 9457 problem details in failed responses.
   - Candidate workflows: likely not a standalone normal workflow unless paired with concrete rejection scenarios; may be better as capabilities/decisions attached to rejection workflows.

9. Extension discovery
   - Covers optional Link-based extension advertisement in the initial 201 response and client ignoring unknown extension rel values.
   - Candidate workflows: likely deferred or excluded from initial core workflows unless extension discovery is intentionally modeled as an observable optional behavior.

### Major entities and state owners

- WHIP session: lifecycle-bearing concept created by initial setup and terminated by DELETE, DTLS teardown, consent expiry, or failure paths.
- WHIP session resource / WHIP session URL: allocated HTTP resource returned in Location and used as target for PATCH and DELETE.
- ICE session: entity-tagged state associated with ICE credentials and candidate sets; changes on successful ICE restart.
- Remote ICE candidate set: behaviorally relevant because trickle adds candidates while ICE restart replaces the previous remote set.
- SDP offer/answer: behaviorally relevant as negotiation artifacts, but their grammar should not become core BehavioML payload structure.
- SDP fragment: behaviorally relevant as the PATCH payload carrier for ICE information, but its grammar should remain outside the core model.
- Authorization token: behaviorally relevant only as request authentication material; token syntax and distribution are outside scope.
- Problem response: behaviorally relevant as optional error detail; RFC 9457 schema should remain outside the core model.
- ICE server configuration: behaviorally relevant as discovered configuration returned via Link headers; STUN/TURN operation itself remains outside core WHIP behavior.

### Lifecycle candidates

- WHIP session lifecycle:
  - candidate states: not created, establishing, active, terminating, terminated, failed/expired.
  - important transitions: POST accepted, POST rejected, session resource allocated, DELETE received, media/consent teardown, failed ICE restart with eventual consent expiry.
- WHIP session resource lifecycle:
  - candidate states: absent, allocated, active target for PATCH/DELETE, removed, unknown/not found.
- ICE session lifecycle:
  - candidate states: initial, trickle-updated, restarting, restarted, stale/out-of-sync, failed/expired.
- Remote candidate set lifecycle:
  - candidate states: empty/initial, buffered locally, applied by trickle, replaced by restart.

### Observable protocol exchanges

- HTTP POST from WHIP client to WHIP endpoint with SDP offer.
- HTTP 201 Created from WHIP endpoint to WHIP client with SDP answer, Location, and possibly ETag, ICE server links, and extension links.
- HTTP 4xx rejection of malformed or unsupported setup request.
- HTTP PATCH from WHIP client to WHIP session URL for Trickle ICE.
- HTTP 204 No Content for successful Trickle ICE candidate addition.
- HTTP PATCH from WHIP client to WHIP session URL for ICE restart.
- HTTP 200 OK for successful ICE restart with new ICE information and ETag.
- HTTP 4xx rejection for malformed PATCH, unsupported PATCH operation, missing ETag, or non-matching ETag.
- HTTP DELETE from WHIP client to WHIP session URL.
- HTTP success response confirming explicit session termination.
- HTTP OPTIONS response for CORS and optional Accept-Post; optional STUN/TURN Link headers in constrained-client discovery.
- HTTP redirect response, especially 307 Temporary Redirect, during setup.
- HTTP 503 Service Unavailable with optional Retry-After during overload.
- ICE/STUN, DTLS, SRTP/RTP/RTCP media-plane exchanges are observable in the RFC overview but should be modeled only at lifecycle/behavior boundary level unless needed for a specific semantic workflow.

### Major failure and rejection behaviors

- POST content type is not `application/sdp`.
- POST SDP is malformed.
- SDP offer violates WHIP constraints such as unsupported media stream/track shape, unacceptable setup role, unsupported partial-success handling, or invalid direction constraints.
- PATCH content type is not `application/trickle-ice-sdpfrag`.
- PATCH SDP fragment is malformed.
- PATCH operation is unsupported by the session, including support for Trickle ICE but not ICE restart or vice versa.
- PATCH lacks a required entity-tag or supplies a non-matching entity-tag.
- ICE restart cannot be satisfied; the existing session is not immediately terminated, but consent expiry can terminate it later.
- Unsupported candidate transport or unresolvable candidate address during Trickle ICE is silently discarded while processing continues.
- Unauthorized or unauthenticated requests to endpoints or sessions.
- Unknown status codes and error codes must be handled by clients using generic status-code semantics.
- Setup request may be redirected or rejected/deferred under overload.

### Behavior that should remain outside core BehavioML

- SDP grammar and full JSEP processing details.
- ICE candidate and SDP fragment grammar.
- HTTP header schemas, OpenAPI, route definitions, status-code taxonomies, and RFC 9457 problem-details schema.
- STUN/TURN protocol behavior and external TURN-provider credential generation internals.
- Browser/WebRTC API calls such as `setConfiguration` or `setLocalDescription`.
- Media pipeline internals, codecs, RTP/RTCP packet behavior, SRTP details, congestion-control algorithms, deployment topology, load-balancer implementation, rate-limit implementation, token syntax/distribution, JWT/database structure, IANA registration mechanics, and extension-specific behavior not defined by RFC 9725.

### Likely traceability anchors

Use RFC/source sections as evidence anchors only, not as model decomposition units:

- RFC 9725 §3 Overview: participants, core setup/teardown, media-plane boundary.
- RFC 9725 §4.1 HTTP Usage: generic error handling, problem details, GET/OPTIONS behavior boundary.
- RFC 9725 §4.2 Ingest Session Setup: POST setup, 201 response, Location, invalid setup rejection, DELETE termination, CORS OPTIONS.
- RFC 9725 §4.3.1 HTTP PATCH Request Usage: PATCH payload media type, entity-tags, conditional request failures, unsupported PATCH operation rejection.
- RFC 9725 §4.3.2 Trickle ICE: candidate buffering, server candidate completeness, 204 response, silent candidate discard.
- RFC 9725 §4.3.3 ICE Restarts: ICE restart PATCH, new credentials, 200 response, ETag replacement, candidate-set replacement, failed restart behavior, out-of-order handling.
- RFC 9725 §4.4 WebRTC Constraints: behaviorally relevant rejection boundaries for SDP/WebRTC constraints.
- RFC 9725 §4.5 Load Balancing and Redirections: 307 redirect behavior, PATCH/DELETE redirect boundary, 503 Retry-After behavior.
- RFC 9725 §4.6 STUN/TURN Server Configuration: Link-based ICE server configuration and OPTIONS caveats.
- RFC 9725 §4.7 Authentication and Authorization: HTTP authentication and bearer-token behavior.
- RFC 9725 §4.8 Simulcast and Scalable Video Coding: likely exclusion or minimal setup-validation anchor.
- RFC 9725 §4.9 Protocol Extensions: optional extension advertisement and unknown-extension handling.
- RFC 9725 §5 Security Considerations: rate limiting, resource exhaustion, hard-to-guess session URLs, and implementation/security boundaries.

## Proposed modeling order

1. Phase 2: complete. Created semantic-area skeletons for session establishment, session resource lifecycle, ICE candidate trickle, ICE restart, authorization and rejection, redirect and overload handling, ICE server discovery, and problem response handling. Extension discovery and non-recommended OPTIONS-based ICE server discovery are intentionally not modeled in this core rebuild.
2. Phase 3: complete. Added high-level vocabulary required before workflows: WHIP client, WHIP endpoint, and media server roles; WHIP session/resource, ICE session, remote candidate set, authorization token, problem response, and ICE server configuration entities; and state-only lifecycle skeletons for WHIP session and WHIP session resource.
3. Phase 4: complete and reviewed. Added sequence-diagrammable workflows owned by semantic areas, then removed standalone problem-response and ICE-server-configuration workflows and narrowed setup to the WHIP HTTP exchange before Phase 5.
4. Phase 5: complete. Refined capabilities under workflow context with ordered internal decomposition, added capability-boundary decisions, and kept protocol grammar, schemas, and implementation mechanics out of the model.
5. Phase 6: refine events, state machines, and decisions once workflows and responsibilities show which occurrences and lifecycle constraints are meaningful.
6. Phase 7: add traceability and final documentation after the semantic model exists.

## Open questions

Resolved for Phase 2 based on human feedback:

- `WHIP session` should be treated as a distinct entity from `WHIP endpoint` in later vocabulary phases.
- `Media server` should be treated as a distinct role where workflows need to represent media-plane participation or lifecycle boundaries.
- Non-recommended OPTIONS-based ICE server discovery should not be modeled in the core rebuild.
- Extension discovery should not be modeled in the core rebuild.

Resolved for Phase 3 based on human feedback:

- Silent discard of unusable Trickle ICE candidates is RFC-defined local processing behavior inside the Trickle ICE semantic area. It must not become a separate workflow, event, state transition, branch, guard, algorithmic step, or failure state. It may be covered later by RFC/source traceability, relevant Trickle ICE processing capability description, or audit/test notes.

## Validation status

- `curl -L --fail --show-error https://www.ietf.org/rfc/rfc9725.txt -o examples/whip/sources/rfc9725.md`: Passed.
- `wc -l examples/whip/sources/rfc9725.md`: Passed; fetched source has 1438 lines.
- `git status --short`: Run after Phase 5 changes.
- `find examples/whip -maxdepth 5 -type f | sort`: Run after Phase 5 changes.
- `npm run validate:models`: Passed for Phase 5. Expected coverage notes remain because triggers, events, transitions, and capability event associations are intentionally deferred: 10 workflows without explicit trigger, 33 capabilities without events, 5 entities without state machine, 2 state machines without transitions, and 12 unused states.

## Phase gate

- Stopped after Phase 5.
- Do not proceed to Phase 6 until a human explicitly confirms continuation.
