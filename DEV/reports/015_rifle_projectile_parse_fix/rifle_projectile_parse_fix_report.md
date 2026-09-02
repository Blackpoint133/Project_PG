# Report: 015_rifle_projectile_parse_fix

## Task objective

Fix the remaining rifle projectile parse blocker, protect the RELOADING HUD state, and safely free a failed projectile cast while preserving configuration order, collision, tuning, and gameplay behavior.

## Parse blocker

`RifleProjectile` extends `Area2D`, but the script assigned and read `velocity` without declaring it. `Area2D` does not provide the `CharacterBody2D` velocity property, so the identifier was undeclared and blocked parsing.

The correction adds one explicit `Vector2` movement-velocity field:

```gdscript
var _movement_velocity := Vector2.ZERO
```

`_ready()` now sets `_movement_velocity = direction * speed` after confirming configuration, and `_physics_process()` advances position with that declared field. Rotation, speed, lifetime, damage, collision, configuration guard, and single-hit behavior are unchanged.

## HUD reload protection

`_on_ammo_changed()` still always updates the cached loaded and reserve values, but it calls `_render_weapon_state()` only while `_is_reloading` is false. During reload, ammunition signals cannot replace the RELOADING label. `_on_reload_completed()` clears the flag and renders the cached post-reload ammunition.

## Failed projectile cast safety

If the instantiated scene cannot be cast to `RifleProjectile`, the unattached `spawned_node` is freed before returning after the existing error message. This prevents an invalid node leak.

## Reconfirmed values

- `projectile.configure()` occurs before `add_child()`.
- `_ready()` observes `_configured == true`.
- `WeaponController` has one authoritative loaded/reserve state and public getters.
- Collision layers and masks are unchanged: player 2/1, target 4/0, projectile 8/5.
- Movement, crouch, jump, jetpack, aiming, rifle tuning, resolution, and camera are unchanged.

## Exact changed files

- `Game/scripts/combat/rifle_projectile.gd`
- `Game/scripts/player.gd`
- `Game/scripts/hud.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/015_rifle_projectile_parse_fix/rifle_projectile_parse_fix_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Reviewed commit `b8f4a68fc06f40d36969d8316e043534eaa56e31`.
- Audited every identifier used by `RifleProjectile` against its declared fields and `Area2D` API.
- Confirmed the undeclared `velocity` identifier no longer remains.
- Confirmed `_movement_velocity` is declared, set after configuration, and used only for movement.
- Confirmed RELOADING cannot be replaced by an ammo signal while reloading.
- Confirmed the failed cast frees the unattached node.
- Confirmed configuration order and one authoritative ammunition state remain valid.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- No compatible Godot executable was available; runtime validation is deferred to Windows.

## Pending Windows manual checks

- Confirm the project parses and starts without projectile script errors.
- Confirm projectiles move at 900 px/s, rotate with aim, expire after 1.5 seconds, and damage targets once.
- Confirm holding reload suppresses HUD ammunition updates and RELOADING remains visible.
- Confirm the post-reload count renders immediately when reloading completes.
- Confirm movement, crouch, jetpack, facing, aiming, camera, and platform behavior remain unchanged.

## Recommended next step

Perform the Windows runtime checklist and continue with the next approved combat task.
