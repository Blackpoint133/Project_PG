# Task 043: Hook Pull Runtime

## Goal

Implement the first complete Hook Right Arm runtime: discrete full-direction E firing, a visible world-blocked hook projectile and cable, world-aware enemy pulling, brief stun, and exact-instance cooldown persistence without Hook damage.

## Completed changes

- Added typed Hook tuning fields and authored the required projectile, range, pull, stop, stun, and cooldown values.
- Added `HookProjectile` with integer placeholder geometry, player-attack collision settings, continuous segment raycast movement, one-collision resolution, and cleanup signals.
- Added `HookController` with idle, extending, and pulling states, transform-safe cable endpoints, cancellation, target tracking, and pull timeout handling.
- Added a direct `HookOrigin` marker to the Hook Right Arm visual and bound it whenever the held visual is rebuilt.
- Added exact per-instance right-arm cooldown progression and state signaling.
- Converted `TargetDummy` to `CharacterBody2D` and added typed hook pull, cancellation, anchor, and stun APIs while preserving damage, knockback, solidity, and defeated-target behavior.
- Added signal-driven HUD states for Hook ready, firing, pulling, and cooldown.
- Updated active design/context documentation.

## Exact changed file list

- `Game/scripts/equipment/right_arm_ability_definition.gd`
- `Game/scripts/equipment/right_arm_instance.gd`
- `Game/scripts/equipment/right_arm_equipment_controller.gd`
- `Game/scripts/abilities/hook_projectile.gd`
- `Game/scripts/abilities/hook_controller.gd`
- `Game/scenes/projectiles/hook_projectile.tscn`
- `Game/resources/equipment/hook_ability.tres`
- `Game/scripts/targets/target_dummy.gd`
- `Game/scenes/targets/target_dummy.tscn`
- `Game/scenes/player/modules/placeholder_hook_right_arm.tscn`
- `Game/scripts/player.gd`
- `Game/scenes/player.tscn`
- `Game/scripts/hud.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/043_hook_pull_runtime/hook_pull_runtime_report.md`

## Runtime architecture

Player routes the typed Hook request to `HookController`. The controller instantiates and configures the projectile before adding it to the world. It owns one projectile and one target at a time, with explicit idle, extending, and pulling states. The player is never pulled by the Hook.

## Projectile collision approach

The projectile uses player-attack layer 4 (integer 8) and mask 5 for world layer 1 and enemy layer 3. Each physics step performs a segment raycast from the previous position to the proposed position, preventing high-speed tunneling through platforms or targets. The first collision resolves the projectile; the projectile never calls `take_damage`.

## Cable transform handling

The cable is a Line2D under the direct Player child `HookController`. Its endpoints are global positions converted with `to_local()`, so the line follows Player movement and the AimPivot-attached HookOrigin without screen-origin placement or global-transform synchronization.

## Target pull and stun contract

Living `TargetDummy` instances expose `begin_hook_pull`, `cancel_hook_pull`, `is_hook_pull_active`, `get_hook_anchor_position`, and `is_hook_stunned`. A pulled target uses CharacterBody2D movement with world mask 1, moves toward the Player at 960 pixels/second, stops at 72 pixels from the Player anchor, and ends on world collision. `HookController` owns the 0.75-second timeout. Stun lasts one second with a temporary cyan tint. No Hook damage is applied.

## Exact tuning values

- Projectile speed: `1200.0`
- Maximum range: `720.0`
- Pull speed: `960.0`
- Stop distance: `72.0`
- Maximum pull duration: `0.75`
- Stun duration: `1.0`
- Cooldown: `3.0`
- Hook damage: `0`

## Cooldown ownership

`RightArmInstance.ability_cooldown_remaining` owns the runtime cooldown. The controller advances only the equipped instance, emits typed state updates, rejects E during cooldown, and does not reset cooldown when an exact instance is moved between Player and pickup.

## Preserved behavior and deferred scope

Weapon behavior, shield behavior, Knee Dash, movement, crouching, jetpack, interaction, pickup ownership, arena layout, input mappings, and project settings remain unchanged. Hook damage, bleeding, rope simulation, player grappling, multiple hooks, sound, camera effects, final artwork/animation, and production enemy AI remain deferred.

## Checks actually performed

- Required base was fast-forwarded with `git pull --ff-only`.
- Branch, clean preflight, and exact base commit were verified.
- Scene and resource references were reviewed statically.
- Collision layers and masks were reviewed statically.
- Typed API, signal, cooldown, projectile configuration, and target contract were reviewed.
- `git diff --check` and `git diff --cached --check` passed.
- Exact staged file scope, scene/resource references, collision settings, forbidden-scope checks, and complete staged diff review passed.
- Repository-wide Cyrillic scan excluding `.git` passed.
- `Game/project.godot` and `Game/scenes/arena.tscn` are untouched; no UID, generated, or imported files were added.

## Pending Windows runtime checklist

- Launch the normal project and confirm no parse/runtime errors.
- Equip Hook Right Arm with F and confirm its compact visual and `HookOrigin`.
- Aim E in right, left, up, down, and diagonal directions; confirm full-direction projectile travel.
- Confirm the amber hook head and cable originate at the arm emitter and never appear at screen origin.
- Confirm world platforms stop the projectile and clear the cable.
- Confirm a living target is pulled toward the Player, stops without overlap, remains solid, and shows the cyan stun tint.
- Confirm no target health changes from Hook use.
- Confirm E cooldown lasts three seconds and survives dropping/re-equipping the exact Hook instance.
- Confirm Standard Right Arm cancels active Hook state and shows `E: NONE`.
- Confirm rifle, shotgun, Shield, Knee Dash, movement, crouch, jetpack, and F interaction remain functional.

## Known risks or limitations

Godot 4.7.2 is not available in this environment, so parser, runtime, collision, and visual validation were not performed. Target pull uses a focused CharacterBody2D contract and does not implement production enemy AI or final obstacle behavior beyond world collision.

## Recommended next step

Run the Windows Godot validation checklist, then tune target pull presentation and implement the deferred production Hook effects only after the focused runtime is confirmed.

## Commit and push results

Implementation commit: `302566ebb6b66d07d0ebeed457fe3da3849ad0a6` (`feat: add hook pull runtime`). The commit was pushed normally to `origin/main`, and remote verification confirmed that `HEAD` matched `origin/main` with a clean working tree. Godot runtime validation remains pending because Godot is unavailable in this environment.
