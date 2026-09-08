# Task 044: Hook Pull Collision Audit Fix

## Audit findings

Task 043 had two runtime architecture defects and one documentation inconsistency. Grounded pulls targeted Player feet and could be cancelled by ordinary floor slide contact. `HookController` also stored and cast every target as `TargetDummy`, and the technical documentation incorrectly described the target collision mask as zero.

## Root causes

- `TargetDummy` calculated pull direction from its hook anchor toward `Player.global_position`, producing a downward component for grounded actors.
- Any non-zero `get_slide_collision_count()` cancelled a pull, including tangential floor contact.
- `HookController` used a concrete `TargetDummy` field and cast instead of the reusable hook-compatible method contract.
- `TECHNICAL_DESIGN.md` retained the pre-pull `collision_mask = 0` description.

## Exact changed files

- `Game/scenes/player.tscn`
- `Game/scripts/player.gd`
- `Game/scripts/abilities/hook_controller.gd`
- `Game/scripts/targets/target_dummy.gd`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/044_hook_pull_collision_audit_fix/hook_pull_collision_audit_fix_report.md`

## Corrected pull-anchor geometry

`BodyRoot/HookPullAnchor` is a direct `Marker2D` child authored at integer local position `Vector2(0, -40)`. Player binds it to `HookController` through `set_player_pull_anchor(anchor: Node2D)`. Hook targets now calculate movement from their own `get_hook_anchor_position()` toward this stable Player anchor, keeping grounded pulls approximately horizontal while preserving the 72-pixel stopping distance.

## Genuine-obstruction logic

`TargetDummy` no longer cancels on any slide collision. It compares distance to the pull anchor before and after `move_and_slide()`. Tangential floor contact can continue while distance decreases; a wall, platform, or other obstruction that produces no meaningful progress cancels safely. The controller's existing 0.75-second timeout remains the final safety limit.

## Generic hook target contract

`HookController` stores the active target as `Node2D` and validates `begin_hook_pull`, `cancel_hook_pull`, `is_hook_pull_active`, and `get_hook_anchor_position` with StringName method checks. Dynamic return values are explicitly converted to `bool` or `Vector2`. Future enemy CharacterBody2D implementations can expose the same contract without modifying `HookController`.

## Preserved behavior

Hook damage remains zero. Hook tuning, projectile behavior, cooldown, HUD, input, weapons, Shield, Knee Dash, health, equipment ownership, arena layout, target health, bullet damage, knockback, living solidity, defeated pass-through, and idle floating target behavior remain unchanged. No UID or generated files were added.

## Validation performed

- Required clean base was verified at `8bfb3264b9c49d3e5d9eb3337483dfe1901901a1` after `git pull --ff-only`.
- Complete staged diff was reviewed.
- `git diff --check` and `git diff --cached --check` passed.
- Exact changed-file scope was confirmed.
- Anchor position, collision masks, generic contract checks, progress-based obstruction handling, and preserved target APIs were statically reviewed.
- `Game/project.godot` and `Game/scenes/arena.tscn` were confirmed untouched.
- Repository Cyrillic scan excluding `.git` passed.
- Godot runtime validation was not performed because the Godot executable is unavailable.

## Windows runtime checklist

- Launch the project and confirm no parse/runtime errors.
- Fire Hook at a grounded target and verify approximately horizontal pull toward the Player center anchor.
- Confirm floor contact alone does not terminate the pull.
- Confirm a wall or platform genuinely blocking progress ends the pull safely.
- Confirm the target stops approximately 72 pixels from the Player without overlap.
- Confirm a floating target remains stationary when idle and pulls correctly when hooked.
- Confirm stun tint, health, bullet damage, Knee-Dash damage/knockback, living solidity, and defeated pass-through remain correct.
- Confirm Hook still deals no damage and cooldown/swap behavior remains unchanged.

## Commit and push results

Implementation commit: `34fb1ddd1329dd7207a72b3a98ae5bb31fceef62` (`fix: correct hook pull collision`). The commit was pushed normally to `origin/main`; remote verification confirmed the published commit and a clean working tree. Godot runtime validation remains pending because the Godot executable is unavailable in this environment.

## Recommended next step

Run the Windows runtime checklist with grounded and floating targets, then continue only with focused Hook gameplay improvements supported by observed behavior.
