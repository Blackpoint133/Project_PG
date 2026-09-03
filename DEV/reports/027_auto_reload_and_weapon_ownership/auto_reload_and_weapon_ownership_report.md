# Task 027: Automatic Reload and Physical Weapon Ownership

## Objective

Automatically reload empty weapons when reserve ammunition is available and enforce physical single-weapon ownership through the existing F pickup and swap flow.

## Completed changes

- Added automatic reload after a successful shot empties the magazine.
- Added reload-on-fire for an already empty weapon with reserve ammunition.
- Added automatic reload when equipping a previously used weapon with zero loaded ammunition and available reserve.
- Preserved manual R reload, reload cancellation on switching, reload signals, and HUD behavior.
- Removed `weapon_1`/`weapon_2` input handling, actions, and HUD hints.
- Removed the unused `SHOTGUN` preload while keeping the automatic rifle as the starting weapon.
- Preserved physical F pickup swapping, dropped weapon behavior, per-definition ammunition snapshots, and all validated movement/combat systems.
- Updated game, technical, and project context documentation.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/027_auto_reload_and_weapon_ownership/auto_reload_and_weapon_ownership_report.md`
- `Game/project.godot`
- `Game/scenes/hud.tscn`
- `Game/scripts/combat/weapon_controller.gd`
- `Game/scripts/player.gd`

## Behavior and signal ordering

- A fire request on an empty weapon first attempts `_start_reload()` and emits `reload_started` only when reserve ammunition and magazine capacity permit it.
- A successful shot decrements loaded ammunition, emits `fired`, emits `weapon_ammo_changed`, then starts automatic reload when the magazine reaches zero.
- Weapon switching stores the current ammo snapshot, cancels any reload, resets cooldown, emits `weapon_changed`, emits the new ammo state, and starts reload only when the newly equipped state is empty with reserve remaining.
- Automatic rifles continue firing while LMB is held after reload completion. Shotguns continue to require a distinct LMB press.
- No reload starts when reserve ammunition is zero, preventing reload loops.

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Fetched origin and fast-forwarded to `ac1334a47416ffd2cabad6fe48c97e6cb2de38ee` before implementation.
- Confirmed the working tree was clean before implementation.
- Reviewed the complete diff.
- Ran `git diff --check`.
- Confirmed `weapon_1` and `weapon_2` are absent from active project configuration, player code, HUD scene, and current documentation.
- Confirmed the automatic rifle remains the initial equipped weapon and physical F pickup remains the weapon acquisition path.
- Confirmed shotgun/rifle tuning, projectile behavior, target behavior, movement, crouch, facing, aim, jetpack, camera, collision, and native viewport settings remain preserved.
- Confirmed no new scripts, scenes, UID files, generated Godot content, credentials, executables, caches, historical reports, or unrelated files are included.
- Confirmed no Cyrillic characters exist in tracked project content.
- No Godot runtime validation was performed or claimed.

## Pending Windows runtime checks

- Run Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Fire the rifle until empty and verify automatic reload, then confirm held LMB resumes firing after completion.
- Switch to shotgun through physical F pickup, empty it, and verify automatic reload does not fire another shell while LMB remains held.
- Confirm manual R reload and reload cancellation when swapping via F.
- Confirm no reload occurs or loops when reserve ammunition is zero.
- Verify dropped weapon pickup, one equipped weapon at a time, preserved rifle/shotgun ammunition, labels, prompts, and dynamic visuals.
- Confirm 1/2 no longer switch weapons and no longer appear in HUD controls.
- Recheck movement, crouch, facing, aiming, jetpack, camera, projectile collisions, target damage, and native 1280x720 presentation.

## Known risks or limitations

Godot runtime validation was not performed in this environment. WeaponController retains per-definition ammo snapshots for preservation, but these snapshots are not inventory slots; physical pickups remain the ownership mechanism.

## Recommended next step

Run the Windows reload and physical ownership checklist, then implement the next approved equipment pickup type without reintroducing debug weapon ownership paths.
