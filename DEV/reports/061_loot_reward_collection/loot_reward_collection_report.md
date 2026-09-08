# Task 061: Loot Reward Collection Tracking

## Objective

Track successful collection of the four exact pickup nodes ejected by the helicopter loot case and complete the equipment reward objective after all four are transferred to Player.

## Completed changes

- Added one-shot `pickup_completed(actor)` signals to the four existing pickup classes.
- Changed the four Player swap methods to return a typed success boolean while preserving exact-instance swap behavior.
- Main retains and connects only the four pickup nodes created by the Task 060 loot-case reward spawn.
- MissionController tracks stable reward IDs, reports progress, and changes the objective to `EQUIPMENT COLLECTED` after all four successful transfers.
- Updated the active design documentation.

## Exact changed file list

- `Game/scripts/equipment/world_weapon_pickup.gd`
- `Game/scripts/equipment/world_left_arm_pickup.gd`
- `Game/scripts/equipment/world_right_arm_pickup.gd`
- `Game/scripts/equipment/world_leg_pickup.gd`
- `Game/scripts/player.gd`
- `Game/scripts/main.gd`
- `Game/scripts/missions/mission_controller.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/061_loot_reward_collection/loot_reward_collection_report.md`

## Identity and ownership contract

Main retains typed references to the exact Shotgun, Shield Left Arm, Hook Right Arm, and Knee-Dash Legs pickup nodes created during loot-case opening. It connects their completion signals before they enter `World`. Unrelated arena pickups are never connected and cannot advance mission progress.

Each pickup emits completion only after its existing dynamic interaction call returns a boolean `true`. A one-shot latch remains set if the pickup node is reused to hold the outgoing item after an equipment replacement, so the same physical node cannot report collection twice. The queued-for-deletion Shotgun pickup emits before deletion completes.

The Player swap methods return `false` for invalid or rejected transfers and `true` only after the incoming exact instance is installed in Player ownership. Existing ammunition, equipment runtime state, dropped outgoing instances, launch behavior, and interaction prompt refresh are preserved.

## Mission progress

MissionController accepts only the four stable IDs: `shotgun`, `shield_left_arm`, `hook_right_arm`, and `knee_dash_legs`. It rejects duplicates, unknown IDs, early calls, and mismatched mission state. Progress is shown as `COLLECT THE EQUIPMENT (N/4)`, and the fourth successful transfer changes the objective to `EQUIPMENT COLLECTED` exactly once.

## Checks actually performed

- Confirmed the required clean base commit and `main` branch before editing.
- Reviewed the complete implementation diff and exact changed-file scope.
- Confirmed pickup signals are emitted only after a successful typed transfer result.
- Confirmed Main connects only the four exact reward instances and validates the actor against the typed Main Player reference.
- Confirmed no scenes, resources, HUD, project settings, InteractionController, or UID files changed.
- Ran `git diff --check` and the staged diff checks.
- Ran the repository Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available in this environment. Godot parser, import, startup, runtime, and visual validation were not performed by Codex. The prior Task 060 runtime result is user-confirmed, not Codex-performed.

## Known risks or limitations

The mission objective remains in its completed reward state after all four transfers; final combat, extraction, and reward-end state are outside this task. Pickup signal signatures cross the existing dynamic actor boundary and are guarded by explicit `Variant` type checks.

## Pending Windows runtime checklist

1. Open the landed case and verify only its four exact reward nodes advance progress.
2. Collect each reward and verify progress reaches `(4/4)` before `EQUIPMENT COLLECTED`.
3. Re-equip an outgoing item from a replacement pickup and confirm it does not count twice.
4. Confirm unrelated arena pickups do not change mission progress.
5. Confirm the queued-for-deletion Shotgun reward counts once.
6. Verify normal weapon ammunition, arm charge/cooldown, Hook cooldown, and Knee-Dash cooldown survive transfers.
7. Confirm no red Godot parser or runtime errors appear.

## Recommended next step

Run the focused Windows collection checklist, then implement the next mission stage for the final reward or extraction flow.

## Publication results

Implementation commit: `102e1f9553ad6e0807eb1111909494d79fa525f1` (`feat: track loot reward collection`), pushed successfully to `origin/main`.

Documentation commit: pending until publication.

Implementation push result: successful. Documentation push result and final HEAD/origin equality: pending until publication.
