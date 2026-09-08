# Task 049: Jetpack Heat Runtime

## Objective

Add finite Jetpack heat with airborne-only consumption, grounded-only cooling, an overheat latch, and signal-driven HUD presentation without changing established movement feel or Player movement authority.

## Exact changed files

- `Game/scripts/movement/jetpack_controller.gd`
- `Game/scenes/player.tscn`
- `Game/scripts/player.gd`
- `Game/scenes/hud.tscn`
- `Game/scripts/hud.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/049_jetpack_heat_runtime/jetpack_heat_runtime_report.md`

## Architecture decision

`JetpackController` is a state-only `Node` child of Player. It owns heat, overheat, active state, tuning, and the typed state signal. It never writes Player velocity and never calls `move_and_slide()`. Player remains the sole movement authority and requests thrust once per physics frame through the typed `advance()` API.

## Heat state rules and tuning

- Maximum heat: `100.0`.
- Heat gain during actual thrust: `40.0` per second.
- Grounded cooling: `50.0` per second.
- Heat does not decrease while airborne.
- Releasing Space stops thrust immediately without cooling.
- Re-engagement is allowed before overheat while authorization remains valid and heat is below maximum.
- Reaching `100.0` clamps heat, latches overheat, and denies thrust.
- Overheat clears only when grounded heat reaches exactly `0.0`.
- Landing still clears the existing airborne authorization, so a new grounded jump is required after overheat recovery.

## Player integration

Player advances the controller exactly once per physics frame. Ordinary airborne authorization and existing jump/grapple transition logic remain in Player. Only a controller-approved thrust result applies the existing `JETPACK_TARGET_RISE_VELOCITY` and `JETPACK_ACCELERATION`; gravity remains applied normally when thrust is denied. Knee Dash requests no thrust and airborne dash frames do not cool heat.

## Grapple and Knee Dash interaction

World grapple movement does not consume heat unless the existing Space transition authorizes jetpack thrust. Grapple-derived momentum and held-hook behavior remain unchanged. Space during world grappling retains the existing detach-to-jetpack transition. Knee Dash retains movement priority, does not generate airborne heat, and does not add another movement call.

## HUD behavior

`JetpackStatusLabel` and `JetpackHeatBar` are placed below the interaction prompt on the left side of the native 1280x720 HUD. The HUD initializes from the controller and updates from `jetpack_state_changed`, without per-frame Player polling for heat. States are `READY`, `ACTIVE`, `HEAT`, `COOLING`, and `OVERHEATED` with a 0-100 percentage bar.

## Static validation results

- Required clean base, branch, fetch, fast-forward, and HEAD/origin verification passed.
- Complete source, scene, HUD, documentation, and report diff reviewed.
- `git diff --check` passed before staging.
- `Game/project.godot` remained untouched.
- No unrelated scenes, resources, UID files, weapons, Hook, Shield, equipment, Knee Dash, collision, or arena files changed.
- JetpackController never writes Player velocity or calls `move_and_slide()`.
- Player remains the only `move_and_slide()` authority, with one call per movement branch.
- Controller advance call occurs exactly once per physics frame.
- Heat, overheat, grounded cooling, grapple, dash, and authorization paths were statically reviewed.
- Repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending for heat rise, overheat, airborne pulsing, grounded cooling, reauthorization after zero heat, grapple-to-jetpack transition, Knee Dash, and HUD readability.

## Known risks or limitations

The controller uses the existing frame-start grounded state for cooling decisions, consistent with the established Player physics flow. No new heat timer, airborne cooling, fuel system, or jetpack tuning was introduced.

## Recommended next step

Run the Windows runtime checklist and verify the heat bar and overheat latch at native 1280x720.

## Commit and push results

The implementation and publication commit hashes, push results, final HEAD/origin comparison, and working-tree state will be recorded here after publication.

## Windows runtime checklist

1. Start the main scene and confirm `JETPACK: READY 0%`.
2. Jump and hold Space; confirm thrust works and heat rises.
3. Hold thrust until approximately 100% after 2.5 seconds; confirm thrust stops and `OVERHEATED 100%` appears.
4. Continue holding Space and confirm thrust does not restart.
5. Release and press Space before overheat; confirm heat is retained in air and thrust can resume.
6. Pulse Space repeatedly airborne and confirm heat never cools.
7. Land with heat and confirm `COOLING` until zero.
8. Jump before zero after overheat and confirm thrust remains unavailable.
9. After zero heat, perform a new grounded jump and confirm thrust is available.
10. Confirm partial heat cools after landing.
11. Test terrain grapple momentum, Space transition, Knee Dash, held Hook, Shield, weapon behavior, crouch, jump, and collisions.
12. Confirm no Godot parser or runtime errors.
