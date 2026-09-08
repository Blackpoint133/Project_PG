# Task 042: Right Arm Equipment Foundation

## Goal

Add a reusable right-arm equipment boundary matching the existing leg and left-arm systems. Standard Right Arm starts equipped, Hook Right Arm is acquired physically with F, and E emits a typed ability request without implementing hook runtime behavior.

## Exact changed and created file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/042_right_arm_equipment_foundation/right_arm_equipment_foundation_report.md`
- `Game/project.godot`
- `Game/resources/equipment/hook_ability.tres`
- `Game/resources/equipment/hook_right_arm.tres`
- `Game/resources/equipment/standard_right_arm.tres`
- `Game/scenes/arena.tscn`
- `Game/scenes/equipment/world_right_arm_pickup.tscn`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_hook_right_arm.tscn`
- `Game/scripts/equipment/right_arm_ability_definition.gd`
- `Game/scripts/equipment/right_arm_definition.gd`
- `Game/scripts/equipment/right_arm_equipment_controller.gd`
- `Game/scripts/equipment/right_arm_instance.gd`
- `Game/scripts/equipment/world_right_arm_pickup.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Implemented architecture

`RightArmDefinition` owns immutable identity, display, visual, and optional ability metadata. `RightArmInstance` owns the exact runtime definition reference and has no speculative mutable runtime state. `RightArmEquipmentController` owns one current instance, returns the exact outgoing instance on replacement, emits typed definition/ability signals, and emits one typed ability request for valid Hook activation.

`RightArmSlot` remains the stable socket under `BodyRoot/AimPivot`. The authored static right-arm child was removed; Player installs the definition visual dynamically whenever the right-arm definition changes. This preserves existing aim and facing transforms while keeping right-arm visuals independently replaceable.

## Exact-instance ownership and swap behavior

Scene-authored `WorldRightArmPickup` creates one fresh `RightArmInstance` in `_ready()`. Runtime pickup swaps use typed `take_right_arm_instance()` and `set_right_arm_instance()` calls. Player equips the incoming instance, places the exact outgoing instance into the same pickup, launches it with the established deterministic drop motion, and refreshes the interaction prompt. No instance is cloned, duplicated, or silently destroyed.

The pickup uses collision layer 6 / integer 32 and world collision mask 1, matching the existing equipment pickup contract. It owns deterministic gravity, floor settling, horizontal friction, interaction cooldown, label, and dynamically rebuilt world visual.

## Standard and Hook definitions

- Standard Right Arm: `standard_right_arm.tres`, display name `STANDARD`, existing `placeholder_right_arm.tscn`, no ability definition.
- Hook Right Arm: `hook_right_arm.tres`, display name `HOOK`, `placeholder_hook_right_arm.tscn`, and `hook_ability.tres` metadata with ability id `hook` and display name `HOOK`.
- The Hook placeholder is a compact integer-authored emitter silhouette only; it contains no cable, projectile, hitbox, or gameplay behavior.

## Input and HUD changes

`right_arm_ability` was added to `Game/project.godot` with physical E. Player routes discrete E presses to `RightArmEquipmentController.activate_ability()`. Standard Right Arm safely returns false; Hook Right Arm emits a typed request that Player intentionally ignores until the next task. E does not share or interfere with Q, C, F, LMB, movement, or weapon switching.

HUD now presents `RIGHT ARM: STANDARD / E: NONE` at startup and `RIGHT ARM: HOOK / E: HOOK READY` after pickup. The controls hint includes E. The status is signal-driven and placed separately from the existing weapon, leg, left-arm, shield, health, and interaction displays.

## Arena pickup

One Hook Right Arm pickup was added at a free reachable floor position in `arena.tscn`, using `hook_right_arm.tres`. Existing targets, weapon pickups, Shield pickup, Knee-Dash pickup, platforms, and player spawn were not redesigned or moved.

## Deferred hook runtime scope

This task intentionally does not implement a hook projectile, cable, collision or hit detection, pull force, enemy pulling, player grappling, damage, stun, cooldown, charges, animation, or final art.

## Validation performed

- Confirmed branch `main`, clean preflight, fetch, and required base `0e4bb85639138657f35f94e4a5742af8bfc298ab`.
- Inspected the existing leg, left-arm, pickup, interaction, Player, HUD, arena, and input implementations.
- Confirmed the exact intended Task 042 file scope.
- Ran `git diff --check` and staged diff checks.
- Confirmed all new resource and scene references resolve statically.
- Confirmed `project.godot` changes only add the physical E action.
- Confirmed no weapon, shield, leg, health, movement, physics, collision, or projectile runtime changes were included beyond right-arm integration.
- Ran the repository-wide Cyrillic scan excluding `.git`; no Cyrillic characters were found.
- Performed a warnings-as-errors static review of new typed GDScript.
- No Godot executable is available, so parser and runtime validation were not performed or claimed.

## Windows runtime checklist

- Launch the normal arena in Godot 4.7.2 and confirm no parser/runtime errors.
- Confirm Standard Right Arm is installed dynamically at startup and visually follows aiming/facing.
- Approach the Hook Right Arm pickup and confirm the F prompt uses `HOOK`.
- Press F and confirm the Hook visual replaces the right-arm slot while the previous Standard instance is dropped.
- Recollect the dropped Standard Right Arm and confirm exact-instance swaps in both directions.
- Confirm HUD changes between `RIGHT ARM: STANDARD / E: NONE` and `RIGHT ARM: HOOK / E: HOOK READY`.
- Press E with Standard Right Arm and confirm no error or gameplay effect.
- Press E with Hook Right Arm and confirm the typed request is safe and intentionally has no hook runtime effect.
- Confirm E does not affect firing, Shield Q, Knee Dash C, interaction F, movement, reload, ammunition, or aiming.

## Commit and push results

Commit and remote verification are recorded after validation in the final task handoff.

## Recommended next step

Implement the focused Hook runtime in a separate task: projectile/cable boundary, target collision, pulling, damage/stun policy, and any authored cooldown only after Windows foundation validation.
