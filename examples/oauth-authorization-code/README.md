# OAuth 2.0 Authorization Code Flow Example

This exploratory BehavioML example models the core OAuth 2.0 Authorization Code Flow at a behavioral level.

The purpose is not to teach OAuth or implement the full RFC. The purpose is to stress-test BehavioML against a business/security protocol with redirects, consent, token issuance, and protected resource access.

## What this example models

The model covers these behaviorally meaningful scenarios:

1. A client starts an authorization request.
2. The authorization server receives the authorization request.
3. The authorization server authenticates or identifies the resource owner.
4. The authorization server obtains consent or validates existing consent.
5. The authorization server redirects back with an authorization code.
6. The client exchanges the authorization code for tokens.
7. The authorization server validates the authorization code.
8. The authorization server issues tokens.
9. The client calls the resource server with the access token.
10. The resource server validates the token or authorization context.
11. The resource server returns the protected resource.

It also includes two focused failure scenarios:

- authorization denied
- invalid authorization code

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

## What this example intentionally does not model

This example intentionally excludes:

- full OAuth RFC behavior
- PKCE
- OpenID Connect
- refresh token rotation
- JWT internals
- HTTP request/response syntax
- cryptographic details
- every RFC error code
- implementation classes
- framework details
- generated diagrams

The model keeps tokens and authorization codes as behavioral artifacts, not as protocol wire formats.

## Generated views

Generated Mermaid diagrams are available under:

```text
generated/mermaid/
```

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
