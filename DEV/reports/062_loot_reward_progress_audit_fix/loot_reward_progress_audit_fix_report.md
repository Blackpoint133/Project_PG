# Task 062: Loot Reward Progress Contract Audit Fix

## Objective

Correct the Task 061 mission progress presentation and typed registration boundary without changing successful pickup, exact-instance equipment transfer, reward identity, or gameplay behavior.

## Audited base

Required base: `eeb760844419be6261e1268df46d6fdbf78ce213`.

## Findings and root causes

- Valid case opening displayed plain `COLLECT THE EQUIPMENT` instead of the required zero-progress state.
- Reward IDs and reward signal parameters used `String` rather than typed `StringName`.
- Main forwarded only a reward id, so the mission boundary did not explicitly validate `destroy_helicopter`.
- The Task 061 report incorrectly described a visible `(4/4)` state before completion.

## Exact changed files

- `Game/scripts/missions/mission_controller.gd`
- `Game/scripts/main.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/061_loot_reward_collection/loot_reward_collection_report.md`
- `DEV/reports/062_loot_reward_progress_audit_fix/loot_reward_progress_audit_fix_report.md`

## Corrected contract

MissionController now declares all four accepted reward IDs as typed `StringName` constants and exposes:

```gdscript
func register_reward_collected(mission_id: String, reward_id: StringName) -> bool
```

Registration succeeds only for the completed `destroy_helicopter` mission after the loot case has opened, for a valid reward not previously recorded and before reward completion. It rejects unknown, duplicate, early, mismatched, and post-completion requests without changing state. Progress remains monotonic and capped at four; completion emits once and never emits `mission_completed` again.

Main passes both `MissionController.DESTROY_HELICOPTER_ID` and the exact typed reward ID from the four connected case-created pickup nodes.

## Objective sequence

- Case opened: `COLLECT THE EQUIPMENT (0/4)`.
- First three unique exact rewards: `COLLECT THE EQUIPMENT (1/4)`, `(2/4)`, `(3/4)`.
- Fourth unique reward: `EQUIPMENT COLLECTED` directly, with no visible `(4/4)` state.

## Preserved behavior

Pickup signals, Player bool-return swap methods, exact-node identity ownership, duplicate protection, equipment state, weapon ammunition, reward ejection, case opening, HUD API/layout, and all movement/combat/ability systems are unchanged.

## Validation

- Confirmed clean `main` base and origin synchronization before editing.
- Reviewed the complete diff and exact six-file changed scope.
- Confirmed all reward IDs, helpers, and reward signal parameters use `StringName`.
- Confirmed Main supplies the matching mission id.
- Confirmed no `(4/4)` objective path exists.
- Confirmed initial `(0/4)` and direct fourth-reward completion.
- Ran `git diff --check` and staged checks for both commits.
- Ran the tracked-project Cyrillic scan excluding `.git`.
- Confirmed no scene, resource, HUD, project, input, collision, combat, movement, ability, pickup, Player, or UID file changed.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser, import, startup, runtime, and visual checks were not performed.

## Known limitations

Final extraction, enemy encounter, save/load, and reward-end mission flow remain deferred. The objective remains a post-combat reward boundary while MissionState remains `COMPLETED`.

## Windows checklist

1. Open a new run and activate the radio, helicopter, and loot case.
2. Confirm opening shows `COLLECT THE EQUIPMENT (0/4)`.
3. Collect the four exact case rewards in arbitrary order and verify `(1/4)`, `(2/4)`, `(3/4)`, then `EQUIPMENT COLLECTED`.
4. Verify unrelated identical pickups do not change progress.
5. Re-equip dropped outgoing items and confirm progress is not incremented again.
6. Verify failed interactions and duplicate attempts are harmless.
7. Confirm no `(4/4)` intermediate state or repeated completion appears.
8. Verify all existing movement, combat, equipment, ability, collision, and HUD behavior.
9. Confirm no red Godot errors appear.

## Publication

Implementation commit: `cfb6d4b02fc6f60008b4d400122c419d93e5efad` (`fix: correct loot reward progress contract`), pushed successfully to `origin/main`.

Documentation commit: this documentation publication commit; its exact SHA is returned in the handoff.

Windows runtime validation remains pending.
