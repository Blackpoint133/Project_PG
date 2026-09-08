# Task 046: World Grapple Momentum Audit Fix

## Required and actual base commit

Required base: `ac1e983f7cda67ac3e556b63ba1417cfa38fc712`.

The clean `main` branch was verified at the required base before editing.

## Objective

Correct post-grapple airborne horizontal momentum preservation and prevent a same-frame C plus E input from starting a new Hook during an active Knee Dash.

## Completed changes

Player now tracks a narrowly scoped momentum-preservation flag set by the successful world-grapple signal. Airborne no-input movement preserves horizontal velocity while that flag is active, while gravity, jetpack behavior, air control, grapple acceleration, speed limiting, and the single `move_and_slide()` call remain unchanged. Landing clears the flag, and a successfully started Knee Dash clears it because Knee Dash replaces velocity.

The physics input order resolves the active Knee Dash state after the C request and before E activation. E still cancels an active Hook, but it cannot request a new Hook when Knee Dash is active and Hook is idle.

## Exact changed files

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/046_world_grapple_momentum_audit_fix/world_grapple_momentum_audit_fix_report.md`

## Audit root causes and behavior

The prior no-input branch applied `GROUND_FRICTION` in the air regardless of how the Player became airborne, rapidly removing horizontal velocity after grapple detachment. The correction bypasses that damping only while the Player is airborne with momentum inherited from a successful world grapple. Horizontal input continues to use the existing acceleration path.

The prior C-before-E ordering allowed Knee Dash to cancel an existing Hook, after which the same-frame E branch could see an idle HookController and start another Hook. The corrected order resolves `dash_active` before the E request; active Hook cancellation remains available, while new Hook activation is suppressed during an active dash.

## Flag lifecycle

- Set when `player_grapple_started` confirms a successful world grapple.
- Retained during the grapple and after E, Space, arrival, timeout, obstruction, or right-arm replacement detachment while airborne.
- Retained through airborne jetpack transition.
- Cleared after landing.
- Cleared when Knee Dash successfully starts.
- Never used for ordinary jumps or non-grapple airborne movement.

Hook cancellation does not zero Player velocity, restart Hook cooldown, or change the exact-instance cooldown state.

## Validation performed

- Preflight branch, clean tree, fetch, and required base verification passed.
- The complete focused source and documentation changes were reviewed.
- `git diff --check` passed before staging.
- `Game/project.godot` remained untouched.
- Scenes, resources, HookController, weapons, Shield, equipment ownership, and unrelated movement systems remained untouched.
- Movement and grapple tuning constants were reviewed as unchanged.
- The Player still has one `move_and_slide()` call in each existing movement branch and remains the sole owner of Player velocity.
- The repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending. Confirm airborne grapple momentum, grounded friction, all grapple detach paths, same-frame C plus E behavior, and normal Hook cooldown behavior in Godot 4.7.2.

## Known risks or limitations

This is a focused movement/input ordering correction. It does not redesign grapple state, movement tuning, Hook cancellation, or Knee Dash behavior.

## Recommended next step

Run the Windows runtime checklist with grounded and airborne world anchors, including C plus E simultaneous input and arm replacement during airborne momentum.

## Commit and push results

The implementation commit and its normal push will be recorded here after publication. The report-only publication update will record the verified implementation hash, remote result, HEAD/origin comparison, and working-tree state.

## Windows runtime checklist

- Launch the project and confirm no Godot parse or runtime errors.
- Grapple from airborne toward a world surface, detach with E, and confirm horizontal momentum persists without input until landing.
- Confirm ordinary jumps and airborne movement still use existing damping.
- Confirm grounded grapple behavior retains normal ground friction.
- Confirm Space detachment preserves momentum into the existing jetpack transition.
- Confirm arrival, timeout, obstruction, and arm-swap detachment preserve airborne momentum.
- Press C and E together while a Hook is active and confirm Knee Dash cancels the Hook without firing a new one.
- Confirm E still cancels an active Hook normally and Hook cooldown remains exact-instance state.
