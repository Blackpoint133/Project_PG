# Task 032: Directional Knee Dash

## Objective

Implement the data-driven directional Knee Dash with a 60-degree aim clamp, movement priority, target-only contact hitbox, once-per-dash damage, capped target knockback, and exact leg-instance cooldown ownership.

## Completed changes

- Extended `LegAbilityDefinition` with typed Knee Dash tuning fields and authored prototype values.
- Added cooldown state to `LegInstance`; `LegEquipmentController` decrements, emits state, rejects cooldown activations, and keeps cooldown with exact instances.
- Added `KneeDashController` for active timing, normalized velocity/direction, temporary hitbox, debug visual, target tracking, and typed signals.
- Added mouse-directed direction calculation with signed -60 to +60 degree clamping and facing fallback for near-vertical/origin aim.
- Integrated dash movement priority in Player while preserving Player ownership of velocity and move_and_slide().
- Added active-dash cancellation when equipped legs no longer provide Knee Dash.
- Added target-only contact damage and once-per-activation hit tracking.
- Added capped horizontal `TargetDummy.apply_knockback()` using AnimatableBody2D without changing target health or projectile damage behavior.
- Added HUD ready/active/cooldown states and updated the design documentation.

## Exact changed and created file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/032_directional_knee_dash/directional_knee_dash_report.md`
- `Game/resources/equipment/knee_dash_ability.tres`
- `Game/scenes/player.tscn`
- `Game/scenes/targets/target_dummy.tscn`
- `Game/scripts/abilities/knee_dash_controller.gd`
- `Game/scripts/equipment/leg_ability_definition.gd`
- `Game/scripts/equipment/leg_equipment_controller.gd`
- `Game/scripts/equipment/leg_instance.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`
- `Game/scripts/targets/target_dummy.gd`

## Direction and 60-degree clamp

Player chooses the horizontal side from mouse X when outside the existing facing dead zone, otherwise keeps current facing. It computes the signed angle with `atan2(mouse_offset.y, absf(mouse_offset.x))`, clamps it to the authored maximum capped at 60 degrees, rotates the selected horizontal unit vector, and normalizes the result. Direct vertical aim therefore becomes an up/down 60-degree diagonal on the current facing side; origin aim becomes horizontal.

## Movement priority

The C request is processed before normal movement. During an active dash, Player forces the standing pose, applies the controller velocity, calls move_and_slide(), processes contacts, and advances dash timing. Normal acceleration, friction, gravity, jump, and jetpack thrust are skipped for that interval. Aiming, facing presentation, weapon input, interaction, and collision remain active. Movement state reports `knee_dash` while active.

## Hitbox and once-per-target behavior

The direct Player child `KneeDashController/Hitbox` has collision layer 0 and mask 4, with a compact forward rectangle and a separate translucent debug visual. The controller stores typed Node targets in a per-activation collection, calls `take_damage(contact_damage)` once, optionally calls `apply_knockback()` with dash-direction impulse, emits `target_hit`, and clears the collection for every new dash.

## Damage and knockback behavior

TargetDummy preserves max/current health, collision layer, disabled feedback, and projectile `take_damage()`. Its new `apply_knockback()` accepts typed Vector2 input but applies only capped horizontal displacement for a short duration, preventing vertical fall-away. No AI, gravity, attacks, respawning, bleeding, or invulnerability was added.

## Per-instance cooldown ownership

`LegInstance.ability_cooldown` stores remaining cooldown on the exact equipped object. Controller activation sets it from the ability definition, while controller processing decrements it and emits typed state. Swapping preserves the outgoing value because the same object is transferred to the pickup. Standard Legs have no ability and never receive cooldown.

## HUD states

HUD reads leg state through `LegEquipmentController` and dash signals: Standard displays `C: NONE`, a ready Knee Dash displays `C: KNEE DASH READY`, active dash displays `C: KNEE DASH ACTIVE`, and cooldown displays a one-decimal remaining value. Weapon HUD and interaction prompts remain unchanged.

## Checks actually performed

- Read `AGENTS.md` and the complete `godot-run-and-gun` skill.
- Confirmed a clean working tree before editing and fast-forwarded to `50db3b19d7d022d3d45a1cf773e235524159350e`.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed `Game/project.godot` is untouched.
- Confirmed obsolete facing-only Knee Dash wording was removed and documentation is consistent.
- Confirmed all authored tuning fields are typed and resource-backed.
- Confirmed Standard Legs remain ability-free and C cannot start a dash or cooldown with them.
- Confirmed direction clamp, vertical-facing fallback, once-per-target tracking, exact-instance cooldown, active replacement cancellation, and target projectile damage support.
- Confirmed weapon/ammo/reload, pickups, movement constants, crouch geometry, aim, jetpack, and camera were otherwise unchanged.
- Confirmed no manual UID files, generated Godot content, credentials, executables, caches, or historical report edits were included.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked project content.
- No Godot runtime testing was performed or claimed.

## Pending manual checks

- Launch Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Test right, left, up-right, up-left, down-right, and down-left dash directions, including direct vertical and origin cursor positions.
- Confirm the dash never exceeds 60 degrees from horizontal and faces the selected horizontal side.
- Verify movement/gravity/jetpack suppression during dash and normal physics recovery afterward.
- Verify debug hitbox visibility, once-per-dash damage, capped knockback, target collision, and projectile damage.
- Verify rapid C presses, cooldown persistence through exact leg swaps, active dash cancellation, HUD states, and Standard Legs no-op.
- Recheck weapons, two slots, pickups, movement, crouch, aim, facing, jetpack, camera, targets, and native 1280x720 presentation.

## Known risks or limitations

Godot runtime/parser validation was unavailable in this environment. Collision overlap timing and AnimatableBody2D knockback behavior require Windows validation. Final Knee Dash animation/effects, invulnerability, bleeding, and camera shake remain out of scope.

## Recommended next step

Run the focused Windows directional dash and collision checklist, then tune dash feel only after confirming the approved 60-degree behavior.
