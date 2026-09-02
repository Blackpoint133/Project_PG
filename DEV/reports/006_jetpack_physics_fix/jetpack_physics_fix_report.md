# Report: 006_jetpack_physics_fix

## Task objective

Fix the audited jetpack physics so a grounded jump authorizes controlled sustained flight while Space is held, landing always clears authorization, and falling or walking off a platform with Space held cannot activate the jetpack. Mouse aiming and all other existing behavior remain unchanged.

## Root cause

The previous implementation applied gravity and a 620-unit upward thrust in the same frame while the default 2D gravity is approximately 980. The net vertical acceleration therefore remained downward. The thrust also ended with `maxf(..., -140)`, which immediately clamped the -420 jump velocity to -140 and removed the jump's upward momentum. The `_jetpack_allowed` flag only cleared when Space was released while grounded, so it could remain stale after landing with Space still held. The movement state additionally reported `jetpack` from raw input rather than the actual jetpack-active result.

## Completed changes

- Renamed the hold flag to `_jetpack_authorized` and set it only when a grounded jump starts.
- Set the jump velocity in the same grounded-press branch.
- Unconditionally cleared the authorization on every grounded frame except the jump-press frame.
- Restricted jetpack thrust to an authorized airborne hold.
- Replaced the insufficient-thrust plus `maxf` clamp model with a smooth `move_toward` approach to a negative target rise velocity.
- Kept gravity on airborne frames when the jetpack is inactive and kept the existing fall-speed cap.
- Grouped the vertical tuning constants under a `Vertical tuning` comment.
- Passed the actual `jetpack_active` value into the movement-state update so the HUD reports real flight state.

## Exact changed files

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/006_jetpack_physics_fix/jetpack_physics_fix_report.md`

## Implemented flight model

Vertical tuning is now explicit:

- `JUMP_VELOCITY = -420.0` — unchanged grounded jump.
- `JETPACK_TARGET_RISE_VELOCITY = -240.0` — controlled upward flight target in Godot's negative Y direction.
- `JETPACK_ACCELERATION = 2400.0` — smoothing authority used with `move_toward` toward the rise target.
- `MAX_FALL_SPEED = 420.0` — unchanged airborne fall cap.

Activation rules:

- A grounded Space press sets the jump velocity and authorizes the jetpack for that jump.
- While airborne, holding Space activates thrust and smoothly approaches the rise target.
- Releasing Space stops thrust on the next physics frame and normal gravity resumes.
- Every grounded frame clears authorization unconditionally, including landing with Space held.
- Walking or falling from a platform with Space held does not activate thrust because no grounded jump authorized it.

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main` before changes.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Confirmed `Game/project.godot` input mappings remain unchanged.
- Confirmed the mouse-aim implementation remains unchanged.
- Scanned all tracked repository content outside `.git` for Cyrillic characters: zero matches.
- Confirmed no `.uid` files were modified.

## Pending Windows manual checks

Godot runtime validation was not performed on this machine. The following checks remain required locally:

- A short Space press performs a normal jump.
- Holding Space after the grounded jump provides clearly visible sustained upward flight.
- Releasing Space stops thrust immediately and restores normal falling.
- Landing deactivates the jetpack even when Space remains held.
- Walking or falling from a platform while Space is already held does not activate thrust.
- The elevated test platforms are reachable.
- The HUD shows `jetpack` during actual thrust and `airborne` after release.
- A/D movement, crouching, mouse aim, camera follow, collision behavior, and the arena remain unchanged.

## Risks or limitations

- Flight feel must still be tuned on Windows if the rise target or acceleration does not feel right.
- Jetpack heat remains deferred by the approved scope.
- The HUD and visuals remain temporary placeholders.

## Recommended next step

Perform the local Windows checklist in Godot 4.7.2 Standard and record any flight-feel tuning changes as a separate focused task.
