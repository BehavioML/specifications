# Add roles as workflow participants

## Decision

This exploratory model treats Role as a first-class entity that may participate in workflows.

## Rationale

QUIC lifecycle behavior naturally refers to client, server, and endpoint participants. These are functional participants in protocol behavior, not components, modules, entities, or implementations.

## Consequences

Workflow files may include `roles`, but they still use capabilities and emit events. Roles do not implement capabilities, own state, or organize components.
