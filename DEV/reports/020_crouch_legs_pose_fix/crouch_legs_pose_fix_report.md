# Task 020: Crouch Legs Pose Fix

## Objective

Correct the modular placeholder crouch pose so the lowered upper body meets the crouching legs without overlap or a gap, while preserving the standing silhouette, collision height, feet baseline, facing, and replaceable equipment architecture.

## Completed changes

- Changed the visual crouch offset to the required 32 pixels for the body, aim pivot, and jetpack.
- Added explicit integer-authored standing and crouching visuals to the replaceable placeholder legs module.
- Kept the standing legs at `Y -56..0` with height 56 and the crouching legs at `Y -24..0` with height 24.
- Added a small legs-module `set_crouching()` interface. The player discovers the module through the legs slot and does not depend on PlaceholderLegs internal child names.
- Corrected the obsolete project context statement: the project renders natively at 1280x720, with no 640x360 internal resolution.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/020_crouch_legs_pose_fix/crouch_legs_pose_fix_report.md`
- `Game/scenes/player/modules/placeholder_legs.tscn`
- `Game/scripts/player.gd`
- `Game/scripts/player/modules/placeholder_legs.gd`

## Checks actually performed

- Read `AGENTS.md`, `DEV/docs/GAME_DESIGN.md`, and `DEV/docs/TECHNICAL_DESIGN.md`.
- Inspected the player scene, player script, body module, and legs module.
- Confirmed the working tree was clean before changes.
- Fetched `origin`; `HEAD` was already synchronized with `origin/main` (`0 0` ahead/behind), so no pull was required.
- Reviewed the complete task diff.
- Ran `git diff --check` successfully.
- Confirmed `Game/project.godot` is untouched.
- Confirmed the movement and combat constants are unchanged except `CROUCH_VISUAL_OFFSET`.
- Confirmed authored crouch geometry uses integer values: `32`, `40`, `24`, and `-24`.
- Confirmed no Cyrillic characters exist in tracked project content.
- Static validation passed.
- Confirmed no Godot executable is available in the validation environment. Windows runtime validation remains pending after publication; no runtime validation was claimed.

## Pending manual checks

- Run the player scene/test arena in Godot 4.7.2 on Windows at native 1280x720.
- Verify standing and crouching poses visually from both horizontal facing directions.
- Verify body/legs contact, feet baseline, 96-pixel standing silhouette, and 64-pixel crouching collision height.
- Verify movement, collision, jump, jetpack, camera, aiming, weapon behavior, damage, ammunition, and reload are unchanged.

## Known risks or limitations

Windows runtime validation remains pending after publication because the Godot executable is not installed or discoverable in this environment; no runtime validation was claimed. The legs pose contract assumes the equipped legs visual exposes `set_crouching()`; replacement modules that do not need pose switching remain valid because the player checks for the method before calling it.

## Recommended next step

Run the Windows visual checklist in Godot 4.7.2 after publication.
