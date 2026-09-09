# Task 059: Helicopter Destruction Presentation and Loot Case Drop

## Objective

Replace the permanent gray helicopter wreck placeholder with a short deterministic explosion and physically drop one closed loot case that updates the mission objective after landing.

## Audited base

- Required base: `d91f97e55bd6bc69748869a69198fe9de92b7ddc`
- Branch: `main`
- Working tree was clean before implementation and local HEAD was fast-forwarded to the required base.

## Exact changed file list

- `Game/scripts/enemies/mission_helicopter.gd`
- `Game/scenes/enemies/mission_helicopter.tscn`
- `Game/scripts/interactables/world_loot_case.gd`
- `Game/scenes/interactables/world_loot_case.tscn`
- `Game/scripts/missions/mission_controller.gd`
- `Game/scripts/main.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/059_helicopter_loot_case_drop/helicopter_loot_case_drop_report.md`

HUD, Player, project settings, existing pickup scripts, and arena geometry were intentionally unchanged.

## Destruction sequence

On the first transition to zero health, MissionHelicopter captures its exact global position and current horizontal velocity, stops movement, clears living-enemy collision, hides its helicopter visuals, shows a restrained orange/red flash, and starts a one-shot 0.4-second Timer. Its typed `destroyed(drop_position, ejection_velocity)` signal emits once. The helicopter node remains owned by Main and is hidden after the timer without being freed.

## Typed destruction payload

The payload contains the global destruction position and deterministic ejection velocity: half of the captured horizontal helicopter velocity plus a fixed upward `-260.0` impulse. Main applies the authored `Vector2(0, 32)` spawn offset.

## Loot-case spawn and motion

Main owns the preloaded `WorldLootCase` PackedScene and guards `_loot_case_spawned`. It instantiates exactly one case, adds it under `World`, places it at the payload position plus offset, connects `landed` before launch, and calls `launch`. The case owns only gravity-driven falling, capped downward speed `1200.0`, grounded horizontal friction `1000.0`, and a one-shot landed latch. It uses the project gravity and world collision through CharacterBody2D movement.

Task 068 corrected the later Windows physics-query diagnostic by moving typed loot-case construction, connection, insertion, placement, and launch into one private deferred Main helper. Helicopter destruction still completes the mission and hides the HUD synchronously, while the one-case latch is set before scheduling the helper. The drop position, spawn offset, ejection velocity, landing, opening, and reward behavior remain unchanged.

## Collision contract

WorldLootCase uses interactable layer 6 / integer layer 32 and world mask 1. It has no `get_interaction_prompt` or `interact` methods, so InteractionController ignores it safely. Player collision mask 5 does not include the interactable layer, so the case does not block Player movement.

## Landing and objective transition

The case emits `landed` only on its first airborne-to-floor transition. Main verifies the case is landed and calls `MissionController.mark_loot_case_ready`. This succeeds only once for the completed `destroy_helicopter` mission, changes the objective to `OPEN THE LOOT CASE`, emits `objective_changed`, and emits the future-facing `loot_case_ready` signal.

## Duplicate guards

MissionHelicopter has a destruction latch and rejects later damage. Main has a single-spawn latch. MissionController rejects duplicate or mismatched completion and loot-case-ready requests. WorldLootCase rejects repeated launch calls and emits landing once.

## Explicitly deferred Task 060 behavior

The case is intentionally closed and non-interactive. F interaction, opening animation/state, shotgun reward, Shield Left Arm reward, Hook Right Arm reward, Knee-Dash Legs reward, physical item ejection, collection objective, and reward completion are deferred to Task 060.

## Preserved systems

Helicopter activation, patrol, health, projectile damage, Player movement, Ctrl crouch and Slide, Jetpack, Knee Dash/Bleeding, Shield, Hook, weapons, equipment, radio interaction, nearest-candidate selection, and native 1280x720 configuration remain unchanged outside the required mission integration.

## Static validation performed

- Confirmed required clean base after fast-forward-only synchronization.
- Inspected every changed script and scene plus current mission/Main boundaries.
- Confirmed the explosion Timer is one-shot and 0.4 seconds.
- Confirmed one typed destruction payload and one case-spawn guard.
- Confirmed case gravity, fall-speed cap, world mask, interactable layer, friction, and one-shot landing signal.
- Confirmed the case has no interaction methods.
- Confirmed objective transition occurs only after landing.
- Ran `git diff --check` and staged diff checks.
- Ran repository Cyrillic scan excluding `.git`.
- Confirmed no new UID file was created manually.

## Checks not performed

Godot 4.7.2 parser, import, startup, runtime, and visual validation were not performed because a compatible Godot executable was not available in the environment.

## Known limitations

The case is a closed placeholder and cannot be opened. No rewards, contents, opening presentation, explosion effects, audio, particles, helicopter attacks, or extraction behavior are implemented.

## Focused Windows runtime checklist

1. Activate the radio and destroy the helicopter.
2. Confirm movement stops and enemy collision clears immediately at zero health.
3. Confirm the orange/red explosion stays at the destruction point for about 0.4 seconds.
4. Confirm the helicopter body disappears without removing its scene reference.
5. Confirm exactly one case appears with deterministic upward and inherited horizontal ejection.
6. Confirm the case falls, collides with floor/platform geometry, and settles.
7. Confirm landing emits once and objective changes to `OPEN THE LOOT CASE` only then.
8. Confirm the case has no F prompt and repeated destruction/landing signals are harmless.
9. Verify radio, weapons, movement, Slide, Jetpack, Knee Dash/Bleeding, Shield, Hook, pickups, and HUD.
10. Confirm no red Godot parser or runtime errors appear.

## Publication results

- Implementation commit: `c9b36cb93991e3e980425983069b46e4c146a715`.
- Implementation push to `origin/main`: succeeded.
- Documentation publication commit: recorded in the final task handoff.
- Windows runtime validation remains pending.
