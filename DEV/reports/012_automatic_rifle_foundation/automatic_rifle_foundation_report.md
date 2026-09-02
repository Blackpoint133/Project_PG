# Report: 012_automatic_rifle_foundation

## Task objective

Implement the first playable combat foundation: automatic-rifle firing, visible projectiles, ammunition, manual reloading, damage, and stationary target dummies. Movement, crouch pose, jetpack physics, facing, shoulder aiming, camera, HUD reporting, and modular visuals are preserved.

## Completed changes

- Added a data-driven `WeaponDefinition` resource and the automatic rifle tuning file.
- Added a focused `WeaponController` handling fire cadence, magazine, reserve ammunition, manual reload, and the required signals.
- Added a visible placeholder rifle projectile with transform-safe direction, lifetime, single-hit damage, and collision layers.
- Added stationary 50-health target dummies with visible hit feedback and removal from the target collision layer at zero health.
- Added the `Muzzle` Marker2D to the weapon module and routed input from the player to the weapon controller without embedding weapon logic in `player.gd`.
- Added four arena targets positioned for right-facing, upward, downward, and left-facing shots.
- Updated the HUD with weapon name, loaded/reserve ammunition, RELOADING state, and LMB/R controls.
- Added `fire` (left mouse button) and `reload` (physical R) input actions while preserving all existing mappings.

## Implemented architecture

- Weapon cadence, ammunition, reloading, and projectile behavior live in `WeaponController`.
- `player.gd` only routes fire/reload input and spawns projectiles from the muzzle marker.
- Arms and weapon remain separate placeholder scenes; weapon behavior is outside arm visuals.
- The implementation is reusable for the future shotgun through `WeaponDefinition` and the shared controller signals.

## Rifle tuning

- Fire rate: 10 rounds per second.
- Magazine: 30.
- Initial reserve: 90.
- Reload time: 1.2 seconds.
- Projectile speed: 900 px/s.
- Projectile lifetime: 1.5 seconds.
- Damage: 10.
- Spread: zero.

## Collision configuration

- Player attacks/projectiles: layer 4, mask 9 (world 1 + targets 3).
- Target dummies: layer 3 and non-blocking for player movement.
- Projectiles cannot collide with the player.
- A projectile applies damage at most once and is freed after world, target, or lifetime expiry.

## Exact created and changed files

Created:

- `Game/scripts/combat/weapon_definition.gd`
- `Game/scripts/combat/weapon_controller.gd`
- `Game/scripts/combat/rifle_projectile.gd`
- `Game/scripts/targets/target_dummy.gd`
- `Game/scenes/projectiles/rifle_projectile.tscn`
- `Game/scenes/targets/target_dummy.tscn`
- `Game/resources/weapons/automatic_rifle.tres`
- `DEV/reports/012_automatic_rifle_foundation/automatic_rifle_foundation_report.md`

Changed:

- `Game/project.godot`
- `Game/scripts/player.gd`
- `Game/scripts/hud.gd`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_weapon.tscn`
- `Game/scenes/arena.tscn`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main` before changes.
- Confirmed no unexpected local changes existed.
- Confirmed existing movement and jetpack constants were not changed.
- Confirmed projectile direction is computed from global muzzle and mouse positions, avoiding the previous horizontal inversion.
- Confirmed ammunition cannot become negative through clamped damage, magazine transfer, and fire guards.
- Confirmed reload transfers only the needed ammunition.
- Confirmed one projectile cannot damage a target more than once through `_has_dealt_damage`.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- No compatible Godot executable was available for headless validation; runtime checks are deferred to Windows.

## Pending Windows manual checks

- Hold LMB and verify 10-round-per-second automatic fire.
- Verify empty magazine cannot fire and R triggers the 1.2-second reload.
- Verify the HUD shows RELOADING during reload and the correct loaded/reserve values otherwise.
- Verify projectiles spawn at the muzzle and follow aim in every quadrant.
- Verify firing while standing, crouching, jumping, falling, and jetpacking.
- Verify targets flash on hit and disappear after 50 damage.
- Verify left-facing, right-facing, upward, and downward shots.
- Verify movement, crouch pose, jetpack, camera, and platform behavior remain unchanged.

## Risks or limitations

- Placeholder projectile and target visuals are temporary.
- Target dummies do not yet share a formal enemy base class.
- No audio, recoil, shell casings, equipment swapping, or enemies are included by scope.

## Recommended next step

Perform the Windows combat checklist, then plan the next combat task such as basic enemies or the shotgun while reusing `WeaponDefinition` and the projectile damage API.
