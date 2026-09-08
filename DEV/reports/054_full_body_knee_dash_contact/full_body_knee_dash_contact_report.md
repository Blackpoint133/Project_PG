# Task 054: Full-Body Knee Dash Contact

## Objective

Replace the offset Knee Dash attack Area2D with the Player's existing CharacterBody2D movement collisions so any living enemy contact during an active dash can receive the existing damage and knockback.

## Audited root cause

The previous implementation used a separate 64x28 Area2D near the legs, so contact outside that small offset shape could not damage an enemy even though the Player body collided with it.

## Completed changes

After the existing Knee Dash `move_and_slide()` call, Player forwards each frame `KinematicCollision2D` collider to `KneeDashController.process_contact(contact: Node)`. The controller rejects invalid, inactive, non-collision-object, non-enemy-layer, and non-`take_damage` contacts. Valid targets are tracked for the full dash, damaged once, knocked back when they expose `apply_knockback`, and reported through the existing `target_hit` signal.

## Exact changed file list

- `Game/scripts/abilities/knee_dash_controller.gd`
- `Game/scripts/player.gd`
- `Game/scenes/player.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/054_full_body_knee_dash_contact/full_body_knee_dash_contact_report.md`

## Contact architecture

The old attack Area2D, its 64x28 CollisionShape2D, `knee_dash_hitbox_shape`, and red `DebugVisual` were removed from the Player scene. The Player's existing collision shape remains unchanged and is the sole Knee Dash contact geometry. Player still assigns dash velocity and calls `move_and_slide()` exactly once in the existing dash branch.

## Collision filtering and damage

`KneeDashController` accepts a generic `Node`, requires a valid `CollisionObject2D` on enemy collision layer bit value 4 (logical layer 3), and requires the `take_damage` method contract. It does not import or cast to `TargetDummy`. World, floor, platform, wall, defeated, and incompatible contacts are not damaged. Once-per-dash tracking and the existing contact damage and knockback values are preserved.

## Preserved gameplay values

The 45-degree direction clamp, dash speed, duration, contact damage 25, knockback strength, cooldown, exact LegInstance cooldown ownership, Standard Legs behavior, solid living-enemy collision, defeated-target passability, and all unrelated movement and ability systems remain unchanged. Bleeding remains deferred to Task 055.

## Checks actually performed

- Required clean base and branch verification passed at `e050a300db4197a4e67369b1f0ee36fc2a5e7440`.
- Complete diff reviewed; only the seven allowed Task 054 files are intended to change.
- `git diff --check` and staged diff checks passed.
- Player scene no longer contains `Hitbox`, its CollisionShape2D, `knee_dash_hitbox_shape`, or `DebugVisual`.
- KneeDashController no longer references `Area2D`, overlap polling, monitoring, or debug visual logic.
- Player forwards slide collisions after the existing dash movement call and retains only the two mutually exclusive `move_and_slide()` calls.
- Generic enemy-layer filtering and once-per-dash tracking were statically verified.
- `Game/project.godot`, resources, target scripts/scenes, HUD, and unrelated systems remained untouched.
- Cyrillic scan excluding `.git` passed.
- No Godot executable was available; parser, runtime, and visual validation were not performed.

## Pending Windows runtime checks

Test lower-leg, torso, and elevated-target contacts; exactly 25 damage once per dash; knockback; defeated-target passability; walls and platforms; and regressions for Slide, Hook, grapple, Jetpack, Shield, weapons, crouch, pickups, and HUD.

## Known risks or limitations

Contact dispatch depends on the enemy body participating in Player `move_and_slide()` collisions and exposing the generic damage method. Final bleeding and production contact effects remain deferred.

## Recommended next step

Run the Windows runtime checklist and then implement the approved Knee Dash bleeding debuff in Task 055.

## Implementation commit and push result

Implementation commit: `b1df00cbe49dbdc1083a3fd3661a1f67f2b39b96` (`fix: use player body for knee dash hits`). It was pushed normally to `origin/main`; after the push, local HEAD and `origin/main` matched and the working tree was clean. The final report and Project Context publication record are committed separately with the required documentation commit.
