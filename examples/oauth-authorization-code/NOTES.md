# OAuth Authorization Code Flow Modeling Notes

This example is exploratory and intentionally limited. It tests whether current BehavioML concepts can describe a security/business protocol flow without introducing OAuth-specific schema.

## User agent as a role

The user agent is modeled as a role because browser mediation is behaviorally relevant. Redirects are central to the authorization code flow, even though the user agent is not an OAuth endpoint in the same way as the client, authorization server, or resource server.

This seems to fit the current `roles.primary` and `roles.participants` model without requiring a new participant type.

## Workflows without explicit trigger

`client/start_authorization.yaml` is intentionally a root behavior without `triggered_by`. It represents an externally initiated user or application action rather than an event emitted by another model element.

Other workflows use `triggered_by` when a clear event exists, such as `authorization_requested`, `consent_granted`, `authorization_code_issued`, `token_request_received`, and `protected_resource_requested`.

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
- `authorization_code_issued` triggers client token exchange.
- `token_request_received` triggers token request handling.
- `protected_resource_requested` triggers protected resource serving.

It felt too narrow only for externally initiated behavior. `workflows/client/start_authorization.yaml` is a root/user-initiated workflow, but the current model has no way to say that without adding a new schema concept. For now, omitting `triggered_by` is the right fit.

### Inline branching deliberately avoided

There were two places where inline branching would have been tempting but was intentionally avoided:

- Consent grant versus denial after `capabilities/oauth/obtain_consent.yaml`.
- Valid authorization code versus invalid authorization code after `capabilities/oauth/validate_authorization_code.yaml`.

Separate workflows were clearer and stayed aligned with BehavioML's scenario-oriented workflow rules:

- `workflows/authorization_server/issue_authorization_code.yaml`
- `workflows/authorization_server/deny_authorization.yaml`
- `workflows/authorization_server/handle_token_request.yaml`
- `workflows/authorization_server/reject_invalid_code.yaml`

This supports the current guidance that workflows should not become executable branch graphs.

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
