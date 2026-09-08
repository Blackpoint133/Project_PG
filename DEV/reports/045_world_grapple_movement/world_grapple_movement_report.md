# Task 045: World Grapple Movement

## Required and actual base commit

Required base: `27b0d2352b48b72f6070f83dd6e3a20c6a21153c`.

The clean `main` branch was fast-forwarded with `git pull --ff-only` and verified at the required base before editing.

## Exact changed files

- `Game/scripts/abilities/hook_controller.gd`
- `Game/scripts/abilities/hook_projectile.gd`
- `Game/scripts/player.gd`
- `Game/scripts/equipment/right_arm_ability_definition.gd`
- `Game/resources/equipment/hook_ability.tres`
- `Game/scripts/hud.gd`
- `Game/scenes/player.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/045_world_grapple_movement/world_grapple_movement_report.md`

## Previous behavior

Task 043/044 stopped the Hook on world impact after preserving enemy pull, but did not provide Player movement toward a solid world surface. The projectile already reported collision bodies, while world collision positions were not retained as a Player grapple anchor.

## Implemented state model

`HookController` now distinguishes `idle`, `extending`, `pulling`, and `grappling`. Enemy-compatible bodies continue through the generic pull contract. Valid solid world-layer hits enter `grappling` with the exact raycast collision position. The controller owns the anchor, cable, marker, duration, arrival, and meaningful-progress obstruction bookkeeping.

## Enemy-versus-world collision routing

Hook-compatible method checks run first. Incompatible bodies can start a grapple only when they are `CollisionObject2D` instances on world layer 1. Incompatible enemies and unrelated bodies therefore stop the Hook without becoming anchors. The projectile forwards the exact collision position and safely handles invalid collision data.

## Player velocity ownership decision

Player remains the only owner of `CharacterBody2D.velocity` and the only caller of `move_and_slide()`. During world grappling, Player adds acceleration toward the fixed world anchor to the existing velocity, preserves tangential momentum, caps total speed at the authored maximum, applies normal gravity once when appropriate, and performs the existing single movement call. HookController never moves Player directly.

## Exact tuning values

- Player grapple acceleration: `3200.0`
- Player grapple maximum speed: `1200.0`
- Player grapple arrival distance: `56.0`
- Maximum Player grapple duration: `2.0`
- Meaningful-progress obstruction timeout: `0.25`

Enemy pull speed, stop distance, maximum duration, stun duration, projectile speed/range, and three-second right-arm cooldown remain unchanged.

## Detach paths

- Manual E cancellation while any Hook state is active.
- Space cancellation, with airborne jetpack authorization preserved for the existing same-frame/next-frame flight path.
- Automatic arrival at the configured distance.
- Maximum grapple duration expiry.
- Meaningful progress obstruction timeout.
- Invalid Hook origin, ability, anchor, or arm replacement through the existing right-arm visual change handler.
- Successful Knee Dash start.

Every path hides the cable and fixed anchor marker, clears only Hook state, preserves Player velocity, and does not alter or restart the exact-instance cooldown. Enemy pull, projectile extension, and world grapple remain mutually exclusive.

## Jetpack and Knee-Dash behavior

A world grapple authorizes airborne jetpack follow-up until landing. Space detaches before normal jetpack processing, and existing jetpack acceleration then modifies only the existing vertical component. A successfully started Knee Dash cancels Hook state before dash movement takes ownership; existing dash velocity, tuning, hitbox, damage, knockback, cooldown, and direction remain unchanged.

## Cooldown ownership and behavior

The three-second cooldown remains on `RightArmInstance.ability_cooldown_remaining` and is advanced by `RightArmEquipmentController`. Grapple detachment never changes it. A new Hook request is possible only after the controller is idle and that exact instance cooldown reaches zero.

## Cable and anchor transform handling

The far world endpoint is stored in global coordinates. Each update converts both HookOrigin and the fixed world anchor with `HookController.to_local()`. The visible `GrappleAnchor` Polygon2D is positioned from the same conversion, so cable and marker stay fixed in world space while Player moves and never jump to the viewport corner.

## Regression boundaries

No changes were made to `Game/project.godot`, arena geometry, weapons, ammunition, Shield, legs, Knee-Dash tuning, enemy health/damage/stun/knockback, interaction, pickup ownership, movement constants, camera limits, or final art.

## Validation performed

- `git status --short`, `git fetch origin`, `git pull --ff-only`, branch, and exact base verification passed.
- Complete changed scripts, scene, resource, and documentation diff reviewed.
- `git diff --check` passed.
- `git diff --stat` reviewed.
- `Game/project.godot` diff is empty; arena scene is untouched.
- HookController has no `TargetDummy` dependency.
- Player remains the only changed caller/owner of Player `velocity` and `move_and_slide()`; the dash and normal branches each retain one movement call.
- Enemy pull tuning and right-arm cooldown ownership remain unchanged.
- All detach paths were statically reviewed for velocity preservation.
- Repository Cyrillic scan excluding `.git` passed.
- Godot executable was not available, so parser, runtime, and visual validation were not performed.

## Windows visual/runtime checklist

- Launch the project and confirm no Godot parse/runtime errors.
- Equip Hook Right Arm and fire at a solid floor, wall, and platform from multiple aim directions.
- Confirm the projectile anchors at the exact impact point and Player retracts toward it without teleporting.
- Confirm cable and amber anchor marker remain fixed in world space while Player moves.
- Confirm Player retains tangential velocity and does not stop merely from floor contact.
- Confirm arrival, E, Space, obstruction, timeout, arm swap, and Knee-Dash detach paths preserve momentum and hide cable/marker.
- Confirm Space during airborne grapple transitions into existing jetpack flight and landing clears authorization.
- Confirm enemy Hook hits still pull/stun the enemy and do not move Player.
- Confirm Hook cooldown, weapons, Shield, Knee Dash, movement, crouch, and interaction remain unchanged.

## Commit and push results

Implementation commit: `93b771acca7a5284f3d76861ea2574d44403b043` (`feat: add world grapple movement`). The commit was pushed normally to `origin/main`; remote verification confirmed the published commit and a clean working tree. Godot runtime validation remains pending because the Godot executable is unavailable in this environment.

## Recommended next step

Run the Windows runtime checklist with grounded and airborne world anchors, then evaluate grapple feel before adding any rope-swing or jetpack heat work.
