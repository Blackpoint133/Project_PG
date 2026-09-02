# Task 021: Crouch Pose Dynamic Call Fix

## Objective

Replace the statically unsafe method invocation on the Node-typed legs module with Godot's safe dynamic modular call interface.

## Completed changes

- Replaced the direct `legs_module.set_crouching(crouching)` invocation with `legs_module.call(&"set_crouching", crouching)` while preserving the existing `has_method(&"set_crouching")` guard.
- Updated project context minimally to record the audit correction.
- Preserved crouch geometry, movement, physics, combat, input, HUD, arena, project settings, and all module scenes.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/021_crouch_pose_dynamic_call_fix/crouch_pose_dynamic_call_fix_report.md`
- `Game/scripts/player.gd`

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Confirmed the working tree was clean before the Task 021 change.
- Reviewed the complete diff and confirmed only the three listed Task 021 files changed.
- Ran `git diff --check` successfully.
- Confirmed `Game/project.godot` is untouched.
- Confirmed no module scene changed.
- Confirmed no unrelated gameplay, physics, combat, input, HUD, arena, or project-setting changes exist.
- Confirmed no Cyrillic characters exist in tracked project files.

## Pending manual checks

- Windows runtime validation remains pending after publication because no Godot executable is available in this environment.
- No runtime validation was claimed.

## Known risks or limitations

The dynamic call depends on the existing guarded `set_crouching` interface exposed by a compatible legs module. No gameplay behavior was changed.

## Recommended next step

Run the existing Windows visual crouch checklist in Godot 4.7.2 after publication.
