# Task 030: Preserve Partial Magazines on Weapon Switch

## Objective

Prevent automatic reload from starting when switching to or receiving a partially spent weapon instance, while preserving empty-magazine automatic reload and manual partial-magazine reload.

## Completed changes

- Added the typed `_start_reload_if_empty()` distinction for automatic reload requests caused by slot selection or active-slot replacement.
- Preserved `_start_reload()` for manual R reload, including partially filled magazines.
- Preserved final-round automatic reload, empty-fire reload, empty-instance equip reload, reload cancellation, and zero-reserve guards.
- Updated project context documentation without changing the two-slot inventory design.
- Did not modify scenes, resources, inputs, pickups, Player, HUD, movement, physics, projectile, target, or historical reports.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/030_weapon_switch_auto_reload_fix/weapon_switch_auto_reload_fix_report.md`
- `Game/scripts/combat/weapon_controller.gd`

## Confirmed root cause

`select_slot()` and active-slot `replace_slot_instance()` called `_start_reload()` unconditionally. Because `_start_reload()` intentionally supports manual reload of partially filled magazines, those calls incorrectly began reload after a weapon switch or active-slot replacement.

## Resulting behavior and signal ordering

- Partial magazine on slot selection or active-slot replacement: ammunition is preserved and no automatic reload starts.
- Zero loaded ammo with reserve available on selection or replacement: `_start_reload_if_empty()` calls `_start_reload()` and emits `reload_started`.
- Zero loaded and zero reserve: no reload starts.
- Manual R still calls `_start_reload()` directly and reloads partial magazines.
- The final shot still emits `fired`, then `weapon_ammo_changed`, then `reload_started` when reserve ammunition is available.
- Slot switching and active-slot replacement still cancel existing reload and reset cooldown before the weapon and ammo signals.

## Checks actually performed

- Read `AGENTS.md` and the complete `godot-run-and-gun` skill.
- Confirmed the clean working tree before editing.
- Fetched origin and fast-forwarded to `db7ada7923c65c7c859abb0f721e940ba08fd9e8` before editing.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed the Task 028 final-round guard remains in `try_fire()`.
- Confirmed manual R still calls `_start_reload()` and therefore supports partial magazines.
- Confirmed slot selection and active-slot replacement call `_start_reload_if_empty()` only.
- Confirmed reload cancellation remains in both switch paths.
- Confirmed no definition-keyed ammunition dictionary exists.
- Confirmed `Game/project.godot`, all scenes, weapon resources, and UID files are untouched.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked project content.
- No Godot runtime testing was performed or claimed.

## Pending manual checks

- Run Godot 4.7.2 on Windows and confirm startup has no parser/runtime errors.
- Fire each weapon to a partial magazine, switch away and back, and verify no automatic reload starts.
- Place a partial instance into the active slot through F pickup and verify its ammo remains unchanged without reload.
- Verify zero-loaded instances with reserve reload on selection/replacement.
- Verify final-round reload, manual R partial reload, zero-reserve behavior, rifle automatic fire, shotgun semi-automatic fire, duplicate weapons, and independent ammunition.

## Known risks or limitations

Godot runtime validation was unavailable in this environment. The helper intentionally distinguishes automatic empty-instance reload from manual partial-magazine reload; final timing and HUD presentation require Windows validation.

## Recommended next step

Run the focused Windows switch/reload checklist and confirm no reload begins for partially spent instances.
