# Do not model packet formats

## Decision

This example does not model QUIC packet formats, frames, transport parameters, stream internals, congestion control, or TLS protocol details.

## Rationale

Those concerns would expand the example beyond the connection lifecycle and obscure the BehavioML modeling questions being tested.

## Consequences

Capabilities and interfaces use lifecycle-level language such as initial datagrams, handshake support, close signals, and timers rather than packet or frame structures.
