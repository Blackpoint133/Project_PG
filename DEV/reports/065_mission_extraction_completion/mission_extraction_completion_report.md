# Task 065: Mission Extraction Completion

## Objective

Add a reusable physical extraction zone at the far-right end of Main. It becomes available only after the three exact Task 064 mercenaries are defeated and completes the first mission flow when the exact Main Player enters it.

## Audited base

Required base: `27952b685d959d71f03a452ffd6d37759be6f930`.

## Exact changed files

Implementation:

- `Game/scripts/interactables/mission_extraction_zone.gd`
- `Game/scenes/interactables/mission_extraction_zone.tscn`
- `Game/scripts/main.gd`
- `Game/scenes/main.tscn`
- `Game/scripts/missions/mission_controller.gd`

Documentation:

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/065_mission_extraction_completion/mission_extraction_completion_report.md`

## Extraction architecture

MissionExtractionZone is a reusable Area2D that owns only local presentation, monitoring, activation, completion, and the typed `extraction_requested(actor)` signal. It does not search for Main, Player, MissionController, groups, or siblings, and it does not implement F interaction.

MissionController keeps the existing helicopter `MissionState.COMPLETED` boundary and owns guarded extraction availability/completion latches, objective text, and typed availability/completion signals. Main owns the exact zone reference, signal connections, activation, exact Player validation, and forwarding.

## Collision and overlap contract

The zone uses collision layer 0 and collision mask 2, detecting the Player body without becoming solid or interactable. It has no interactable layer and cannot be selected by InteractionController. Monitoring is enabled and disabled with deferred property changes. A deferred overlap check calls the same request boundary after activation, so a Player already inside the zone is handled without requiring re-entry.

The zone is authored at `Vector2(2440, 520)` with a `Vector2(160, 208)` rectangle offset down by 104 pixels, covering the intended area through ground level Y 624. Its cyan field, outline, beacon, and `EXTRACTION` label remain hidden before activation; successful completion changes the presentation to restrained green `COMPLETE` while leaving the zone visible.

## Mission guards and signals

`make_extraction_available(mission_id)` succeeds only for the completed `destroy_helicopter` mission after encounter start and all three unique mercenary defeats. It emits `extraction_available` once and preserves `REACH THE EXTRACTION`.

`complete_extraction(mission_id)` succeeds only after availability, matching mission, completed encounter, and before completion. It changes the objective exactly once to `MISSION COMPLETE` and emits `extraction_completed` once. Duplicate, early, mismatched, and unrelated requests are rejected. The historical `mission_completed` signal is not emitted again.

## Main wiring

Main connects `MissionController.mercenary_encounter_completed` and requests extraction availability only for `destroy_helicopter`; on acceptance it activates the exact Main zone. Main connects `extraction_requested`, accepts only the exact `World/Player` reference, requests MissionController completion, and calls zone completion only after the mission request succeeds.

## Preserved and deferred behavior

Player, HUD, MissionMercenary, TargetDummy, weapons, projectiles, equipment, pickups, radio, helicopter, loot case, InteractionController, arena geometry, project settings, input mappings, and existing UID files are unchanged. Movement, crouch, Slide, Jetpack, Knee Dash, Bleeding, Shield, Hook, collisions, and the complete pre-extraction mission sequence are preserved.

No extraction interaction prompt, combat encounter, level transition, menu, restart behavior, reward, cutscene, or final artwork was added.

## Validation performed

- Confirmed the clean synchronized required base before editing.
- Reviewed the complete implementation and documentation diff.
- Confirmed hidden/unavailable pre-encounter zone state, layer 0/mask 2, non-solid behavior, and no InteractionController contract.
- Confirmed exact Main Player identity validation and deferred monitoring/overlap handling.
- Confirmed extraction availability is gated by the exact completed encounter and completion is one-shot.
- Confirmed objective transition ends at `MISSION COMPLETE` without another `mission_completed` signal.
- Confirmed no existing gameplay systems or UID files changed.
- Ran `git diff --check` and staged diff checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser, startup, visual, and runtime validation were not performed by Codex.

## Known limitations

The extraction zone only completes the first mission flow. It does not transition levels, display menus, restart the run, or implement final mission presentation.

## Windows runtime checklist

1. Start Main and confirm the zone is hidden before the encounter.
2. Walk through its future position early and confirm nothing happens.
3. Complete radio, helicopter, loot-case, reward, and mercenary defeat flow.
4. Confirm the third defeat produces `REACH THE EXTRACTION`.
5. Confirm the cyan field appears at the far-right position.
6. Enter it with Player and confirm `MISSION COMPLETE`.
7. Confirm the field changes to green `COMPLETE`.
8. Leave and re-enter; confirm completion does not repeat.
9. Test completion while Player is already inside when the third defeat occurs.
10. Confirm the zone never blocks movement and has no F prompt.
11. Verify all existing combat, equipment, mission, and HUD behavior.
12. Confirm no red Godot parser or runtime errors appear.

## Publication results

Implementation commit: `844ed35e434bcd61f6c4a7fd1895d9055640b275` (`feat: add mission extraction completion`), pushed successfully to `origin/main`.

Documentation commit: the publication commit; its exact SHA is returned in the handoff.

Godot runtime validation remains pending.
