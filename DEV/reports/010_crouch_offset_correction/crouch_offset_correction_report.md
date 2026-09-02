# Report: 010_crouch_offset_correction

## Task objective

Correct the audited crouch offset sign, initialize the standing pose safely before the first physics frame, and start the temporary aim guide at the weapon muzzle without changing gameplay, facing, aim behavior, input mappings, physics, or modular scene structure.

## Root cause

Task 009 documented a downward crouch offset but implemented the opposite sign. `target_height - STAND_HEIGHT` evaluates to -10 when crouching because `target_height` is 18 and `STAND_HEIGHT` is 28. In Godot, positive Y points downward, so the `BodySlot`, `JetpackSlot`, and `AimPivot` moved upward and `AimPivot` moved from Y -18 to Y -28 instead of down to Y -8.

## Implemented corrections

- Added `upper_body_offset := STAND_HEIGHT - target_height`.
- Applied the positive offset to `BodySlot` and `JetpackSlot`.
- Set `AimPivot` to `-18.0 + upper_body_offset`.
- Kept `LegsSlot` fixed at Y 0 and `BodyRoot` at its neutral unscaled position.
- Called the focused pose method with `false` in `_ready()` after assigning the rectangle shape so the standing collision and visual positions are initialized before the first physics frame.
- Removed only the unused `body_root` onready variable; the `BodyRoot` node remains unchanged.
- Changed `AimLine` to start at `Vector2(17, 0)` and extend forward to `Vector2(33, 0)`.

## Calculated pose values

Standing:

- `target_height = 28`
- `upper_body_offset = 28 - 28 = 0`
- `BodySlot.position.y = 0`
- `JetpackSlot.position.y = 0`
- `AimPivot.position.y = -18`
- `collision_shape.position.y = -28 * 0.5 = -14`
- Collision covers Y -28 through Y 0.

Crouching:

- `target_height = 18`
- `upper_body_offset = 28 - 18 = 10`
- `BodySlot.position.y = 10`
- `JetpackSlot.position.y = 10`
- `AimPivot.position.y = -8`
- `collision_shape.position.y = -18 * 0.5 = -9`
- Collision covers Y -18 through Y 0.
- `LegsSlot.position.y = 0`.

The temporary weapon muzzle is at `AimPivot` local X 17 because `WeaponSlot` is at X 7 and `PlaceholderWeapon` extends another 10 pixels. `AimLine` now starts at X 17 and extends forward to X 33.

## Exact changed files

- `Game/scripts/player.gd`
- `Game/scenes/player.tscn`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/009_player_pose_and_facing/player_pose_and_facing_report.md`
- `DEV/reports/010_crouch_offset_correction/crouch_offset_correction_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Confirmed the starting commit included `8755d49a8580718253a150177995dbe8a2c59666`.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Confirmed standing values: `upper_body_offset = 0`, `AimPivot Y = -18`, `collision Y = -14`.
- Confirmed crouching values: `upper_body_offset = 10`, `AimPivot Y = -8`, `collision Y = -9`.
- Confirmed `LegsSlot Y` remains 0.
- Confirmed `AimLine` begins at X 17.
- Confirmed facing logic, aim calculation, input mappings, and jetpack tuning are unchanged.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Godot runtime validation was not performed.
