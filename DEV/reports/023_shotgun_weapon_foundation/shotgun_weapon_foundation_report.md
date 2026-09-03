# Task 023: Shotgun Weapon Foundation

## Objective

Add a data-driven shotgun as the second testable weapon while preserving automatic rifle behavior and the validated movement, crouch, facing, aiming, jetpack, projectile, and target systems.

## Completed changes

- Extended `WeaponDefinition` with typed automatic-fire, projectile-count, and complete-cone spread properties.
- Added `shotgun.tres` with the requested six-shell, eight-pellet tuning.
- Added deterministic symmetric pellet spawning from the existing Muzzle marker; each projectile is configured before entering the scene tree.
- Kept rifle fire continuous while held and made shotgun fire once per distinct LMB press.
- Added focused weapon equip/switch behavior with independent ammunition state, reload cancellation, and cooldown reset.
- Added temporary physical 1/2 weapon selection input actions.
- Updated the HUD to show the current weapon name, ammunition, and weapon-specific reload status.
- Updated project context and technical design documentation.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/023_shotgun_weapon_foundation/shotgun_weapon_foundation_report.md`
- `Game/project.godot`
- `Game/resources/weapons/shotgun.tres`
- `Game/scenes/hud.tscn`
- `Game/scripts/combat/weapon_controller.gd`
- `Game/scripts/combat/weapon_definition.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Shotgun tuning

- Display name: `SHOTGUN`
- Automatic fire: `false`
- Fire rate: `1.2`
- Magazine/reserve: `6 / 24`
- Reload time: `1.8`
- Projectile speed/lifetime: `1400.0 / 0.45`
- Damage per pellet: `8`
- Projectiles per shot: `8`
- Complete spread cone: `14.0` degrees

## Architecture decisions

- `WeaponDefinition` remains the data source for fire mode, cadence, ammo, projectile scene, pellet count, and spread.
- `WeaponController` owns current definition, firing cadence, reload state, signals, and per-definition ammunition snapshots. Player remains responsible for input and requests.
- The existing rifle projectile scene and script are reused unchanged. Player configures every pellet before adding it to the tree.
- The one-shot/automatic distinction stays in Player input routing; weapon behavior does not absorb input handling.
- Final pickup, drop, and equipment replacement systems remain deferred.

## Checks actually performed

- Read `AGENTS.md`, `godot-run-and-gun`, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Fetched origin and fast-forwarded to required commit `ae7a03da75bb629794c0770936b934e3abc524ff` before implementation.
- Confirmed the working tree was clean before implementation.
- Reviewed the complete diff and verified only Task 023 files changed.
- Ran `git diff --check`.
- Confirmed automatic rifle defaults remain unchanged.
- Confirmed Task 021 dynamic legs calls and Task 022 explicit float correction remain unchanged.
- Confirmed projectile script, projectile scene, target behavior, movement, collision, and native viewport settings were not modified.
- Confirmed typed new variables and collections, integer-safe pellet indexing, one-pellet spread handling, and configure-before-add ordering by source inspection.
- Confirmed no generated `.godot` or `.import` content, credentials, executables, or unexpected UID files are included.
- Confirmed no Cyrillic characters exist in tracked project content.

## Pending Windows runtime checks

- Run Godot 4.7.2 on Windows and confirm no warnings-as-errors parser failures.
- Confirm rifle starts equipped, fires continuously while LMB is held, and preserves its existing cadence and ammo behavior.
- Confirm 1 selects rifle and 2 selects shotgun without refilling either weapon's stored ammo.
- Confirm shotgun consumes one shell, emits one firing event, spawns eight pellets from the Muzzle, and fires only once per held-LMB interval.
- Confirm pellet spread is centered, symmetric, deterministic, and uses the 14-degree complete cone.
- Confirm reload cancellation, weapon-specific HUD text, reload naming, and both weapon cooldown resets.
- Confirm movement, crouch geometry, facing, aiming, jetpack, projectile collisions, target damage, camera, and native 1280x720 presentation remain unchanged.

## Known risks or limitations

Godot runtime and visual validation were not performed in this environment. The shotgun intentionally reuses rifle projectile visuals and behavior for this foundation. Weapon ammo snapshots are keyed by the loaded `WeaponDefinition` resource instance.

## Recommended next step

Run the pending Windows runtime checklist, then continue with the later world pickup and equipment replacement work.
