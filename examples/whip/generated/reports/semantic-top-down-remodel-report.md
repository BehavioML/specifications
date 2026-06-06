# WHIP Semantic Top-Down Remodel Report

## Source inputs inspected

- `examples/whip/sources/rfc9725.md` — local copy of RFC 9725 fetched from the IETF RFC text endpoint.
- Project modeling rules and process guidance:
  - `README.md`
  - `docs/model-rules.md`
  - `docs/semantic-top-down-modeling.md`
  - `docs/design-notes/0010-afterthought-semantic-first-rfc-modeling.md`
  - `docs/design-notes/0011-semantic-areas-and-progressive-modeling.md`
  - `docs/design-notes/0005-sequence-diagrammable-workflows.md`
  - `docs/design-notes/0006-behavioml-and-uml-boundary.md`
  - `docs/design-notes/0007-implementation-guidance-boundary.md`
  - `docs/design-notes/0008-lessons-from-whip.md`

The previous WHIP BehavioML model was used only to know what old files existed and what had to be removed. It was not used as the behavioral source for the new model.

## Semantic areas introduced

- `session-establishment`
- `session-resource-lifecycle`
- `ice-candidate-trickle`
- `ice-restart`
- `authorization-and-rejection`
- `redirect-and-overload-handling`

Candidate areas for standalone ICE server discovery and problem-response handling were removed during Phase 4 review because they did not own independent workflow spines in the core model.

## Workflows owned by each semantic area

### Session establishment

- `client/create_session`
- `endpoint/reject_invalid_offer`

### Session resource lifecycle

- `client/terminate_session`

### ICE candidate trickle

- `client/trickle_ice_candidates`
- `session/reject_invalid_ice_patch`

### ICE restart

- `client/restart_ice`
- `session/reject_failed_ice_restart`

### Authorization and rejection

- `endpoint/reject_unauthorized_request`

### Redirect and overload handling

- `client/follow_setup_redirect`
- `endpoint/defer_overloaded_setup`

## Roles, entities, and state machines created

### Roles

- `whip_client`
- `whip_endpoint`
- `media_server`

### Entities

- `whip_session`
- `whip_session_resource`
- `ice_session`
- `remote_ice_candidate_set`
- `authorization_token`
- `problem_response`
- `ice_server_configuration`

### State machines

- `whip_session/lifecycle`
- `whip_session_resource/lifecycle`

The state machines own lifecycle transitions. Workflows do not encode lifecycle state-control logic.

## Capabilities created and refined

Capabilities were refined under workflow context rather than by RFC paragraph. Important responsibility groups include:

- Setup request and response: `send_sdp_offer`, `accept_sdp_offer`, `validate_sdp_offer`, `generate_sdp_answer`, `create_session_resource`, `return_session_created`, `include_session_resource_location`, `include_ice_session_tag`, `include_ice_server_configuration`.
- Termination: `send_delete_request`, `remove_session_resource`, `release_media_session`, `return_session_terminated`.
- Trickle ICE: `send_trickle_ice_patch`, `apply_trickle_ice_update`, `validate_trickle_ice_patch`, `update_remote_ice_candidates`, `return_trickle_ice_accepted`, `reject_invalid_ice_patch`.
- ICE restart: `send_ice_restart_patch`, `apply_ice_restart`, `validate_ice_restart`, `replace_remote_ice_candidates`, `return_ice_restart_answer`, `reject_ice_restart`, `preserve_existing_ice_session`.
- Authorization, rejection, redirect, and overload: `evaluate_request_authorization`, `reject_unauthorized_request`, `return_failed_response`, `return_setup_redirect`, `follow_setup_redirect`, `defer_overloaded_setup`.

## Events and decisions created/refined

### Events

Events represent meaningful occurrences that happened in the modeled system, such as:

- `session_setup_requested`
- `session_resource_created`
- `session_established`
- `session_setup_rejected`
- `session_termination_requested`
- `session_terminated`
- `session_consent_expired`
- `remote_ice_candidates_updated`
- `ice_patch_rejected`
- `ice_restart_requested`
- `remote_ice_candidates_replaced`
- `ice_restart_applied`
- `ice_restart_rejected`
- `request_authorization_rejected`
- `setup_redirect_returned`
- `setup_overload_deferred`

Events are not status-code aliases, branch labels, helper completions, or payload names.

### Decisions

- `keep_protocol_payloads_out_of_capabilities`
- `refine_auxiliary_response_metadata_under_setup`
- `model_events_as_observable_occurrences`
- `keep_lifecycle_transitions_in_state_machines`

## What is intentionally not modeled

- SDP grammar and full JSEP processing.
- ICE candidate and SDP fragment grammar.
- HTTP route schemas, header schemas, OpenAPI, or status-code taxonomy.
- RFC 9457 problem-details schema.
- STUN/TURN protocol behavior and TURN credential-generation internals.
- Browser-specific WebRTC APIs such as `setConfiguration` and `setLocalDescription`.
- Media pipeline internals, codecs, RTP/RTCP packet behavior, SRTP details, congestion-control algorithms, and deployment topology.
- Implementation components, modules, interfaces, storage schemas, or framework details.
- Standalone workflows for generic failed-response handling or ICE server discovery.
- A separate workflow, event, state transition, branch, guard, algorithmic step, or failure state for silent discard of unusable Trickle ICE candidates.

## How this differs from the previous WHIP BML approach

- The old WHIP model was removed before rebuilding.
- The new model starts with semantic areas and RFC-wide survey findings rather than source-section decomposition.
- Semantic areas own workflows directly and do not reference components.
- Components, modules, and interfaces are absent until a later phase needs implementation anchors.
- Workflows focus on sequence-diagrammable role interactions and meaningful behavior spines.
- Capabilities were refined only after workflow context existed.
- Events and lifecycle transitions were added after workflows and capabilities clarified observable occurrences.
- Traceability is external and maps RFC evidence to model elements rather than making RFC sections model decomposition units.

## Remaining gaps

- No implementation components/modules/interfaces have been introduced.
- No generated Mermaid views have been regenerated after the rebuild.
- Some workflows remain root scenarios without explicit triggers, which is expected for this modeling stage.
- Some capabilities intentionally have no events because they are internal responsibilities rather than observable occurrences.
- Supporting entities such as authorization token, problem response, ICE server configuration, ICE session, and remote ICE candidate set do not yet own dedicated state machines.

## Validator/generator follow-up issues

- `npm run validate:models` passes.
- The validator reports expected coverage notes for root workflows, intentionally eventless capabilities, and supporting entities without state machines.
- Mermaid generation was not run in this phase. Generated Mermaid artifacts were removed with the old model and should be regenerated only after the rebuild is accepted.

## Commands run

- `curl -L --fail --show-error https://www.ietf.org/rfc/rfc9725.txt -o examples/whip/sources/rfc9725.md`
- `wc -l examples/whip/sources/rfc9725.md`
- `git status --short`
- `find examples/whip -maxdepth 5 -type f | sort`
- `npm run validate:models`
- `git diff --check`

## Failures or uncertainties

- No command failures remain.
- The remaining validation coverage notes are expected for the current modeling stage.
- RFC/source traceability uses section/line anchors into the local RFC artifact and should be deepened if future reviews require more granular source evidence.
