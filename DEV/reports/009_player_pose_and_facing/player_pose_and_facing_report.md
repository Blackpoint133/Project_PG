# Report: 009_player_pose_and_facing

## Task objective

Correct the placeholder grounding, crouch pose, facing behavior, and shoulder/weapon pivots while preserving all validated movement, jetpack, aiming, camera, HUD, and platform behavior.

## User-reported Task 008 visual validation

The user completed the Task 008 Windows visual test and reported these defects: crouching moved the character visual upward, the body did not turn when the mouse crossed behind the player, only the weapon direction changed, the arm rotated around an elbow or central point instead of the shoulder, and the visual feet were approximately 14 logical pixels above the ground. These results are recorded as user-reported validation only; Codex did not reproduce them in Godot.

## Root causes

- The collision center was calculated as `(STAND_HEIGHT - target_height) * 0.5`, which is positive. Godot centers shapes on the collision node, so both poses kept the collision center above Y=0 and left the bottom above the ground.
- `_update_crouch()` moved the entire `BodyRoot` upward. This lifted all visuals, including feet, instead of lowering only the upper-body modules.
- Body, legs, and jetpack were not horizontally flipped, so only the aim-following weapon changed direction.
- Arm visuals started at their shoulder node but extended backward into negative local X, and the weapon sat at the shoulder origin rather than in the hands.

## Implemented corrections

### Ground and collision anchoring

- Standing collision height 28: `collision_shape.position.y = -28 * 0.5 = -14`.
- Crouching collision height 18: `collision_shape.position.y = -18 * 0.5 = -9`.
- Collision width remains 12.
- The collision bottom remains at local Y 0 in both poses.

### Crouch pose

- `BodyRoot` remains at its neutral local position.
- `BodySlot` and `JetpackSlot` move down by 10 pixels while crouching.
- `AimPivot` moves from Y -18 to Y -8 while crouching.
- `LegsSlot` remains fixed at Y 0.
- `BodyRoot` is not scaled.
- Crouching silhouette covers local Y -18 through Y 0.

### Post-audit correction

A post-commit repository audit found that the initially documented downward offset was implemented as `target_height - STAND_HEIGHT`, which produced -10 in Godot and moved the modules upward. Task 010 corrected this to a clearly named `upper_body_offset = STAND_HEIGHT - target_height`; the formulas above describe the corrected behavior, not the original implementation.

### Facing

- Added `facing_direction` and a 4-pixel horizontal dead zone.
- Mouse to the right sets `facing_direction = 1`; mouse to the left sets it to -1.
- The previous facing is preserved inside the dead zone.
- Only `BodySlot`, `LegsSlot`, and `JetpackSlot` flip horizontally; `BodyRoot` is not flipped.
- The placeholder body gained a small front marker so flipping is visible locally.
- `AimPivot` still uses the unchanged `look_at(get_global_mouse_position())` calculation and is mirrored on local Y only when facing left, keeping arm and weapon artwork upright without reversing the firing direction.

### Arm and weapon pivots

- Both arm visuals now begin at local `Vector2(0, 0)` and extend toward positive local X.
- Left arm ends near `Vector2(7, 2)`; right arm ends near `Vector2(7, -2)`.
- `WeaponSlot` moved to `Vector2(7, 0)` so the weapon begins near the hands.
- `AimLine` starts at the weapon pivot and extends forward from the muzzle area.

## Exact changed files

- `Game/scripts/player.gd`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_body.tscn`
- `Game/scenes/player/modules/placeholder_left_arm.tscn`
- `Game/scenes/player/modules/placeholder_right_arm.tscn`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/009_player_pose_and_facing/player_pose_and_facing_report.md`

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Confirmed the starting commit included `766fc05c86c6e52f76c819d6d28a9c146faaf841`.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Confirmed standing collision and visual both end at local Y 0.
- Confirmed crouching collision and visual both end at local Y 0.
- Confirmed `LegsSlot` never moves vertically during crouching.
- Confirmed `BodyRoot` is not non-uniformly scaled.
- Confirmed body, legs, and jetpack flip without flipping `BodyRoot`.
- Confirmed arms begin at their shoulder-side local origin and extend toward positive local X.
- Confirmed `WeaponSlot` remains a separate scene instance.
- Confirmed jetpack constants and flight logic are unchanged.
- Confirmed input mappings are unchanged.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Godot runtime and visual validation were not performed.

## Pending Windows manual checks

- Run the project and verify standing visual feet rest on the ground.
- Hold S and verify the upper body, arms, weapon, and jetpack lower while the feet remain planted.
- Move the mouse across the vertical centerline and verify body, legs, and jetpack flip.
- Confirm the front-facing marker changes side when facing changes.
- Confirm arms and weapon rotate from the shoulder around the cursor in every quadrant.
- Confirm movement, jump, jetpack, camera, platform collision, and HUD states remain unchanged.

## Risks or limitations

- Placeholder art positions may require further visual tuning after runtime inspection.
- `AimPivot` vertical mirroring is currently binary; future artwork may need a more continuous uprighting rule.
- The pose remains placeholder geometry and does not yet include animation.

## Recommended next step

Perform the Windows visual checklist, then record any required pixel-level pose tuning as a separate focused task before equipment behavior work.
