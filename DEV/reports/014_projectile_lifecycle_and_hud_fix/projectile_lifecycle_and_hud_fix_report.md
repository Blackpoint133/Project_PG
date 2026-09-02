# Report: 014_projectile_lifecycle_and_hud_fix

## Task objective

Correct the audited projectile initialization order and HUD ammunition cache while preserving rifle tuning, collision configuration, movement, crouching, facing, aiming, jump, and jetpack behavior.

## Root causes and corrections

### Projectile lifecycle order

The previous `_spawn_projectile()` called `add_child()` before `configure()`. Entering the scene tree immediately invokes `_ready()`, which observed `_configured == false`, disabled physics processing, and returned before configuration.

The corrected order is:

1. Instantiate and safely cast to `RifleProjectile`.
2. Validate that instantiation and casting succeeded.
3. Compute a non-zero transform-safe aim direction from the global muzzle to the global mouse.
4. Call `projectile.configure(...)` using the active `WeaponDefinition`.
5. Add the configured projectile to the world.
6. Set its global muzzle position in the same frame.

If the mouse direction has zero length, the player falls back to the muzzle global X-axis direction. `_ready()` now observes `_configured == true`, sets rotation and velocity, starts the lifetime timer, and leaves physics processing enabled.

### HUD ammunition cache

The HUD previously wrote the label on `weapon_ammo_changed` but did not update its cached values, allowing the next frame to overwrite the display with the initial 30 / 90 state.

The corrected flow is:

- Initialize once from the controller's public getters.
- `_on_ammo_changed()` updates the cached loaded and reserve values, then renders once.
- `_render_weapon_state()` is the single focused method that renders cached weapon state.
- `_process()` no longer re-renders ammunition every frame.
- `reload_started()` displays RELOADING.
- Ammunition signals received during reload still update the cache.
- `reload_completed()` exits RELOADING and renders the updated cache.

### Controller cleanup

The duplicate public `loaded_ammo` and `reserve_ammo` copies were removed. The controller now owns one authoritative private loaded/reserve state and exposes explicit public getter methods. Firing, reload, signal, and negative-ammo guards are unchanged.

## Reconfirmed unchanged values

- Weapon controller script attachment.
- Player logical layer 2: `collision_layer = 2`, `collision_mask = 1`.
- Target logical layer 3: `collision_layer = 4`, `collision_mask = 0`.
- Projectile logical layer 4: `collision_layer = 8`, `collision_mask = 5`.
- Target collision position Y -14.
- Rifle tuning.
- Movement, crouching, facing, aiming, jump, and jetpack behavior.

## Exact changed files

- `Game/scripts/player.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/combat/weapon_controller.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/014_projectile_lifecycle_and_hud_fix/projectile_lifecycle_and_hud_fix_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Reviewed commit `e1bfa6c23d15aa19737e952b094c90d2cc25cd41`.
- Confirmed from the final code that `configure()` occurs before `add_child()`.
- Confirmed `_ready()` receives a configured projectile and leaves physics enabled.
- Confirmed the HUD cache updates after every ammunition signal.
- Confirmed RELOADING cannot be overwritten by per-frame polling.
- Confirmed there is only one authoritative loaded/reserve ammunition state in the controller.
- Confirmed collision values, target position, rifle tuning, movement, crouching, facing, aiming, jump, and jetpack behavior are unchanged.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- No compatible Godot executable was available; runtime validation is deferred to Windows.

## Pending Windows manual checks

- Verify projectiles fire, rotate, move, expire, and damage targets correctly.
- Verify the HUD initially shows 30 / 90 and updates immediately after every shot.
- Verify RELOADING persists for the full 1.2-second reload.
- Verify the completed reload displays the correct transferred ammunition.
- Verify movement, crouch, jetpack, facing, aiming, camera, and platform behavior remain unchanged.

## Recommended next step

Perform the Windows combat checklist and then continue with the next approved combat or enemy task.
