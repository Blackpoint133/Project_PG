# Task 068: Physics-Safe Loot Case Spawn and Crouch Offset Type Fix

## Objective

Fix the Windows-observed physics-query flushing diagnostic during helicopter destruction and the incompatible int/float crouch ternary diagnostic while preserving mission, loot, movement, crouch, equipment, combat, and presentation behavior.

## Audited base

Required implementation base: `72f7e954610d01e97c8ede9059b2a941e813eb77`.

## Windows-observed diagnostics and root causes

The first diagnostic repeatedly reported that monitoring state could not change while queries were flushing at the old `Game/scripts/main.gd:76` insertion path. `MissionHelicopter.destroyed` can be emitted from a projectile collision callback, and immediate insertion of the collision-bearing `WorldLootCase` under `World` ran inside that physics query flush.

The second diagnostic reported incompatible ternary branch types while loading `Game/scripts/player.gd`. `CROUCH_VISUAL_OFFSET` was inferred as integer `32`, while `_update_crouch()` combined it with float `0.0` in an explicitly float local expression.

## Exact changed files

Implementation:

- `Game/scripts/main.gd`
- `Game/scripts/player.gd`

Documentation:

- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/059_helicopter_loot_case_drop/helicopter_loot_case_drop_report.md`
- `DEV/reports/068_runtime_physics_and_ternary_fix/runtime_physics_and_ternary_fix_report.md`

No other files changed in Task 068.

## Exact fixes

`_on_helicopter_destroyed()` still performs the duplicate latch, mission completion request, and helicopter-health HUD hiding synchronously. It now schedules exactly one `_spawn_loot_case_deferred(drop_position, ejection_velocity)` call. The helper preserves the raw instantiated `Node` until casting, validates `WorldLootCase`, frees an invalid raw node with a clear English error, stores the typed reference, connects `landed` and `opened`, adds the case under `World`, applies `drop_position + LOOT_CASE_SPAWN_OFFSET`, and launches with the unchanged ejection velocity.

Player now declares:

`const CROUCH_VISUAL_OFFSET: float = 32.0`

`upper_body_offset` remains explicitly typed as `float`, and both ternary values are floats without changing crouch geometry or movement behavior.

## Preserved behavior

Helicopter timing, explosion timing, mission objectives, loot-case gravity, collision, landing, opening, reward contents, duplicate latches, Player movement, crouch visuals, collision height, Slide, aiming, weapons, equipment, abilities, HUD, projectiles, input, collision layers, scenes, resources, project settings, and UID files remain unchanged.

## Validation performed

- Confirmed the expected clean `main` state and performed the required fast-forward-only synchronization to the exact base.
- Read `AGENTS.md`, `godot-run-and-gun/SKILL.md`, the implementation files, active design documents, and Task 059 report before editing.
- Reviewed the complete implementation diff.
- Confirmed `_on_helicopter_destroyed()` no longer directly inserts the loot case.
- Confirmed exactly one deferred helper performs loot-case instantiation and collision-bearing insertion.
- Confirmed the helper preserves typed drop position, ejection velocity, spawn offset, signals, and one-case guard.
- Confirmed `CROUCH_VISUAL_OFFSET` is `float` `32.0` and the crouch ternary remains explicitly float.
- Ran `git diff --check` and staged checks.
- Confirmed `Game/project.godot` was unchanged.
- Confirmed no UID file was created or modified by Task 068.
- Ran the tracked-project Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser and runtime validation were not performed by Codex.

## Publication

Implementation commit: `db85e187859cb6f70bb419952cffa3f5abd452a2` (`fix: defer loot case spawn safely`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after the documentation commit and returned in the final handoff.

## Focused Windows runtime checklist

1. Restart Godot or clear debugger history.
2. Start a fresh Main scene run.
3. Confirm no incompatible-ternary warning appears at startup.
4. Activate the radio and destroy the helicopter.
5. Confirm no physics-query flushing errors appear.
6. Confirm exactly one explosion and one loot case appear.
7. Verify case ejection, landing, opening, and four reward ejection.
8. Complete reward collection and defeat all three mercenaries.
9. Verify normal extraction entry.
10. In another run, stand inside the future extraction zone before the third enemy dies and confirm immediate `MISSION COMPLETE`.
11. Confirm crouch visuals and collision remain unchanged.
12. Confirm no red errors or yellow warnings remain.
