# Report: 005_movement_validation_fixes

## Task objective

Diagnose and fix the two validated movement-foundation bugs: jetpack thrust did not activate when Space remained held after jumping, and horizontal mouse-aim direction was reversed. No new gameplay features were added.

## Reported symptoms

- Holding Space after jumping did not activate the jetpack. The player fell normally and could not reach the elevated platforms.
- Vertical mouse aiming worked, but horizontal aiming was reversed: moving the mouse right pointed the aim line left, and moving the mouse left pointed it right.

## Diagnosed root causes

### Jetpack bug

`player.gd` computed jetpack activation directly from `Input.is_action_pressed("jump")` combined with `not was_on_floor`. Because the jump starts on the ground and `is_on_floor()` remains true for the physics frame that starts the jump, the first airborne frame never registered the held key as a jetpack intent. The state was recomputed every frame instead of tracking a hold intent through the jump.

The fix introduces a `_jetpack_allowed` hold flag. It becomes true when a grounded jump starts, clears when Space is released while grounded, and only allows thrust while the player is actually airborne and still holding Space. Thrust continues to use the negative Y direction and remains capped at the controlled rise speed. Landing clears the intent on the next grounded frame where Space is not held, so the jetpack cannot reactivate while standing on the floor.

### Mouse-aim bug

`player.gd` clamped the `AimPivot` rotation into the front-facing half circle after calling `look_at()`. That post-transform mirrored the true world-space direction when the cursor was behind the pivot, producing the reported horizontal inversion.

The fix removes the rotation clamp. `AimPivot` now receives an unconditional world-space rotation from `look_at(get_global_mouse_position())`, so the aim line points directly toward the cursor in every quadrant. Body-facing responsibility was not implemented in this scene and was not added; the aim pivot remains independent of any future facing flip.

## Exact files changed

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/005_movement_validation_fixes/movement_validation_fixes_report.md`

## Implemented corrections

- Added the `_jetpack_allowed` hold flag and integrated it into the jetpack activation check.
- Removed the aim-rotation clamping branch.
- Updated `DEV/docs/PROJECT_CONTEXT.md` with the local validation findings and corrected status.

## Validations actually performed

- Ran `git pull --ff-only` and confirmed `HEAD` includes commit `0f1a8ea chore: sync Godot editor metadata`.
- Ran `git diff --check`: passed.
- Scanned all tracked project content outside `.git` for Cyrillic characters: zero matches.
- Reviewed the complete Git diff before commit.
- Confirmed existing `.uid` files were preserved exactly.

## Deferred local Godot runtime validation

Godot was not executed on this machine. Local Windows retest is still required to confirm:

- holding Space after jumping activates controlled jetpack thrust;
- releasing Space stops thrust immediately;
- landing deactivates the jetpack;
- the jetpack does not activate while standing on the floor;
- the aim line points toward the cursor in every quadrant;
- the HUD shows `jetpack` while thrust is active and `airborne` after release;
- the elevated platforms are reachable.

## Remaining limitations

- The arena and player visuals remain placeholder primitives.
- The HUD remains temporary.
- Body-facing visuals, equipment sockets, weapons, enemies, equipment swapping, damage, missions, shield, hook, and knee dash remain deferred.
- Jetpack heat is not implemented yet.
