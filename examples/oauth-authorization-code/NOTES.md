# OAuth Authorization Code Flow Modeling Notes

This example is exploratory and intentionally limited. It tests whether current BehavioML concepts can describe a security/business protocol flow without introducing OAuth-specific schema.

## User agent as a role

The user agent is modeled as a role because browser mediation is behaviorally relevant. Redirects are central to the authorization code flow, even though the user agent is not an OAuth endpoint in the same way as the client, authorization server, or resource server.

This seems to fit the current `roles.primary` and `roles.participants` model without requiring a new participant type.

## Workflows without explicit trigger

`client/start_authorization.yaml` is intentionally a root behavior without `triggered_by`. It represents an externally initiated user or application action rather than an event emitted by another model element.

Other workflows use `triggered_by` when a clear event exists, such as `authorization_requested`, `consent_granted`, `authorization_code_received_by_client`, `token_request_received`, `protected_resource_requested`, `redirect_uri_rejected`, and `access_token_rejected`.

Open question: should BehavioML eventually distinguish externally initiated root workflows, or is optional `triggered_by` sufficient?

## Consent as both entity and event

Consent is modeled as:

- `entities/consent_grant.yaml` for persisted authorization state
- `events/consent_granted.yaml` and `events/consent_denied.yaml` for observable behavioral outcomes

This separation works well with the current rules: entities own state, events drive behavior, and workflows avoid inline branches.

Open question: should future examples add a consent lifecycle state machine, or is that unnecessary for this model scope?

## Authorization code lifecycle

`state-machines/authorization_code/lifecycle.yaml` owns the authorization code transitions:

- `requested` to `issued` on `authorization_code_issued`
- `issued` to `redeemed` on `authorization_code_validated`
- `requested` or `issued` to `rejected` on `authorization_code_rejected`

The `expired` state is included as a behaviorally relevant lifecycle state, but this example does not add a timeout event because expiration is not one of the required scenarios. That leaves room for a future targeted timeout scenario without making this model a full RFC implementation.

## Are current BehavioML concepts enough?

For this scope, the current concepts appear sufficient:

- workflows represent nominal and failure scenarios
- capabilities represent responsibilities
- events connect capabilities, workflows, and state machines
- roles capture functional participants
- components and modules provide implementation boundaries without owning behavior
- decisions capture modeling rationale

Metamodel questions discovered:

1. Whether root workflows should get an explicit concept or remain workflows without `triggered_by`.
2. Whether a state listed but not transitioned to should be flagged as a coverage finding or accepted as known future behavior.
3. Whether duplicate event declarations from client-side and server-side capabilities should be treated as intentional shared observability or as a possible ambiguity.
4. Whether consent deserves a first-class lifecycle in larger examples.

## Implementation-readiness scope clarifications

The model now distinguishes server-side authorization-code issuance from client-observed callback delivery. `authorization_code_issued` remains the authorization server's code-production outcome, while `authorization_code_received_by_client` is emitted by the user-agent callback delivery capability and triggers `workflows/client/exchange_code_for_tokens.yaml`. This keeps the explicit `user_agent` to `client` workflow step as source-of-truth behavior instead of letting a generator infer the callback.

Invalid authorization request behavior is modeled as a safe failure path. `oauth/validate_redirect_uri` can emit `redirect_uri_rejected`, which triggers `workflows/authorization_server/reject_invalid_authorization_request.yaml`. That workflow returns a local/user-agent-facing rejection and deliberately does not redirect to an unvalidated URI. It stays at the behavioral level and does not model HTTP status codes or OAuth error payload schemas.

Protected-resource denial is also modeled as a focused failure path. `oauth/validate_access_token` can emit `access_token_rejected`, which triggers `workflows/resource_server/deny_protected_resource.yaml`; the resource server then returns an observable denial instead of a protected resource. The model does not enumerate OAuth error codes.

