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
