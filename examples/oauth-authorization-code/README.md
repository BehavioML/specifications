# OAuth 2.0 Authorization Code Flow Example

This exploratory BehavioML example models the core OAuth 2.0 Authorization Code Flow at a behavioral level.

The purpose is not to teach OAuth or implement the full RFC. The purpose is to stress-test BehavioML against a business/security protocol with redirects, consent, token issuance, and protected resource access.

This example also uses the proposed sequence-diagrammable workflow step shape experimentally: workflow steps identify the acting role with `from`, optional cross-role recipients with `to`, the stable `capability`, and a contextual human-facing `label`.

## What this example models

The model covers these behaviorally meaningful scenarios:

1. A client starts an authorization request.
2. The authorization server receives the authorization request.
3. The authorization server authenticates or identifies the resource owner.
4. The authorization server obtains consent or validates existing consent.
5. The authorization server redirects back with an authorization code.
6. The user agent delivers the authorization callback to the client.
7. The client-observed callback event triggers code exchange; the model does not infer this directly from server-side code issuance.
8. The client exchanges the authorization code for tokens.
9. The authorization server validates the authorization code and produces tokens internally.
10. The authorization server returns the token response to the client.
11. The client calls the resource server with the access token.
12. The resource server validates the token or authorization context.
13. The resource server returns the protected resource.

It also includes focused failure scenarios:

- authorization denied
- invalid authorization code
- invalid authorization request or rejected redirect URI
- rejected access token and protected resource denial

## Model structure

The source-of-truth model is under `model/`:

```text
model/
├── capabilities/oauth/
├── components/
├── decisions/
├── entities/
├── events/
├── interfaces/oauth/
├── modules/
├── roles/
├── state-machines/authorization_code/
└── workflows/
```

Key behavioral workflows are grouped by primary role:

- `workflows/client/start_authorization.yaml`
- `workflows/authorization_server/handle_authorization_request.yaml`
- `workflows/authorization_server/issue_authorization_code.yaml`
- `workflows/client/exchange_code_for_tokens.yaml`
- `workflows/authorization_server/handle_token_request.yaml`
- `workflows/client/call_resource_server.yaml`
- `workflows/resource_server/serve_protected_resource.yaml`
- `workflows/authorization_server/deny_authorization.yaml`
- `workflows/authorization_server/reject_invalid_code.yaml`
- `workflows/authorization_server/reject_invalid_authorization_request.yaml`
- `workflows/resource_server/deny_protected_resource.yaml`

## What this example intentionally does not model

This example intentionally excludes:

- full OAuth RFC behavior
- PKCE
- OpenID Connect
- resource-owner authentication failure handling beyond the successful authentication/identification path
- refresh-token grant, rotation, revocation, and lifecycle behavior
- JWT internals
- HTTP request/response syntax
- cryptographic details
- every RFC error code
- implementation classes
- framework details
- generated diagrams

The model keeps tokens and authorization codes as behavioral artifacts, not as protocol wire formats. Refresh-token issuance is represented as an optional authorization-server policy outcome during token response production; this example does not model refresh-token use after issuance.

## Behavioral readiness clarifications

This pass tightens several implementation-scaffold boundaries without expanding into full RFC behavior:

- Server-side `authorization_code_issued` is distinct from client-observed `authorization_code_received_by_client`; the client token-exchange workflow starts only after the user agent delivers the callback to the client.
- Invalid authorization requests or rejected redirect URIs are modeled as safe authorization-server rejection behavior. The model intentionally does not redirect to an unvalidated URI or invent an unsafe callback.
- Access-token rejection is modeled separately from successful token validation, and protected resource denial is an observable resource-server response.
- Resource-owner authentication failure remains out of scope; the example models only successful authentication or identification before consent.
- Refresh-token issuance remains optional by authorization-server policy and is represented only as an issuance artifact, not as a refresh-token grant or lifecycle model.

## Generated views

Generated Mermaid diagrams are available under:

```text
generated/mermaid/
```

Generated Mermaid documentation includes state-machine diagrams and workflow sequence diagrams. OAuth workflow sequence diagrams are especially useful for browser-mediated redirects, callbacks, token exchange, and protected resource calls. Relationship graphs, when present, are inspection views rather than primary documentation.

These files are derived from the model and should be regenerated after model changes.

## How to validate

From the repository root, run:

```bash
npm run validate:models
```

The validation script checks both the existing QUIC model and this OAuth model.

## How this differs from the QUIC example

The QUIC example stresses lifecycle and protocol endpoint behavior around a connection entity.

This OAuth example stresses different modeling concerns:

- redirect-mediated behavior through a user agent
- consent as both persisted authorization state and observable outcome
- a short-lived authorization code lifecycle
- security/business protocol behavior without modeling packet or HTTP syntax
- separate success and failure workflows instead of inline branch logic
