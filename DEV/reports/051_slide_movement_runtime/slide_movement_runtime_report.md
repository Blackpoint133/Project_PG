# Task 051: Grounded and Landing Slide Runtime

## Objective

Add a reusable grounded and landing slide driven by the existing Ctrl crouch action while preserving ordinary crouch, Player movement authority, collision, jetpack, grapple, Knee Dash, Shield, weapon, and equipment behavior.

## Exact changed files

- `Game/scripts/movement/slide_controller.gd`
- `Game/scenes/player.tscn`
- `Game/scripts/player.gd`
- `Game/scenes/hud.tscn`
- `Game/scripts/hud.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/051_slide_movement_runtime/slide_movement_runtime_report.md`

## Architecture decision

`SlideController` is a state-only `Node` child of Player. It owns active state, signed locked slide speed, duration, cooldown, tuning, and a typed state signal. It never reads input, writes Player velocity, changes collision shapes, moves the Player, or calls `move_and_slide()`. Player supplies requests and remains the sole movement authority.

## Final slide tuning

- Minimum entry horizontal speed: `260.0`.
- Minimum initial slide speed: `600.0`.
- Duration: `0.65` seconds.
- Deceleration: `720.0` pixels per second squared.
- Minimum active speed: `180.0`.
- Cooldown after completion or cancellation: `1.0` second.

No upper entry speed cap was added; grapple-derived or otherwise valid momentum is preserved.

## Grounded and landing entry

A new Ctrl press starts a grounded slide only when the Player was grounded at frame start, is not Knee Dashing or world grappling, the controller is ready, and horizontal speed reaches 260.0. Stationary or slow Ctrl remains ordinary crouch, and holding Ctrl while accelerating cannot auto-start a grounded slide.

Landing entry is edge-triggered by `not was_on_floor and is_on_floor()`. If Ctrl is held, horizontal speed reaches 260.0, cooldown is zero, Knee Dash is inactive, and Hook grappling is inactive, the controller starts a landing slide. Continuous ground contact cannot retrigger it after cooldown expiry.

## Slide movement and cooldown

While active, Player applies the controller's locked signed horizontal speed and keeps the crouched pose. Input cannot reverse the slide, release of Ctrl does not cancel it, and the existing single `move_and_slide()` call handles walls, floors, and living enemies. Leaving the ground or a horizontal blocking collision cancels the slide and starts cooldown. Duration completion starts the same cooldown exactly once. Cooldown continues while airborne.

## Momentum and jump transition

Slide cancellation does not zero horizontal velocity. Jumping from an active grounded slide cancels it, starts cooldown, and uses the existing jump path without requesting jetpack thrust on the grounded frame. Existing airborne gravity, authorization, heat, and later jetpack thrust remain unchanged.

## Grapple, jetpack, Knee Dash, Shield, and collisions

World grapple start cancels slide without clearing velocity, preserving grapple-derived momentum. Knee Dash has priority, cancels slide, and retains its existing velocity and tuning. Slide frames request no jetpack thrust; grounded controller advancement still allows normal grounded heat cooling. Shield crouch presentation is updated while sliding. Player collision layers, masks, shapes, living-enemy solidity, Hook behavior, weapons, and equipment remain unchanged.

## HUD behavior

`SlideStatusLabel` is placed below the Jetpack heat bar at native 1280x720. It initializes from controller getters and updates only through `slide_state_changed`, displaying `SLIDE: READY`, `SLIDE: ACTIVE`, or `SLIDE: COOLDOWN 0.0s`.

## Static validation

- Required clean base, branch, fetch, fast-forward, and HEAD/origin verification passed.
- Complete source, scene, HUD, documentation, and report diff reviewed.
- `git diff --check` passed before staging.
- `Game/project.godot` and the existing Ctrl crouch binding remained untouched.
- SlideController never writes Player velocity or calls `move_and_slide()`.
- Player remains the sole movement authority with no additional movement call.
- Slide controller advancement occurs exactly once per physics frame.
- Grounded just-pressed entry, edge-triggered landing entry, cooldown, release continuation, momentum, jump, wall, enemy, grapple, Knee Dash, jetpack, and Shield paths were statically reviewed.
- HUD offsets were checked for non-overlap at native 1280x720.
- Repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending for stationary crouch, moving entry, held-Ctrl landing, slide release, locked direction, cooldown, jump momentum, walls, enemies, grapple momentum, Knee Dash, Shield pose, and HUD readability.

## Known risks

The controller uses the existing frame-start grounded state for grounded entry and cooling interactions, while landing entry is evaluated after the existing collision step. Final slide feel, visuals, effects, and balancing remain placeholder work.

## Recommended next step

Run the Windows runtime checklist and tune slide feel only after confirming collision and landing transitions.

## Commit and push results

The implementation and publication commit hashes, push results, final HEAD/origin comparison, and working-tree state will be recorded here after publication.

## Windows runtime checklist

1. Confirm `SLIDE: READY` at startup.
2. Hold Ctrl while stationary and confirm ordinary crouch without sliding.
3. Run and press Ctrl; confirm locked-direction slide and `MOVEMENT: sliding`.
4. Release Ctrl and confirm the slide continues.
5. Confirm direction cannot reverse during the slide.
6. Confirm one-second cooldown and no retrigger while Ctrl remains held.
7. Hold Ctrl during a fast airborne landing and confirm a landing slide.
8. Confirm slow landings produce only ordinary crouch.
9. Jump from a slide and confirm horizontal momentum and cooldown.
10. Test grapple momentum, walls, living enemies, Knee Dash, jetpack heat, Shield, Hook, weapons, pickups, crouch visuals, and HUD layout.
11. Confirm no Godot parser or runtime errors.
