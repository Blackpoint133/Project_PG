# Task 040: Kinetic Shield Absorption Routing Fix

## Objective

Correct the Task 039 kinetic Shield activation, initial-charge, projectile-routing, and saturated-HUD regressions without changing the Task 039 architecture or gameplay tuning.

## Completed changes

- New `LeftArmInstance` objects now start with zero stored charge.
- Existing instance charge is still clamped when bound to `ShieldController` and remains attached during exact-instance swaps.
- Valid Shield equipment activates at zero, partial, or saturated charge.
- `EnemyProjectile` resolves an overlapping `ShieldArea` to its direct typed parent `ShieldController` before marking shield processing complete.
- Saturated HUD text now has priority over generic active absorption text.
- Task 039 report and project context now document the corrected contract.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/039_kinetic_shield_absorption/kinetic_shield_absorption_report.md`
- `DEV/reports/040_kinetic_shield_absorption_fix/kinetic_shield_absorption_fix_report.md`
- `Game/scripts/abilities/enemy_projectile.gd`
- `Game/scripts/abilities/shield_controller.gd`
- `Game/scripts/equipment/left_arm_instance.gd`
- `Game/scripts/hud.gd`

## Confirmed root causes

Task 039 initialized Shield charge to maximum, made `_can_activate()` require positive charge, searched for `absorb_damage()` directly on the presentation sensor instead of its controller parent, and rendered active HUD text before saturated text.

## Corrected behavior

Every newly constructed Shield Left Arm instance starts at `0.0`. Shield charge is not reset by `set_left_arm_instance()`; existing values are clamped to the current maximum. A valid Shield activates whenever Q is held regardless of charge, including at zero. Standard Left Arm remains a safe no-op.

An enemy projectile accepts an Area2D only when its direct parent is a typed `ShieldController`. It then calls `absorb_damage()` directly, marks the shield interaction once, destroys itself for zero remainder, or continues with only the positive overflow. Saturated charge therefore passes the full incoming damage to Player.

The HUD reports `SHIELD SATURATED 100%` before checking active state, while partial active charge reports `SHIELD ABSORBING N%`.

## Checks actually performed

- Confirmed the required clean base commit `c0d4c7db8d0017daa3b2a5b8f6be66d699306ac7`.
- Inspected the complete Task 039 implementation before editing.
- Confirmed no scenes, resources, collision geometry, tuning values, WeaponController, movement code, equipment swapping, or `Game/project.godot` changed.
- Confirmed `_can_activate()` no longer reads stored charge.
- Confirmed `_shield_processed` is set only after a valid typed parent controller is found.
- Confirmed overflow and single-projectile processing remain intact.
- Confirmed saturated HUD priority.
- Ran `git diff --check` and staged diff checks.
- Ran the repository-wide Cyrillic scan excluding `.git`.
- Performed manual warnings-as-errors static review; no Godot executable is available for parser validation.
- No Godot runtime or Windows visual validation was performed or claimed.

## Pending manual checks

- Run the Task 039 focused test scene on Windows with Godot 4.7.2.
- Confirm a fresh Shield starts at 0%, activates on held Q, and absorbs incoming 20-damage projectiles.
- Confirm five hits reach 100%, the next hit damages Player, and an unprotected side reaches Player.
- Confirm counter-blast works from empty only after charge is built, remains active after release, and does not consume weapon ammunition.
- Confirm saturated HUD text remains `SHIELD SATURATED 100%` while active or inactive.

## Known risks or limitations

Godot parser and runtime validation remain pending because no Godot executable is available in this environment. The broader Task 039 damage and projectile systems remain prototype foundations.

## Recommended next step

Run focused Windows runtime validation for empty activation, five-hit saturation, overflow damage, counter-blast, side orientation, and HUD priority.
