# Context

## Project summary
- Goal: keep shared development context between sessions.
- Product: p2p_number iOS app.
- Scope: this repository/workspace only.

## Current state
- Status: active development.
- Known issues: track in TODO section below.

## Key constraints
- None recorded yet.

## Links
- None recorded yet.

## Decisions
Use this log for decisions that should persist across sessions.

### Template
- Date:
- Decision:
- Rationale:
- Alternatives considered:
- Impact:

## Notes

### Ongoing notes
- 2026-02-10: Attempted to fix digit animation desync by replacing SwiftUI transitions with explicit per-digit progress + manual layout.
  - Changes included: custom ZStack layout with computed x positions; progressById driving appear/disappear; removing outer withAnimation in input; added digitDisappear.
  - Result: desync persisted (first 0 still lags behind 3 when typing 300 quickly). Also broke deletion animations and caused digits to "fly in" from left due to x-position initialization.
  - Rolled back all code changes to last git state. No fix applied.

- 2026-02-10: Iterative attempts to fix desync when typing fast (e.g., "123") where earlier digits wait to shift left until later digit finishes appear animation.
  - Tried stable digit IDs (UUID per digit) to avoid view recreation; no visible improvement.
  - Switched to manual layout with GeometryReader + ZStack + computed x positions and per-digit appear progress (spring), shift (easeOut). Desync persisted.
  - Introduced per-element x shift via AnimatableModifier and removed container animation. Briefly appeared to help, but centering drifted; attempts to recenter introduced double-motion suspicion (local shift + container centering).
  - Hypothesis: dual movement (per-digit shift + container centering) causing perceived desync; attempts to separate (left-based positions + container offset) did not fix.
  - Tried fixed-width digit cells to remove font metric jitter; no improvement.
  - Tried storing xById state and animating it explicitly; broke layout (right-aligned, overlapping digits) due to timing/order issues.
  - Ultimately rolled back to git state after instability. No fix applied.

### Questions / Unknowns
- Root cause of desync still unclear: likely interaction between SwiftUI layout/transition timing and ongoing appearance animations.

## TODO

### Now
- 

### Next
- 

### Later
- 
