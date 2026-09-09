# Task 067: Extraction Existing-Overlap Timing Fix

## Objective

Correct the delayed existing-body extraction query so an already-overlapping Player is checked only after deferred monitoring and a complete physics-step opportunity have updated the Area2D overlap list.

## Audited base

Required base: `a5d1a9a6202fe72c467009f9ebed16db205246fc`.

## Root cause and exact changed files

The Task 066 fallback awaited one `SceneTree.physics_frame`. That signal is emitted before `Node._physics_process`, while Area2D overlap data is updated during the physics step. One await therefore did not explicitly guarantee that the queried list reflected monitoring activation.

Exact changed files:

- `Game/scripts/interactables/mission_extraction_zone.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/066_mission_extraction_audit_fix/mission_extraction_audit_fix_report.md`
- `DEV/reports/067_extraction_overlap_timing_fix/extraction_overlap_timing_fix_report.md`

## Corrected timing sequence

1. `activate()` enables monitoring with `set_deferred("monitoring", true)`.
2. The deferred coroutine starts.
3. It awaits the first `get_tree().physics_frame`.
4. It awaits a second successive `get_tree().physics_frame`, allowing one complete physics step between coroutine resumptions.
5. It validates `_is_active`, `_is_completed`, and `monitoring`.
6. It queries `get_overlapping_bodies()` and forwards each body through `_request_extraction`.

The normal `body_entered` path remains authoritative for ordinary entry and uses the same `_request_extraction` boundary. If that path completes extraction first, the delayed coroutine observes `_is_completed` after the second await and returns harmlessly.

## Preserved behavior

The extraction root position, centered 160x208 shape, world bounds Y 416 through 624, collision layer 0, collision mask 2, cyan/green presentation, Main exact-Player validation, MissionController guards, and final availability/completion states are unchanged. No timers, groups, scene searches, polling, Player dependencies, or unrelated gameplay changes were added.

## Validation performed

- Confirmed branch `main`, clean working tree, successful origin fetch, and exact required base.
- Read the extraction script, scene, Main, MissionController, active technical/context documentation, and Task 065/066 reports before editing.
- Reviewed the complete diff.
- Confirmed exactly two successive `physics_frame` awaits before the overlap query.
- Confirmed state is revalidated after both awaits and the query is not performed earlier.
- Confirmed `body_entered` and the delayed fallback converge on `_request_extraction`.
- Confirmed no scene, geometry, Main, MissionController, Player, HUD, project, collision, or UID file changed.
- Ran `git diff --check` and staged checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser, import, startup, visual, and runtime validation were not performed by Codex.

## Windows runtime checklist

1. Complete the mission through the three mercenary defeats.
2. Confirm the extraction zone activates with the corrected centered geometry.
3. Stand Player inside the future zone before the third defeat.
4. Confirm extraction completes without leaving and re-entering.
5. Confirm normal entry through `body_entered` still completes extraction.
6. Confirm duplicate entries do not repeat `MISSION COMPLETE`.
7. Confirm the zone remains non-solid, green after completion, and unavailable afterward.
8. Confirm movement, Slide, Jetpack, Knee Dash, Hook, Shield, weapons, equipment, and HUD remain intact.
9. Confirm no red Godot parser or runtime errors appear.

## Publication

Implementation commit: `e82e550ec8ae8dd2982a677c5a7bc91f7b358728` (`fix: delay extraction overlap query`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after the Task 067 documentation commit and returned in the final handoff.

Windows runtime validation remains pending.
