# Report: 011_crouch_visual_pose_fix

## Task objective

Correct the crouching placeholder pose so the torso communicates crouching without sinking visibly into the legs, while preserving collision anchoring, facing, aiming, movement, jetpack physics, HUD behavior, input mappings, and all module scenes.

## User-reported Windows runtime result

The user reported that standing pose, mouse-facing, shoulder-based weapon rotation, and aim-guide placement are correct, but during crouching the torso sinks too far into the legs. This is recorded as a user-reported result; Codex did not reproduce it in Godot.

## Root cause

The crouch visual offset used the full collision height reduction of 10 pixels. With body geometry covering Y -28 through -16 and legs covering Y -16 through 0, moving the upper body down by 10 pixels overlapped nearly the entire torso with the leg module.

## Exact visual offset correction

Added `CROUCH_VISUAL_OFFSET = 4.0` and applied it only while crouching. `LegsSlot` remains fixed at Y 0, and collision anchoring is unchanged.

### Standing positions

| Node | Position |
| --- | --- |
| LegsSlot | Y 0 |
| BodySlot | Y 0 |
| JetpackSlot | Y 0 |
| AimPivot | Y -18 |
| CollisionShape2D | Y -14, covering Y -28 through Y 0 |

Torso visible range: Y -28 through Y -16, directly above the leg module.

### Crouching positions

| Node | Position |
| --- | --- |
| LegsSlot | Y 0, unchanged |
| BodySlot | Y 4 |
| JetpackSlot | Y 4 |
| AimPivot | Y -14 |
| CollisionShape2D | Y -9, covering Y -18 through Y 0 |

Torso visible range: Y -24 through Y -12. The leg module occupies Y -16 through Y 0, so the torso remains visibly above the legs with only a 4-pixel temporary overlap.

## Exact changed files

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/011_crouch_visual_pose_fix/crouch_visual_pose_fix_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main` before changes.
- Confirmed standing and crouching node positions are documented and mathematically consistent.
- Confirmed the torso remains visibly above the legs in both poses.
- Confirmed `LegsSlot` does not move during crouching.
- Confirmed collision anchoring, facing, aim calculation, jetpack tuning, input mappings, and scene structure are unchanged.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Godot runtime validation was not performed.

## Pending Windows manual checks

- Run the project and hold S to verify the crouch reads clearly without the torso disappearing into the legs.
- Confirm feet and legs remain planted on the ground.
- Confirm BodySlot, JetpackSlot, and AimPivot remain visually aligned while crouching.
- Confirm facing, shoulder aiming, aim guide, movement, jump, jetpack, camera, HUD, and platform behavior are unchanged.

## Risks or limitations

- The 4-pixel offset is placeholder tuning and may need further visual adjustment after runtime review.
- The pose remains simple placeholder geometry without animation.

## Recommended next step

Perform the Windows crouch visual check and record any further pose tuning in a separate focused task.
