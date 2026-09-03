# Task 028: Automatic Reload Regression Fix

## Objective

Prevent automatic reload from interrupting a partially empty weapon magazine after every successful shot, and clarify the approved two-slot physical weapon ownership contract for Task 029.

## Completed changes

- Restricted the post-shot automatic reload request to the shot that reduces loaded ammunition to zero.
- Preserved reload-on-fire for an already empty weapon when reserve ammunition is available.
- Preserved automatic reload when equipping a stored empty weapon with reserve ammunition.
- Preserved manual R reload for partially empty magazines, reload cancellation on weapon switching, reload signals, and zero-reserve guards.
- Updated design documentation to describe the planned two-slot physical inventory without implementing it.
- Did not restore the removed weapon_1/weapon_2 inputs or alter any other gameplay system.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/028_auto_reload_regression_fix/auto_reload_regression_fix_report.md`
- `Game/scripts/combat/weapon_controller.gd`

## Signal ordering

For the shot that empties a magazine, `fired` is emitted first, followed by `weapon_ammo_changed`, then `reload_started` when reserve ammunition is available. A successful shot leaving ammunition loaded emits no automatic reload signal. Empty-fire requests and empty stored-weapon equips start reload only when the existing guards allow it.

## Design contract clarification

The intended Task 029 inventory has two physical weapon slots: slot 1 starts with the automatic rifle, slot 2 starts empty, and keys 1 and 2 select occupied slots only. A pickup fills an empty slot first; when both slots are occupied it replaces the active slot and drops that exact weapon instance. Duplicate definitions, including two shotguns, are allowed and must retain independent loaded and reserve ammunition. Task 028 documents this boundary only.

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Fetched origin and fast-forwarded to `2176849b880ee0e512768af95575427ca119b1d7` before editing.
- Confirmed the working tree was clean before implementation.
- Reviewed the complete Task 028 diff.
- Ran `git diff --check`.
- Confirmed the only gameplay code change is the zero-ammo guard in `WeaponController.try_fire()`.
- Confirmed rifle and shotgun resource tuning remain unchanged.
- Confirmed no player, HUD, project settings, pickup, visual, physics, interaction, movement, or UID files changed.
- Confirmed no new scripts, scenes, resources, UID files, generated Godot content, credentials, executables, or unrelated files were added.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked project content.
- No Godot runtime validation was performed or claimed.

## Pending manual checks

- Run Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Hold LMB with the rifle and verify it fires at its existing cadence until the magazine reaches zero.
- Verify only the final rifle shot starts automatic reload, with signal/UI order intact.
- Verify shotgun cadence remains semi-automatic and manual R still reloads a partially empty magazine.
- Verify empty-fire reload, empty-equipped-weapon reload, switch cancellation, and no-reserve behavior.
- Validate the planned two-slot contract when Task 029 is implemented.

## Known risks or limitations

Godot runtime validation was not available in this environment. The two-slot inventory remains a documented future contract; the current single-active implementation is unchanged.

## Recommended next step

Run the Windows automatic-reload checklist, then implement the two physical weapon slots and per-instance ammunition ownership in Task 029.
