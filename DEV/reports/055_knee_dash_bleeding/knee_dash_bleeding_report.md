# Task 055: Knee Dash Bleeding

## Objective

Add a reusable, delayed, non-stacking Bleeding status effect to valid Knee Dash enemy contacts while preserving direct damage, full-body contact, and all existing movement and combat behavior.

## Completed changes

Added `BleedingStatusController`, data-driven Bleeding fields on `LegAbilityDefinition`, authored Knee Dash Bleeding values, generic Knee Dash integration, and one TargetDummy status child with red presentation. Bleeding is advanced once per target physics frame and applies due damage through the existing `take_damage` method.

## Exact changed file list

- `Game/scripts/status_effects/bleeding_status_controller.gd`
- `Game/scripts/equipment/leg_ability_definition.gd`
- `Game/resources/equipment/knee_dash_ability.tres`
- `Game/scripts/abilities/knee_dash_controller.gd`
- `Game/scripts/targets/target_dummy.gd`
- `Game/scenes/targets/target_dummy.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/055_knee_dash_bleeding/knee_dash_bleeding_report.md`

## Bleeding timing and damage contract

Each valid application stores 4 damage per tick, a 1.0-second interval, and exactly 4 ticks. The first tick is delayed until one second has elapsed. One uninterrupted application therefore deals exactly 16 delayed damage. Large delta values can produce multiple due ticks in one advance call without creating additional status instances.

## Refresh and non-stacking behavior

Applying valid Bleeding replaces the current state, resets remaining ticks to four, and resets the next-tick timer to one second. No parallel timer or stacking state is created. Invalid non-positive authored values are rejected. Defeat clears all remaining Bleeding state.

## Controller ownership

`BleedingStatusController` extends `Node` and owns only timing and damage state. It does not own health or movement, search the scene tree, depend on a target class, or call `take_damage`. `TargetDummy` owns one controller child and passes returned tick damage through its existing health API.

## Knee Dash integration boundary

`KneeDashController` remains generic. After direct damage on a valid enemy-layer contact, it calls `apply_bleeding` only when that method exists and the contact still remains on enemy layer bit 4. Direct damage remains available to future enemies without Bleeding support, and world, defeated, invalid, and incompatible contacts are excluded.

## TargetDummy integration and presentation

TargetDummy rejects Bleeding at zero health, advances it once per physics frame, and stops movement processing if a tick defeats it. Dead gray presentation has priority; Hook stun cyan presentation has priority over the active red Bleeding tint, while the Bleeding timer continues underneath.

## Collision-layer documentation correction

Full-body Knee Dash contact uses Player body layer 2 against enemy layer 3 (integer bit 4). Player attack layer 4 contains weapon projectiles, shotgun pellets, and Hook behavior, not Knee Dash body contact.

## Preserved gameplay behavior

Direct Knee Dash damage remains 25, once per target per dash. Direction, 45-degree clamp, dash speed/duration, knockback, cooldown, exact LegInstance ownership, living-enemy solidity, defeated-target passability, and Slide, Hook, grapple, Jetpack, Shield, weapon, pickup, HUD, input, and project settings remain unchanged. Bleeding is the only new damage-over-time behavior.

## Checks actually performed

- Required clean base and branch verification passed at `618490d8239b87cbb722d58f13937801940db95d`.
- Complete diff reviewed; only the ten allowed Task 055 files are intended to change.
- `git diff --check` and staged diff checks passed.
- Authored Bleeding values verified as 4 damage, 1.0-second interval, and 4 ticks.
- Controller first-tick delay, refresh reset, non-stacking state, multi-tick advancement, and clear behavior were statically reviewed.
- TargetDummy advances Bleeding once per physics frame and clears it on defeat.
- KneeDashController remains generic with no TargetDummy dependency; full-body contact and once-per-dash tracking remain intact.
- Player scripts/scenes, `Game/project.godot`, HUD, arena, weapons, and unrelated resources remained untouched.
- No UID file was created.
- Cyrillic scan excluding `.git` passed.
- No Godot executable was available; parser, runtime, and visual validation were not performed.

## Pending Windows runtime checks

Verify immediate 25 damage, four delayed 4-damage ticks, red tint, refresh without stacking, Hook stun tint priority, death clearing, solidity/passability, and all existing movement/combat regressions.

## Known risks or limitations

The prototype uses aggregate due damage for unusually large frame deltas and placeholder tint presentation. Production blood effects, audio, particles, and additional damage-status effects remain deferred.

## Recommended next step

Run the Windows runtime checklist and then continue with the integrated movement and combat audit in Task 056.

## Implementation commit and push result

Implementation commit: `26a6cd2ef4056cbf765694df182b826c8b2bda71` (`feat: add knee dash bleeding`). It was pushed normally to `origin/main`; after the push, local HEAD and `origin/main` matched and the working tree was clean. The final report and Project Context publication record are committed separately with the required documentation commit.
