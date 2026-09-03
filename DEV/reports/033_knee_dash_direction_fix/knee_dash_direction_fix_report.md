# Task 033: Knee-Dash Direction Fix

## Objective

Correct left-side Knee-Dash direction mirroring and center the debug visual on its existing attack hitbox without changing gameplay tuning or other systems.

## Completed changes

- Reconstructed the dash vector explicitly from the clamped angle and selected horizontal side, preserving the vertical component when moving left.
- Centered the existing debug visual on the existing 64x28 hitbox.
- Preserved the existing facing selection, `atan2` calculation, 60-degree clamp, normalization, hitbox, cooldown, damage, and movement behavior.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/033_knee_dash_direction_fix/knee_dash_direction_fix_report.md`
- `Game/scenes/player.tscn`
- `Game/scripts/player.gd`

## Confirmed mathematical root cause

Rotating `Vector2(-1, 0)` by an angle produces `(-cos(angle), -sin(angle))`, which reverses the vertical component for left-side dashes. The corrected construction uses `x = cos(angle) * horizontal_side` and `y = sin(angle)`, so horizontal mirroring changes only X.

## Direction validation

With `desired_angle = atan2(mouse_offset.y, absf(mouse_offset.x))`, the explicit vector is normalized after construction:

- Right/up: `horizontal_side = 1`, negative angle produces positive X and negative Y.
- Left/up: `horizontal_side = -1`, negative angle produces negative X and negative Y.
- Right/down: `horizontal_side = 1`, positive angle produces positive X and positive Y.
- Left/down: `horizontal_side = -1`, positive angle produces negative X and positive Y.
- Direct above: the current facing side is retained and the negative angle clamps to 60 degrees, producing up-right when facing right and up-left when facing left.
- Direct below: the current facing side is retained and the positive angle clamps to 60 degrees, producing down-right when facing right and down-left when facing left.

The X sign always matches `horizontal_side`; for non-origin aim, the Y sign matches the mouse vertical side. The authored angle is clamped to `[-60, 60]`, so the absolute angle from horizontal never exceeds 60 degrees. Origin aim leaves `desired_angle` at zero and therefore remains horizontal in the current facing direction.

## Debug visual alignment

The `DebugVisual` now uses offsets `-32, -14, 32, 14`, giving it the same centered 64x28 bounds as the unchanged `RectangleShape2D`. Its position and rotation remain shared with the hitbox controller.

## Checks actually performed

- Confirmed the required base commit and clean preflight state.
- Reviewed the complete diff.
- Ran `git diff --check`.
- Confirmed `Game/project.godot` and all unrelated gameplay files are untouched.
- Confirmed the hitbox remains 64x28 with its existing position, rotation, mask, and behavior.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked content.
- No Godot runtime or visual test was performed or claimed.

## Pending manual checks

Windows runtime validation remains pending: visually test all six directional cases, direct vertical aim while facing both directions, origin aim, and debug visual alignment during an active dash.

## Known risks or limitations

This is a static direction and debug-visual correction. Runtime collision behavior and visual presentation still require validation in Godot 4.7.2 on Windows.

## Recommended next step

Run the focused Windows Knee-Dash direction checklist and confirm left/right diagonal signs and centered debug hitbox presentation.
