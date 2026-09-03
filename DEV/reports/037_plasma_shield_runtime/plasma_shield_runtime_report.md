# Task 037: Plasma Shield Runtime

## Objective

Implement the runtime foundation for Shield Left Arm: a signal-driven held-Q plasma barrier with per-instance energy, delayed recharge, depletion release latch, HUD state, firing lock, and a prepared defensive collision boundary.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/037_plasma_shield_runtime/plasma_shield_runtime_report.md`
- `Game/resources/equipment/shield_ability.tres`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_shield_left_arm.tscn`
- `Game/scripts/abilities/shield_controller.gd`
- `Game/scripts/equipment/left_arm_ability_definition.gd`
- `Game/scripts/equipment/left_arm_instance.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Confirmed base commit

Implementation started from `af28bf4faf76242f0ecab40b4838e7a8cb974095` with a clean working tree and matching `origin/main`.

## Energy tuning

`shield_ability.tres` authors the typed values `max_energy = 100.0`, `active_drain_per_second = 25.0`, `recharge_per_second = 20.0`, and `recharge_delay = 1.0`. This provides four seconds of uninterrupted full-energy use, a one-second recharge delay, and five seconds for a full recharge.

## Exact per-instance state

`LeftArmInstance` owns `ability_energy`, `ability_recharge_delay_remaining`, and `ability_release_required`. Standard Left Arm starts with zero energy because it has no ability. Shield instances start at their definition's maximum energy. The same exact instance continues to move between the controller and world pickup, preserving energy, delay, and depletion state.

## Activation, depletion, and recharge state machine

`LeftArmEquipmentController` remains the owner of the held Q input boundary. Player forwards its typed input signal to `ShieldController`. A Shield instance activates immediately for held Q when energy is above zero. Release deactivates immediately and starts the authored delay. Active drain reaches zero by clamping energy, immediately hides the shield, sets the instance release latch, and starts the delay. Continued Q hold cannot reactivate or flicker; Q must be released first. After the delay, an unheld shield recharges to its maximum. Swapping away deactivates the controller without resetting the exact instance state.

## Visual hierarchy and local geometry

`ShieldController` is a `Node2D` child of `BodyRoot/AimPivot`, so its panel inherits existing aim rotation and left/right mirroring without global-position synchronization. The inactive held arm now contains only the standard-sized arm and a compact cyan emitter. The active controller owns a translucent cyan `ShieldFill` and bright `ShieldOutline`; the panel spans integer-authored local coordinates approximately 44..64 by -52..52. Its defensive rectangle is centered at local X 52 with size 16x96.

## Collision-layer contract

`ShieldArea` is inactive on collision layer 0 and always uses collision mask 16, corresponding to future enemy attack layer 5. While active, the controller changes its layer to 64, logical layer 7, and enables monitoring. It does not push bodies and no hostile projectile integration is included.

## Player firing-lock order

At the start of each Player physics frame, held Q is routed through `LeftArmEquipmentController`, then `ShieldController.advance(delta)` updates energy/state. Player next sets `WeaponController.set_firing_enabled(not shield_controller.is_active())`, and only then processes LMB firing. Shield activity therefore prevents projectile spawning and ammunition consumption while preserving weapon switching and manual reload routing.

## Standard versus Shield behavior

Standard Left Arm has no ability definition, never activates the shield, never blocks firing, and displays `Q: NONE`. Shield Left Arm displays `SHIELD READY 100%`, `SHIELD ACTIVE`, `SHIELD COOLDOWN`, `SHIELD RECHARGING`, or `RELEASE Q 0%` according to signal-driven state. The energy bar is visible only for Shield equipment.

## Explicitly deferred hostile-projectile absorption

Actual enemy projectiles, incoming damage, frontal filtering, absorption, per-projectile energy cost, reflected damage, final effects, sound, animation, and equipment-swap cinematics remain deferred.

## Checks actually performed

- Confirmed the required base commit and clean preflight state after fast-forward synchronization.
- Inspected Task 036 ownership, Player input order, WeaponController firing gate, HUD signals, and AimPivot hierarchy.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed Standard Left Arm remains passive and Shield metadata owns the energy values.
- Confirmed energy, recharge delay, and release latch are stored on `LeftArmInstance`.
- Confirmed the active panel is under AimPivot and the inactive visual has no large shield plate.
- Confirmed the Player firing gate follows shield input routing and energy advance.
- Confirmed weapons, legs, Knee Dash, movement, project settings, pickups, and UID files were not otherwise changed.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked content.
- No Godot runtime or visual test was performed or claimed.

## Pending Windows runtime checklist

Verify startup Standard state, F Shield pickup, panel visibility/aim/mirroring, four-second drain, immediate release, one-second delay, five-second recharge, depletion release latch, energy bar, Q+LMB firing lock, firing resume after release, exact energy persistence after swaps, and 1280x720 HUD layout.

## Known limitations

The defensive Area2D is only a future attack boundary; no hostile attacks exist yet. The controller uses placeholder geometry and does not implement actual absorption or player health interaction.

## Recommended next step

Add hostile projectile and damage routing in a later focused task, consuming the prepared logical layer 7 shield boundary without moving energy ownership out of `LeftArmInstance`.
