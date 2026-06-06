# WHIP Semantic Top-Down Remodel Progress

## Current phase status

- Current phase: Phase 0 — Reset WHIP BehavioML model.
- Status: Complete.
- Summary: The previous WHIP BehavioML source model and stale generated Mermaid diagrams were removed so the example can be rebuilt from RFC/source behavior using the semantic top-down process.
- Next phase safe to run: Yes, after human confirmation. Phase 1 should inspect or fetch the RFC 9725 source artifact before creating any new BehavioML model files.

## Commits made

- Phase 0 commit message: `docs(whip): reset model for semantic top-down rebuild`

## Files changed per phase

### Phase 0 — Reset WHIP BehavioML model

Removed:

- `examples/whip/model/`
- `examples/whip/generated/mermaid/`

Updated:

- `examples/whip/README.md`
- `examples/whip/generated/README.md`
- `examples/whip/generated/reports/semantic-top-down-remodel-progress.md`

## Source material available

- No local RFC/source artifact was present under `examples/whip/sources/` during Phase 0.
- Phase 1 must use an existing RFC source artifact if one is added before then, or fetch the official RFC 9725 text from the RFC Editor if network access is available.
- The removed WHIP BehavioML model must not be used as behavioral source material for subsequent phases.

## Open questions

- Phase 1 must confirm whether `examples/whip/sources/rfc9725.md` exists or fetch it from the official RFC Editor source.
- Phase 1 must determine the behavior-first semantic areas from the full RFC/source survey rather than from RFC section boundaries.

## Validation status

- `git status --short`: Run after Phase 0 changes.
- `find examples/whip -maxdepth 4 -type f | sort`: Run after Phase 0 changes.
- `npm run validate:models`: Not run in Phase 0 because the WHIP model was intentionally removed and this phase is limited to cheap repository hygiene checks.

## Phase gate

- Stopped after Phase 0.
- Do not proceed to Phase 1 until a human explicitly confirms continuation.
