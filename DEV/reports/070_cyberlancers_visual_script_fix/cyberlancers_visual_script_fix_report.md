# Task 070: Cyberlancers Visual Script Compatibility Fix

## Objective

Correct the shared leg presentation script so Standard Legs `ColorRect` visuals and Cyberlancers `Sprite2D` visuals can initialize through one explicitly typed script.

## Completed changes

`Game/scripts/player/modules/placeholder_legs.gd` now types `standing_visual` and `crouching_visual` as `CanvasItem`. The existing node paths and `set_crouching(crouching: bool)` implementation are unchanged and still only toggle `visible`.

The Task 069 mismatch was that both variables remained typed as `ColorRect` after the script became shared with Cyberlancers Sprite2D nodes. `CanvasItem` is the nearest common typed base and exposes the required visibility property.

## Exact changed files

- `Game/scripts/player/modules/placeholder_legs.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/070_cyberlancers_visual_script_fix/cyberlancers_visual_script_fix_report.md`

## Preserved behavior

- Standard Legs continue supplying ColorRect nodes and retain their appearance and C no-op behavior.
- Cyberlancers continue supplying Sprite2D nodes and using the native 64x64 nearest-filtered asset.
- Standing, mirroring, crouching, Slide, Knee Dash, collision, equipment ownership, and gameplay constants were not changed.
- The runtime PNG and both DEV source-art PNGs were not modified.

## Validation performed

- Confirmed clean `main` precondition at required base `c2dd58d7ea1366f0fb918b69b5c703a582ecd937` before editing.
- Reviewed the complete implementation and documentation diffs.
- Confirmed the implementation commit contains only the shared leg script.
- Confirmed both scene families use the expected visual node types and both inherit `CanvasItem`.
- Confirmed the shared script uses only the `visible` property and preserves `set_crouching(crouching: bool)`.
- Ran `git diff --check` and staged checks.
- Confirmed the runtime PNG remains 64x64, 907 bytes, alpha-capable, and has SHA-256 `5dada02aea453199f48c279f30f43706db213fc5f0eab00234354c9738a7f26e`.
- Ran the tracked-project Cyrillic scan excluding binary files and `.git`.
- Confirmed no UID, `.godot`, import-cache, or unrelated file was changed.

## Checks not performed

No compatible Godot 4.7.2 executable was available in the environment, so parser, import, startup, visual, and runtime checks were not performed. Windows validation remains pending.

## Known risks and limitations

The Cyberlancers scene still temporarily uses its player visual for world pickup presentation. Dedicated ground-pickup artwork remains a later visual task.

## Recommended next step

Run the focused Windows Godot checklist and confirm both leg scene variants initialize without warnings.

## Publication

Implementation commit: `869216329d78ce21daf2e0f1ef97f345f6ab9443` (`fix: support Sprite2D leg visuals`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after this report-only commit and push.

## Windows checklist

1. Start with Standard Legs and confirm the old appearance and C no-op behavior.
2. Pick up Cyberlancers and confirm no type error occurs.
3. Confirm HUD shows `LEGS: CYBERLANCERS`.
4. Verify standing, left/right mirroring, crouching, and Slide visuals.
5. Verify Knee Dash, damage, knockback, Bleeding, and cooldown.
6. Swap repeatedly between Standard Legs and Cyberlancers.
7. Confirm no red Godot errors or warnings.