Resource-owner authentication failure is explicitly out of scope for this example. `oauth/authenticate_resource_owner` models only successful authentication or identification sufficient to continue to consent. Adding login failure, retry, account recovery, or user-interface behavior would make this example less focused on the authorization-code scaffold.

Refresh-token issuance is optional by authorization-server policy and represented only as an optional artifact during token response production. The example does not model refresh-token grant, rotation, revocation, expiration, or lifecycle behavior.

## Modeling feedback for review

### Awkward or forced areas

Most of the core authorization code flow mapped cleanly to the current concepts, but two areas felt mildly forced:

- `workflows/client/start_authorization.yaml` has no `triggered_by` because the initiating action is external to the modeled system. Omitting `triggered_by` is valid, but it makes root behavior implicit rather than explicit.
- `state-machines/authorization_code/lifecycle.yaml` includes `expired` as a meaningful lifecycle state, but this scoped example intentionally does not add a timeout event or expiration workflow. The state is useful for the protocol concept but appears incomplete to coverage-style checks.

### Ambiguity around model concepts

The strongest ambiguity was the boundary between Capability and Event:

- `capabilities/oauth/obtain_consent.yaml` represents a responsibility, while `events/consent_granted.yaml` and `events/consent_denied.yaml` represent outcomes of that responsibility.
- `capabilities/oauth/validate_authorization_code.yaml` similarly has both success and failure events: `authorization_code_validated` and `authorization_code_rejected`.

That split worked, but it raised a question about whether capability outcomes should remain ordinary events or eventually receive a more explicit outcome vocabulary.

Entity and StateMachine boundaries were clearer. `entities/authorization_code.yaml` owns the stateful artifact, while `state-machines/authorization_code/lifecycle.yaml` owns transitions. Role and Decision also felt clear for this example.

### User agent as a role

Modeling `user_agent` as a role worked naturally for the workflow level. Redirect mediation appears in workflows such as:

- `workflows/client/start_authorization.yaml`
- `workflows/authorization_server/handle_authorization_request.yaml`
- `workflows/authorization_server/issue_authorization_code.yaml`
- `workflows/authorization_server/deny_authorization.yaml`

The separate `components/user_agent.yaml` still provides an implementation boundary for browser-runtime mediation. This suggests the Role/Component split is useful: the role captures participation; the component captures implementation.

I would not introduce a special OAuth browser concept for this example. If the metamodel changes, a more general participant classification may be more useful than a user-agent-specific construct.

### Consent modeling

Consent worked best as a combination:

- an entity: `entities/consent_grant.yaml`
- events: `events/consent_granted.yaml` and `events/consent_denied.yaml`
- a capability outcome from `capabilities/oauth/obtain_consent.yaml`

Using only an event would lose the persisted grant concept. Using only an entity would make the grant/deny behavioral split less visible. Using only a capability would hide the fact that downstream workflows are triggered by consent outcomes.

### `triggered_by` narrowness

`triggered_by` was useful when a workflow clearly follows an observable event:

- `authorization_requested` triggers authorization request handling.
- `consent_granted` triggers authorization code issuing.
- `authorization_code_received_by_client` triggers client token exchange, keeping it separate from server-side `authorization_code_issued`.
- `token_request_received` triggers token request handling.
- `protected_resource_requested` triggers protected resource serving.
- `redirect_uri_rejected` triggers safe authorization request rejection.
- `access_token_rejected` triggers protected resource denial.

It felt too narrow only for externally initiated behavior. `workflows/client/start_authorization.yaml` is a root/user-initiated workflow, but the current model has no way to say that without adding a new schema concept. For now, omitting `triggered_by` is the right fit.

### Inline branching deliberately avoided

There were two places where inline branching would have been tempting but was intentionally avoided:

- Consent grant versus denial after `capabilities/oauth/obtain_consent.yaml`.
- Valid authorization code versus invalid authorization code after `capabilities/oauth/validate_authorization_code.yaml`.
- Accepted versus rejected redirect URI behavior after `capabilities/oauth/validate_redirect_uri.yaml`.
- Accepted versus rejected access token behavior after `capabilities/oauth/validate_access_token.yaml`.

