# Task 025: Dropped Weapon Visual Fix

## Objective

Synchronize the physical world weapon pickup visual with its current `WeaponDefinition` so dropped rifles and shotguns retain their distinct placeholder appearance.

## Completed changes

- Replaced the hardcoded pickup `WeaponVisual` with a `WorldVisualSlot` Node2D.
- Rebuilds the world visual synchronously when the pickup enters the scene and whenever `set_weapon_definition()` is called.
- Reuses each definition's `held_visual_scene`, clears the previous visual first, and installs the replacement near the ground-contact origin.
- Safely clears the slot for null definitions, missing visual scenes, or non-Node2D visual scenes while preserving `UNKNOWN WEAPON` label behavior.
- Preserved pickup physics, cooldown, collision, weapon switching, ammunition ownership, firing, reload, spread, damage, player movement, HUD, input, and project settings.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/025_dropped_weapon_visual_fix/dropped_weapon_visual_fix_report.md`
- `Game/scenes/equipment/world_weapon_pickup.tscn`
- `Game/scripts/equipment/world_weapon_pickup.gd`

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Audited commit `703badff33b0aba88bf584cf150c1902b04a5d51` before editing and confirmed the reported hardcoded visual defect.
- Confirmed the working tree was clean before implementation.
- Reviewed the complete Task 025 diff.
- Ran `git diff --check`.
- Confirmed scene and script references use the existing repository paths.
- Confirmed the previous visual is cleared before synchronous replacement installation.
- Confirmed no weapon, player, HUD, input, project-setting, or pickup physics code was changed outside the requested visual synchronization.
- Confirmed no Cyrillic characters exist in tracked project content.
- No runtime validation was performed or claimed.

## Pending Windows checks

- Run Godot 4.7.2 on Windows and verify no parser/runtime errors.
- Equip the shotgun with F and confirm the dropped rifle is visibly longer, thinner, and yellow.
- Pick up the rifle again and confirm the dropped shotgun is visibly shorter, thicker, and red.
- Verify visual replacement occurs before each launched drop and remains near the pickup ground-contact point.
- Verify null/missing visual definitions clear safely and retain `UNKNOWN WEAPON` behavior.
- Recheck weapon swap, ammo preservation, cooldown, movement, aiming, crouch, jetpack, firing, reload, projectile collisions, targets, HUD, and native 1280x720 presentation.

## Known risks or limitations

Godot runtime and visual validation were not performed in this environment. World pickup visuals intentionally reuse held weapon placeholder scenes; the pickup visual contract assumes a valid `Node2D` held visual scene.

## Recommended next step

Run the Windows visual checklist after publication, then extend the same pickup presentation boundary to future equipment types when their world pickup systems are implemented.
