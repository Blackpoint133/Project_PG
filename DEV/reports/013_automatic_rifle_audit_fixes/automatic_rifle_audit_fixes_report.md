# Report: 013_automatic_rifle_audit_fixes

## Task objective

Repair the audited automatic-rifle integration while preserving rifle tuning, movement, jetpack physics, crouch pose, facing, aiming, muzzle location, input mappings, and modular visual scenes.

## Root causes and corrections

1. `WeaponController` existed only as a bare node in `player.tscn`. Its script is now attached and the typed `Player.weapon_controller` reference and setup call are valid.
2. Collision masks used logical layer numbers instead of integer bit values. The corrected logical configuration is documented below. The player is now on logical layer 2 with mask 1, so projectiles targeting world and targets cannot collide with the player.
3. Projectile speed, damage, and lifetime were duplicated as script defaults rather than driven by the active definition. `RifleProjectile` now has a typed `configure()` API called before `add_child`, and `_ready()` uses only configured values. The muzzle-to-mouse global direction flow is unchanged.
4. The target collision shape was centered at Y 0 while its visual covered Y -28 through Y 0. The shape is now centered at Y -14, matching the visible bounds exactly. Targets remain non-blocking.
5. The HUD read private underscore-prefixed controller fields every frame. It now initializes from public read-only `loaded_ammo` and `reserve_ammo`, caches updates through `weapon_ammo_changed`, and preserves the RELOADING presentation.
6. Projectile instantiation is statically typed as `RifleProjectile`, and its `_ready()` explicitly guards against unconfigured use for Godot 4.7.2 parse/runtime safety.

## Corrected scene/script wiring

- `player.tscn` now attaches `res://scripts/combat/weapon_controller.gd` to the `WeaponController` node.
- `Player` uses logical layer 2 and mask 1.
- `RifleProjectile` uses logical layer 4 and mask 5.
- `TargetDummy` uses logical layer 3 and mask 0, with collision centered at Y -14.
- Projectile configuration comes from the active `WeaponDefinition` at spawn time.

## Logical collision layers and integer values

| Logical layer | Integer value | Use |
| --- | --- | --- |
| 1 | 1 | World |
| 2 | 2 | Player body, mask 1 |
| 3 | 4 | Target/enemy body, mask 0 |
| 4 | 8 | Player projectile, mask 5 |

Projectile mask 5 detects logical layers 1 and 3 and cannot detect logical layer 2.

## Projectile configuration flow

`WeaponController.try_fire()` emits `fired`. The player instantiates a `RifleProjectile`, sets its global position from the `Muzzle` marker, computes the global muzzle-to-mouse direction, then calls `configure(direction, projectile_speed, damage, projectile_lifetime)` from the active `WeaponDefinition` before the node enters the tree.

## Exact changed files

- `Game/scenes/player.tscn`
- `Game/scenes/projectiles/rifle_projectile.tscn`
- `Game/scenes/targets/target_dummy.tscn`
- `Game/scripts/combat/rifle_projectile.gd`
- `Game/scripts/combat/weapon_controller.gd`
- `Game/scripts/player.gd`
- `Game/scripts/hud.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/013_automatic_rifle_audit_fixes/automatic_rifle_audit_fixes_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Reviewed commit `3f37c66306e61d2309aaa3546ec798189b4b3dd3`.
- Confirmed the weapon controller script is attached in `player.tscn`.
- Confirmed the exact logical layers and integer bit values in the scenes.
- Confirmed projectile configuration comes from `WeaponDefinition`.
- Confirmed target visual and collision bounds now match.
- Confirmed the HUD uses public state and caches signal updates rather than reading private fields.
- Confirmed ammunition guards and reload transfer still prevent negative values.
- Confirmed the projectile damage flag prevents multiple hits.
- Confirmed rifle tuning, movement and jetpack constants, crouch pose, facing, aiming, muzzle location, and input mappings are unchanged.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- No compatible Godot executable was available; runtime validation is deferred to Windows.

## Pending Windows manual checks

- Verify the project parses and starts without script or scene errors.
- Verify holding LMB fires automatically at the approved cadence.
- Verify projectiles hit targets on all visible target areas.
- Verify projectiles pass through the player and collide with world and targets.
- Verify reload and HUD state remain correct.
- Verify movement, crouch pose, jetpack, facing, aiming, camera, and platforms are unchanged.
