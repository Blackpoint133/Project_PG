# Task 050: Crouch Ctrl Input Migration

## Objective

Move the existing `crouch` action from physical S to physical Ctrl while preserving the secondary Down Arrow binding and all existing crouch mechanics. Sliding remains deferred to the next focused task.

## Exact changed files

- `Game/project.godot`
- `Game/scenes/hud.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/050_crouch_ctrl_input_migration/crouch_ctrl_input_migration_report.md`

## Input-map change

The existing action name remains `crouch`. Its former physical S event (`physical_keycode = 83`) was replaced with the physical Left Ctrl event (`physical_keycode = 4194326`). The secondary Down Arrow event (`physical_keycode = 4194322`) remains unchanged. No new action was added and no other input action was changed.

## Gameplay preservation

No GDScript files changed. Crouch speed, collision heights, visual offset, modular legs geometry, acceleration, friction, jump, jetpack heat, grapple, Knee Dash, Shield, weapons, equipment, collisions, and arena geometry remain unchanged. No slide behavior, impulse, duration, landing slide, or cooldown was implemented.

## Documentation changes

Current controls now document Ctrl for crouch. Stale statements deferring Ctrl migration were removed. The remaining roadmap preserves grounded and landing slide as the next focused task, followed by full Player-body Knee Dash contact, the Knee Dash bleeding debuff, an integrated movement/combat audit, and the first radio/helicopter mission slice.

## Static validation

- Required clean base, branch, fetch, fast-forward, and HEAD/origin verification passed.
- Complete diff reviewed.
- `git diff --check` passed before staging.
- The `crouch` action name is unchanged.
- Physical S keycode `83` is absent from the crouch action.
- Physical Ctrl keycode `4194326` is present.
- Down Arrow physical keycode `4194322` remains present.
- All other input-map actions were compared unchanged.
- No GDScript files changed.
- HUD controls geometry and styling remain unchanged; only the control text changed.
- No slide behavior was added.
- Repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending for S rejection, Left Ctrl crouch, Down Arrow crouch, crouching movement, modular legs pose, and regression coverage for movement, jump, jetpack heat, weapons, Knee Dash, Shield, Hook, pickups, and collisions.

## Known risks or limitations

This task changes only serialized input mapping and player-facing documentation. The existing input action remains named `crouch`, so runtime behavior depends on Godot loading the physical Ctrl event as authored.

## Recommended next step

Run the Windows checklist and implement grounded/landing slide with anti-bunny-hop cooldown in the next focused task.

## Commit and push results

Implementation commit: `34490bab25b65e80d93ef9742d08c12d55c8d14f` (`fix: move crouch input to Ctrl`). The commit was pushed normally to `origin/main` and remote verification passed. After the implementation push, `HEAD` and `origin/main` both matched `34490bab25b65e80d93ef9742d08c12d55c8d14f`, and the working tree was clean. This report-only publication update will record the final documentation commit and state.

## Windows runtime checklist

1. Start the main scene.
2. Press S while standing and confirm the Player does not crouch.
3. Hold Left Ctrl and confirm the Player crouches; release it and confirm standing returns.
4. Hold Ctrl while moving and confirm existing crouch movement without sliding.
5. Land while holding Ctrl and confirm ordinary crouch without a slide.
6. Confirm Down Arrow still crouches.
7. Confirm the modular legs crouching pose remains correct.
8. Verify A/D movement, jump, jetpack heat, weapons, Knee Dash, Shield, Hook, pickups, and enemy collisions.
9. Confirm the HUD reads `Ctrl: crouch` and Godot shows no parser or runtime errors.
