# Task 036: Left-Arm Equipment Foundation

## Objective

Add a separate, reusable left-arm equipment ownership boundary with Standard Left Arm as the starting item and Shield Left Arm as a physical F pickup, while deferring all shield gameplay.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/036_left_arm_equipment_foundation/left_arm_equipment_foundation_report.md`
- `Game/project.godot`
- `Game/resources/equipment/shield_ability.tres`
- `Game/resources/equipment/shield_left_arm.tres`
- `Game/resources/equipment/standard_left_arm.tres`
- `Game/scenes/arena.tscn`
- `Game/scenes/equipment/world_left_arm_pickup.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_shield_left_arm.tscn`
- `Game/scenes/hud.tscn`
- `Game/scripts/equipment/left_arm_ability_definition.gd`
- `Game/scripts/equipment/left_arm_definition.gd`
- `Game/scripts/equipment/left_arm_equipment_controller.gd`
- `Game/scripts/equipment/left_arm_instance.gd`
- `Game/scripts/equipment/world_left_arm_pickup.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Ownership architecture

`LeftArmDefinition` is immutable shared configuration. Each `LeftArmInstance` owns one definition reference and is transferred exactly between `LeftArmEquipmentController` and `WorldLeftArmPickup`. The controller owns exactly one current instance and returns the exact outgoing instance on replacement. The Player owns only integration and visual socket installation; left-arm ownership remains in the focused controller.

## Standard versus Shield ability contract

Standard Left Arm has no ability definition, so Q is safely ignored. Shield Left Arm references `shield_ability.tres`, whose typed metadata identifies the `shield` ability. No speculative shield tuning is present.

## Q held-input boundary

Player reads `left_arm_ability` and routes its held state to `LeftArmEquipmentController.set_ability_input()`. The controller emits `left_arm_ability_input_changed` only when the state changes. Standard Left Arm returns false without emitting active input metadata. Replacing an arm releases an active outgoing ability state before resetting it.

## Physical pickup and swap behavior

The arena pickup is a `CharacterBody2D` on collision layer 6 (integer 32) with world collision mask 1 and a non-blocking floor shape. It creates one fresh `LeftArmInstance` from its authored definition in `_ready()`. F interaction takes that exact instance, equips it, transfers the exact outgoing instance back to the same pickup, rebuilds its world visual, and launches it using deterministic existing pickup motion.

## HUD states

The HUD displays `LEFT ARM: STANDARD` / `Q: NONE` initially, `LEFT ARM: SHIELD` / `Q: SHIELD READY` after pickup, and `Q: SHIELD INPUT HELD` while Q is held. Returning to Standard restores `Q: NONE`. The controls help includes Q and the layout keeps the interaction prompt separate.

## Explicitly deferred Task 037 behavior

Damage blocking, frontal filtering, shield collision, energy, drain, recharge, shield breaking, projectile handling, reflected waves, firing lock, final animation, one-second swap presentation, and invulnerability are not implemented.

## Checks actually performed

- Confirmed the required base commit and clean preflight state.
- Inspected and reused the existing leg ownership and pickup pattern.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed Standard Left Arm has no ability resource and Shield Left Arm references `shield_ability.tres`.
- Confirmed exact `LeftArmInstance` transfer APIs in controller and pickup.
- Confirmed `LeftArmSlot` is empty in the authored player scene and Player layer 2/mask 5 are unchanged.
- Confirmed no shield defense, energy, collision, or global-transform workaround was added.
- Confirmed no UID files were created or modified.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked content.
- No Godot runtime test was performed or claimed.

## Pending Windows runtime checklist

Verify Standard Left Arm at startup, F pickup and replacement in both directions, exact visual swaps, Q no-op with Standard, Shield ready/held/released HUD states, pickup label and cooldown, and no overlap in the 1280x720 HUD.

## Known limitations

Shield behavior is metadata and input state only. The required protection and energy mechanics remain pending Task 037, and the one-second equipment swap presentation is not implemented.

## Recommended next step

Implement the Shield ability runtime in Task 037 using the existing left-arm controller signal boundary without changing instance ownership or pickup transfer.
