# Task 041: Kinetic Shield Counter-Blast Cooldown

## Objective

Add a data-driven two-second recovery after a successful kinetic Shield counter-blast while preserving Task 039 absorption and Task 040 activation/routing behavior.

## Completed changes

- Added `counter_blast_cooldown = 2.0` to Shield ability data.
- Added exact-instance `ability_cooldown_remaining` ownership.
- Added typed `ShieldController.advance(delta)` cooldown progression and held-Q reactivation.
- Added typed `captures_fire_input()` so Q retains LMB ownership through cooldown.
- Made the successful counter-blast transition consume charge, start cooldown, deactivate the Shield, and emit one final state update.
- Updated HUD cooldown priority and documentation.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/039_kinetic_shield_absorption/kinetic_shield_absorption_report.md`
- `DEV/reports/041_kinetic_shield_counter_cooldown/kinetic_shield_counter_cooldown_report.md`
- `Game/resources/equipment/shield_ability.tres`
- `Game/scripts/abilities/shield_controller.gd`
- `Game/scripts/equipment/left_arm_ability_definition.gd`
- `Game/scripts/equipment/left_arm_instance.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Cooldown state ownership

`LeftArmAbilityDefinition` owns immutable `counter_blast_cooldown` tuning. `LeftArmInstance` owns mutable `ability_cooldown_remaining`, initialized to zero. Binding clamps stored cooldown to the authored range without resetting it, so exact-instance pickup swaps preserve recovery state. Standard Left Arm has no Shield ability and remains unaffected.

## Counter-blast transition order

After projectile instantiation, configuration, and successful scene-tree insertion, the controller clears stored charge, starts the authored cooldown, sets the Shield inactive, hides its presentation, disables defensive collision, and emits one coherent state update. Failed projectile creation and zero-charge LMB return without changing charge or cooldown.

## Q/LMB ownership

`captures_fire_input()` returns true whenever a valid Shield ability is equipped and Q is held, including during cooldown. Player checks this query before the weapon fire path. During cooldown, LMB cannot fire or consume weapon ammunition. Releasing Q returns ownership to the weapon immediately, even while cooldown remains. If Q stays held, `advance(delta)` reactivates the Shield when cooldown reaches zero; activation never requires positive charge. Standard Left Arm never captures fire input.

## HUD states

The charge bar remains at zero after counter-blast. HUD priority is: cooldown, saturated, active absorption, stored partial charge, then ready zero charge. Cooldown is displayed as `SHIELD COOLDOWN 2.0s` and decreases through signal updates.

## Checks actually performed

- Confirmed clean required base `0c2c46e4b8efdc79e70bb05fc01bd15a8c36960a` and fast-forward synchronization.
- Inspected the complete Shield input and firing order before editing.
- Confirmed no scenes, collision geometry, projectile code, WeaponController, movement, equipment swapping, or `Game/project.godot` changed.
- Confirmed cooldown is authored in the resource and owned by the exact instance.
- Confirmed `_can_activate()` checks availability and cooldown, never charge.
- Confirmed Player checks `captures_fire_input()` before weapon firing.
- Confirmed cooldown blocks absorption and counter-blast, while Q-held cooldown still captures LMB.
- Ran `git diff --check` and staged diff checks.
- Ran the repository-wide Cyrillic scan excluding `.git`.
- Performed warnings-as-errors static review; no Godot executable is available for parser/runtime validation.
- No Godot or Windows runtime validation was performed or claimed.

## Pending manual checks

- Launch the focused kinetic Shield test scene on Windows with Godot 4.7.2.
- Equip Shield, build charge, fire a counter-blast, and verify exactly two seconds of cooldown.
- Hold Q through cooldown and confirm automatic reactivation at zero cooldown.
- Confirm LMB during cooldown does not fire rifle or shotgun and does not consume ammo.
- Release Q during cooldown and confirm weapon firing resumes while Shield remains inactive.
- Confirm exact Shield instance cooldown persists through drop/equip swaps.
- Confirm HUD cooldown, saturated, absorbing, stored, and ready states.

## Known risks or limitations

Godot parser and runtime behavior remain unverified because the Godot executable is unavailable in this environment. The hostile projectile and Player damage systems remain focused prototype foundations.

## Recommended next step

Run focused Windows runtime validation of the vulnerable recovery window, held-Q reactivation, weapon-input ownership, and exact-instance cooldown persistence.
