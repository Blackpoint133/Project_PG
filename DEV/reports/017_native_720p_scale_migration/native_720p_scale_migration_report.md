# Report: 017_native_720p_scale_migration

## Task objective

Migrate the prototype from a 640x360 logical viewport stretched to 1280x720 into true native 1280x720 presentation with a 96-pixel base player, preserving validated gameplay behavior and timing.

## Resolution and scale result

| Value | Old | New |
| --- | --- | --- |
| Logical viewport | 640x360 | 1280x720 |
| Window | 1280x720 | 1280x720 |
| Base player height | 28 pixels | 96 pixels |
| Player collision | 12x28 | 40x96 |
| Crouch collision | 12x18 | 40x64 |
| Arena width | 1280 units | 2560 units |

## Complete spatial and physics conversion table

| Item | Old | New |
| --- | --- | --- |
| RUN_SPEED | 180 | 360 |
| CROUCH_SPEED | 90 | 180 |
| GROUND_ACCELERATION | 1400 | 2800 |
| AIR_ACCELERATION | 900 | 1800 |
| GROUND_FRICTION | 1600 | 3200 |
| JUMP_VELOCITY | -420 | -840 |
| JETPACK_TARGET_RISE_VELOCITY | -240 | -480 |
| JETPACK_ACCELERATION | 2400 | 4800 |
| MAX_FALL_SPEED | 420 | 840 |
| FACING_DEAD_ZONE | 4 | 8 |
| Effective 2D gravity | ~980 | 1960 |
| Projectile speed | 900 | 1800 |
| Projectile size | 8x3 | 16x6 |
| Player spawn | (120, 300) | (240, 600) |
| Floor | 1280x48 at (640, 336) | 2560x96 at (1280, 672) |
| Platform size | 96x12 | 192x24 |
| Walls | 24x360 | 48x720 |
| Camera limits | 0/-200 to 1280/360 | 0/-400 to 2560/720 |
| Target dummy | 16x28 | 32x80 |
| Player module geometry | 28-pixel silhouette | doubled LARGE geometry: 40-wide, 96-tall |
| Shoulder pivot | Y -18 | Y -72 |
| Weapon slot offset | X 7 | X 14 |
| Weapon length | 10 | 36 |
| Muzzle offset | X 10 | X 36 |
| AimLine | X 17-33 | X 48-76 |

Unchanged time-based values: fire rate, reload duration, projectile lifetime, camera smoothing speed. Rifle damage, ammunition, collision layers, collision masks, fire cadence, reload behavior, projectile lifecycle, and target hit behavior are unchanged.

## Exact changed files

- `Game/project.godot`
- `Game/scripts/player.gd`
- `Game/scenes/main.tscn`
- `Game/scenes/arena.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/hud.tscn`
- `Game/scenes/player/modules/placeholder_body.tscn`
- `Game/scenes/player/modules/placeholder_legs.tscn`
- `Game/scenes/player/modules/placeholder_jetpack.tscn`
- `Game/scenes/player/modules/placeholder_left_arm.tscn`
- `Game/scenes/player/modules/placeholder_right_arm.tscn`
- `Game/scenes/player/modules/placeholder_weapon.tscn`
- `Game/scenes/projectiles/rifle_projectile.tscn`
- `Game/scenes/targets/target_dummy.tscn`
- `Game/resources/weapons/automatic_rifle.tres`
- `Game/scenes/dev/player_scale_comparison.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/017_native_720p_scale_migration/native_720p_scale_migration_report.md`

## Checks performed

- Confirmed branch `main`, clean working tree, and synchronized history including `215178d5deb13a3b127f3cc77215d64c6b062d28`.
- Verified scene/resource paths exist and viewport settings are native 1280x720.
- Searched active `Game` files for stale 640x360 assumptions and obsolete 28/18-pixel player assumptions.
- Verified the authoritative rifle speed is 1800 in `automatic_rifle.tres`.
- Verified `Camera2D` zoom remains unset, equivalent to `Vector2(1, 1)`.
- Verified player and target visuals/collisions remain bottom-anchored at local Y 0.
- Verified collision layer and mask values are unchanged.
- Confirmed no final artwork, executables, caches, credentials, or unrelated files are included.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Reviewed the complete Git diff before staging.
- Confirmed `Game/.godot` and `Game/.import` are not tracked.
- Godot runtime and visual validation were not performed and remain deferred to Windows.

## Pending Windows runtime checks

- Verify native window and viewport sizes.
- Verify movement, jump, jetpack, and camera feel at doubled scale.
- Verify crouching visual pose at the 96-pixel player.
- Verify rifle projectiles spawn, travel at doubled speed, and hit targets.
- Verify targets remain readable and correctly grounded.
- Verify HUD layout and text remain readable at native 720p.
- Verify the scale comparison scene marks 96 PX as selected.

## Known risks or limitations

- Placeholder geometry preserves proportions but does not represent final high-detail art.
- Crouch visual offset is approximate and may need one tuning pass after runtime inspection.
- Parallax and foreground collision layers are documented but not yet implemented.

## Confirmation

No final artwork was added. No supplied reference image was copied.

## Recommended next step

Perform the Windows runtime checklist, then plan the first high-detail environment or player-art task after gameplay timing is confirmed.