Separate workflows were clearer and stayed aligned with BehavioML's scenario-oriented workflow rules:

- `workflows/authorization_server/issue_authorization_code.yaml`
- `workflows/authorization_server/deny_authorization.yaml`
- `workflows/authorization_server/handle_token_request.yaml`
- `workflows/authorization_server/reject_invalid_code.yaml`
- `workflows/authorization_server/reject_invalid_authorization_request.yaml`
- `workflows/resource_server/deny_protected_resource.yaml`

This supports the current guidance that workflows should not become executable branch graphs.

### Sequence-diagrammable workflow steps

Converting the OAuth workflows from legacy string steps to object steps made the intended sequence-diagram shape much more explicit. A step with `from` and `to` worked naturally for redirects, incoming requests, callbacks, token exchanges, resource calls, and resource responses because those steps cross role boundaries. A step with only `from` worked well for local preparation, validation, issuance, and rejection responsibilities where the behavior belongs to one role even if the broader scenario involves other participants.

The separate `label` field was useful. Capability references such as `oauth/receive_authorization_request` and `oauth/redirect_with_authorization_code` remain stable model responsibilities, while labels such as `Authorization request` or `Redirect with authorization code` can present the step in the language of this workflow. This should reduce generator guesswork because the model now says which role performs the step and whether another role is directly involved, instead of requiring a generator to infer messages from capability names.

The follow-up modeling pass tightened the boundary between observable scenario steps and internal decomposition. Browser-mediated callbacks are now explicit rather than inferred: after the authorization server redirects through the user agent, the user agent has its own `oauth/deliver_authorization_callback` step back to the client for both authorization-code and denied outcomes. The successful code callback emits `authorization_code_received_by_client`, so client token exchange is tied to what the client observes rather than directly to server-side `authorization_code_issued`. This keeps the sequence diagram honest without asking a generator to invent the browser's follow-up request.

Token response delivery is also distinct from local token production. `oauth/return_token_response` is the observable authorization-server-to-client response step, while `oauth/validate_authorization_code`, `oauth/issue_access_token`, and `oauth/issue_refresh_token` are internal decomposition under that capability's `uses`. This makes `Workflow.steps` read as the ordered observable scenario spine rather than a list of every validation, persistence, or issuance responsibility.

Some local steps remain intentionally visible when they are useful in the human-facing sequence diagram. For example, redirect URI validation and authorization-code issuance still communicate important protocol responsibilities. Rejected redirect URI behavior is modeled as a separate safe rejection workflow rather than as an inline branch or an unsafe redirect callback. `oauth/validate_access_token` also stays local to the resource server because token introspection is not modeled explicitly, and rejected access-token behavior is represented by a separate protected-resource denial workflow. The useful rule of thumb from this pass is: keep local steps when they clarify the scenario, but move details to `Capability.uses` when the sequence remains understandable without rendering them directly.

### Validator coverage observations

The validator coverage output was useful but somewhat noisy:

- `requested` has no inbound transition because it is effectively the initial authorization-code state.
- `expired` has no inbound transition because expiration is acknowledged as protocol-relevant but intentionally out of scope for this minimal example.

The finding is still valuable because it forces the model author to explain whether the missing transition is intentional, but initial states and deferred-scope states may need a cleaner representation.

### One proposed metamodel change

If proposing one change after building this example, I would add an explicit but minimal way to identify workflow initiation semantics without turning workflows into programs.

For example, BehavioML could eventually distinguish:

- externally initiated/root workflows
- event-triggered workflows

The current optional `triggered_by` field is workable, so this is not urgent. But OAuth made the absence of explicit root workflow semantics more visible than the QUIC lifecycle example did. Any change should avoid adding inline branching or protocol-specific trigger objects.
