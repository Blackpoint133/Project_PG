# Task 034: Knee-Dash Hitbox Transform Fix

## Objective

Attach the Knee-Dash hitbox and debug visual to the player's 2D transform hierarchy and reduce the maximum dash angle from 60 degrees to the approved 45-degree limit.

## Completed changes

- Changed `KneeDashController` from `Node` to `Node2D` in both the script and player scene.
- Kept the controller as a direct `Player` child at local origin, with `Hitbox` and `DebugVisual` as its children.
- Preserved the existing hitbox position, centered 64x28 geometry, collision layer, collision mask, monitoring behavior, and shared position/rotation update.
- Changed the authored and safety maximum aim angle to 45 degrees.
- Updated the active design documentation to describe the 45-degree contract.

## Confirmed transform root cause

The controller was a plain `Node`, so it did not propagate the player's 2D transform to its `Area2D` and `ColorRect` children. Those CanvasItem children therefore operated near the canvas origin instead of following the moving player. Making the controller a direct-child `Node2D` restores inherited translation without a per-frame global-position workaround or reparenting into a visual socket.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/034_knee_dash_hitbox_transform_fix/knee_dash_hitbox_transform_fix_report.md`
- `Game/resources/equipment/knee_dash_ability.tres`
- `Game/scenes/player.tscn`
- `Game/scripts/abilities/knee_dash_controller.gd`
- `Game/scripts/equipment/leg_ability_definition.gd`
- `Game/scripts/player.gd`

## 45-degree tuning and direction contract

The default definition, authored resource, and Player safety cap now use 45 degrees. Task 033's explicit reconstruction remains unchanged:

```gdscript
Vector2(cos(desired_angle) * float(horizontal_side), sin(desired_angle))
```

Right/up produces positive X and negative Y; left/up produces negative X and negative Y; right/down produces positive X and positive Y; left/down produces negative X and positive Y. Near-vertical aim still uses current facing for the horizontal side, and direct above/below produces a 45-degree diagonal. The signed angle clamp guarantees the absolute angle never exceeds 45 degrees.

## Checks actually performed

- Confirmed the required base commit and clean preflight state.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed the controller script extends `Node2D` and the scene node is a direct `Player` child at local origin.
- Confirmed `Hitbox` and `DebugVisual` remain controller children; the debug visual remains centered at `-32/-14` to `32/14`.
- Confirmed the hitbox remains 64x28, layer 0, mask 4, with unchanged controller-driven position and rotation.
- Confirmed no manual global transform synchronization was added.
- Confirmed cooldown, movement priority, damage, knockback, once-per-target tracking, HUD, equipment transfer, and weapons were untouched.
- Confirmed `Game/project.godot` and UID files were untouched.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked content.
- No Godot runtime or visual test was performed or claimed.

## Pending manual checks

Windows runtime validation remains pending: verify the debug rectangle follows the player, appears in front along the dash direction, detects targets, applies 25 damage once per activation, and produces visible knockback. Verify direct vertical aim produces 45-degree diagonals in both facing directions.

## Known risks or limitations

Runtime collision detection and visual placement still require validation in Godot 4.7.2 on Windows. This task intentionally does not change hitbox reach, damage, knockback, or player-target collision behavior.

## Recommended next step

Run the focused Windows Knee-Dash hitbox checklist against a 50-health target and verify the second dash disables it.
