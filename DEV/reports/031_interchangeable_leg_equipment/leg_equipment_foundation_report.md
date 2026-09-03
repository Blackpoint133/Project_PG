# Task 031: Interchangeable Leg Equipment Foundation

## Objective

Create the data-driven leg equipment, exact-instance physical pickup transfer, runtime LegsSlot replacement, C ability request boundary, and HUD foundation without implementing knee-dash movement.

## Completed changes

- Added `LegDefinition`, `LegAbilityDefinition`, `LegInstance`, and `LegEquipmentController`.
- Replaced the scene-authored permanent legs child with a runtime visual installed in the existing LegsSlot.
- Preserved standing/crouching leg visuals and reapplied the crouching API after every visual replacement.
- Added `WorldLegPickup` with deterministic gravity, floor settling, cooldown, visual/label rebuilding, and exact instance transfer.
- Added Standard Legs and Knee-Dash Legs resources plus Knee Dash ability metadata.
- Added a distinct red Knee-Dash Legs placeholder using the same standing/crouching geometry and API.
- Added the physical C input action and safe leg ability request; no dash execution was added.
- Added a Knee-Dash Legs pickup to the arena and a controller-backed HUD leg status readout.
- Kept leg equipment independent from weapon slots and left WorldWeaponPickup unchanged.

## Exact changed and created file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/031_interchangeable_leg_equipment/leg_equipment_foundation_report.md`
- `Game/project.godot`
- `Game/resources/equipment/knee_dash_ability.tres`
- `Game/resources/equipment/knee_dash_legs.tres`
- `Game/resources/equipment/standard_legs.tres`
- `Game/scenes/arena.tscn`
- `Game/scenes/equipment/world_leg_pickup.tscn`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_knee_dash_legs.tscn`
- `Game/scripts/equipment/leg_ability_definition.gd`
- `Game/scripts/equipment/leg_definition.gd`
- `Game/scripts/equipment/leg_equipment_controller.gd`
- `Game/scripts/equipment/leg_instance.gd`
- `Game/scripts/equipment/world_leg_pickup.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Ownership and transfer architecture

`LegDefinition` is shared configuration, `LegInstance` owns one exact definition reference, and `LegEquipmentController` owns the single player leg instance. Scene-authored pickups create one fresh instance in `_ready()`. F interaction takes the pickup instance, replaces the controller instance, and returns the exact outgoing instance to the same pickup before deterministic launch. Legs never share ownership or ammunition state with weapons.

## Standard Legs behavior

Standard Legs are equipped at startup, retain the existing green placeholder visual, implement `set_crouching(crouching: bool)`, and have no ability definition. Pressing C safely returns false with no movement, state change, error, or combat effect.

## Knee-Dash Legs metadata behavior

Knee-Dash Legs use a distinct red placeholder with the same standing/crouching geometry and expose `knee_dash` / `KNEE DASH` metadata. C emits a typed ability request only; execution is intentionally deferred.

## HUD and input behavior

The native C action is the only new input action. HUD leg status is updated from leg controller signals and shows the current definition plus `C: NONE` or `C: KNEE DASH`. Existing weapon HUD, weapon inputs, and interaction candidate selection remain unchanged.

## Checks actually performed

- Read `AGENTS.md`, the complete `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Confirmed a clean working tree before editing and fast-forwarded to `595f6c9fc7032d00c00794c50bcf2085dbb8b82c`.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed Standard Legs has no ability and Knee-Dash Legs references the Knee Dash ability resource.
- Confirmed exact `LegInstance` take/replace/return transfer in both directions.
- Confirmed the old permanent legs scene child is removed and runtime visuals occupy only LegsSlot.
- Confirmed both leg visuals use the compatible crouching API and baseline geometry.
- Confirmed no knee movement, damage, hitbox, cooldown execution, or knockback was implemented.
- Confirmed leg code does not alter weapon ownership or ammunition.
- Confirmed only the physical C input action was added and unrelated project settings remain unchanged.
- Confirmed movement/combat constants, WorldWeaponPickup, WeaponController, WeaponInstance, weapon resources, projectile/target logic, and existing UID files remain unchanged.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked project content.
- No Godot runtime testing was performed or claimed.

## Pending manual checks

- Launch Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Confirm Standard Legs visual, baseline, crouch pose, and C no-op behavior.
- Pick up Knee-Dash Legs with F, verify visual/HUD metadata and exact dropped Standard Legs.
- Recollect Standard Legs and verify visual restoration and no-ability behavior.
- Verify repeated swaps, nearest pickup selection, deterministic launch, cooldown, collision, and labels.
- Verify weapon switching/firing/ammunition, movement, crouch, aim, facing, jetpack, camera, targets, and native 1280x720 presentation.

## Known risks or limitations

Godot runtime/parser validation was unavailable in this environment. The typed nullable leg references and runtime class registration should be confirmed in Godot 4.7.2 on Windows. The one-second swap presentation and Knee-Dash execution remain unimplemented.

## Recommended next step

Run the focused Windows leg-equipment checklist, then implement Knee-Dash movement and its combat behavior in Task 032.
