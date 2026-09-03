# Task 035: Solid Enemy Collision and Stronger Knee-Dash Knockback

## Objective

Make living enemies physically block the Player through the existing CharacterBody2D collision resolution and increase the TargetDummy placeholder horizontal knockback cap to match the authored Knee-Dash impulse.

## Confirmed root causes

- The Player collision mask was `1`, so it detected world layer 1 but not TargetDummy collision layer 4.
- TargetDummy clamped horizontal knockback to `320.0`, limiting the authored `640.0` Knee-Dash impulse.

## Exact changed file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/035_solid_enemy_collision_and_knockback/solid_enemy_collision_and_knockback_report.md`
- `Game/scenes/player.tscn`
- `Game/scripts/targets/target_dummy.gd`

## Collision-layer and mask contract

Player remains on collision layer 2 and now uses collision mask 5, detecting world layer 1 and enemy layer 4. TargetDummy remains on collision layer 4 with collision mask 0. No collision exceptions or manual position blocking were added; living enemy blocking uses the existing `CharacterBody2D` and `move_and_slide()` resolution. TargetDummy still clears logical enemy layer 3 when defeated, so a disabled target may become passable.

## Exact knockback tuning

`TargetDummy.KNOCKBACK_MAX_SPEED` is now an explicitly typed `640.0` cap. Horizontal-only knockback still lasts `0.18` seconds and decelerates at `1800.0`. No vertical target physics, gravity, bouncing, ragdoll, or enemy-world collision was added.

## Preserved behavior

The 45-degree Knee-Dash direction clamp, Task 033 direction construction, dash speed and duration, 64x28 attack hitbox, contact damage 25, cooldown 1.5, once-per-target tracking, and movement-priority behavior are unchanged. Weapons, ammunition, reloads, pickups, leg ownership, crouching, aiming, jetpack, HUD, interaction, inputs, and project settings are unchanged.

## Checks actually performed

- Confirmed the required base commit and clean preflight state.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed Player layer 2/mask 5 and TargetDummy layer 4/mask 0.
- Confirmed defeated targets still call `set_collision_layer_value(3, false)`.
- Confirmed the knockback cap is exactly `640.0`, with duration `0.18` and deceleration `1800.0` unchanged.
- Confirmed no UID files, project settings, weapon files, or unrelated scenes/scripts were changed.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked content.
- No Godot runtime test was performed or claimed.

## Pending Windows runtime checks

Verify that living targets block walking, jumping/falling, jetpack movement, and Knee Dash; verify the player cannot cross through an active target; verify the 640.0 horizontal knockback is visibly stronger; and verify defeated gray targets become passable.

## Known limitations

TargetDummy knockback remains a deterministic horizontal placeholder. It does not add vertical physics, world collision, impact stopping, bouncing, recoil, or general enemy AI.

## Recommended next step

Run the focused Windows collision and knockback checklist with a living target, then repeat after defeating it to confirm the intended passability transition.
