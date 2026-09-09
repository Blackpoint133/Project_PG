# Task 066: Mission Extraction Geometry and Overlap Audit Fix

## Objective

Correct the extraction-zone vertical geometry, make already-overlapping Player detection reliable after deferred monitoring activation, and clear extraction availability after successful completion.

## Audited base

Required base: `a1ad41a594b240799e0ca2876e1dc3cf5a7c2947`.

## Root causes and exact changed files

The prior CollisionShape2D was offset by local Y 104, placing its actual bounds at Y 520 through 728. The deferred overlap check also read `get_overlapping_bodies()` without an explicit complete physics-frame boundary. Finally, successful completion left availability latched in Main and MissionController.

Exact changed files:

- `Game/scripts/interactables/mission_extraction_zone.gd`
- `Game/scenes/interactables/mission_extraction_zone.tscn`
- `Game/scripts/main.gd`
- `Game/scripts/missions/mission_controller.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/065_mission_extraction_completion/mission_extraction_completion_report.md`
- `DEV/reports/066_mission_extraction_audit_fix/mission_extraction_audit_fix_report.md`

## Corrected geometry

The root remains at `Vector2(2440, 520)`. The `Vector2(160, 208)` collision shape is centered at local `Vector2(0, 0)`, so its world bounds are Y `520 - 104 = 416` through `520 + 104 = 624`. VisualField and Outline use local Y -104 through 104, the Beacon ends at local Y 104, and ZoneLabel remains above the field. No visual extends below world Y 624. Collision layer 0, mask 2, and non-solid Area2D behavior are unchanged.

## Corrected overlap timing

`activate()` still uses deferred monitoring. The existing-body check is now deferred and awaits `get_tree().physics_frame` before reading overlap data. It validates active, completed, and monitoring state after the await, then calls the same `_request_extraction` boundary used by `body_entered`. A normal entry or an already-overlapping exact Player therefore follows the same Main validation and MissionController completion path; later duplicate checks are harmless.

## Availability and completion state

Main clears `_extraction_available` after MissionController accepts completion and the zone transitions to completed/inactive presentation. MissionController clears `_extraction_is_available` before latching `_extraction_is_completed`. Consequently, the final states are: zone active false/completed true, Main availability false, and MissionController availability false/completed true. Duplicate completion remains rejected, `MISSION COMPLETE` remains one-shot, and `extraction_completed` remains one-shot. The historical `mission_completed` signal is not emitted again.

## Preserved behavior

The extraction position, objective strings, collision layer and mask, cyan/green presentation concept, Main scene, Player, HUD, mercenaries, radio, helicopter, loot case, InteractionController, arena, project settings, input, movement, combat, equipment, and ability behavior remain unchanged.

## Validation performed

- Confirmed branch `main`, clean working tree, successful `git fetch origin`, and required HEAD/origin base.
- Reviewed all required extraction, Main, MissionController, scene, arena, Player, documentation, and historical report files before editing.
- Verified the geometry arithmetic and corrected local bounds.
- Verified deferred monitoring plus a complete `physics_frame` await before overlap querying.
- Verified body-entered and existing-overlap paths share `_request_extraction`.
- Verified availability is cleared in Main and MissionController before/at completion, while completed state remains latched.
- Ran `git diff --check` and staged checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser, import, startup, visual, and runtime validation were not performed by Codex.

## Windows runtime checklist

1. Confirm the extraction field is hidden before encounter completion.
2. Complete the radio, helicopter, loot-case, reward, and mercenary sequence.
3. Confirm the corrected field spans Y 416 through 624 and does not extend below the floor.
4. Confirm the cyan field appears only after all three exact mercenaries are defeated.
5. Enter the field normally and confirm `MISSION COMPLETE`.
6. Activate extraction while Player is already inside the future zone and confirm no re-entry is required.
7. Leave and re-enter; confirm completion and signals do not repeat.
8. Confirm the zone remains non-solid and has no F prompt.
9. Verify movement, Slide, Jetpack, Knee Dash, Hook, Shield, weapons, equipment, and HUD.
10. Confirm no red Godot parser or runtime errors appear.

## Publication

Implementation commit: `610087f0850951a13cfcd2979bac1a8b4ec5bf00` (`fix: correct mission extraction zone`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after the Task 066 documentation commit and returned in the final handoff.

Windows runtime validation remains pending.
