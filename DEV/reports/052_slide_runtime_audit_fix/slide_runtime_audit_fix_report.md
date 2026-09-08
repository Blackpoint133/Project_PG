# Task 052: Slide Runtime Advancement and Momentum Audit Fix

## Objective

Correct the missing SlideController advancement and preserve the latest slide momentum through a slide-to-jump transition without changing slide tuning or unrelated movement systems.

## Exact changed files

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/052_slide_runtime_audit_fix/slide_runtime_audit_fix_report.md`

## Audited root causes

The published Task 051 Player integration never called `slide_controller.advance(delta)`, so active duration, deceleration, and cooldown could not progress. The slide-jump path also cancelled the controller before copying its latest signed velocity, allowing ordinary grounded movement to reduce momentum on the jump frame.

## Corrections

Player now advances SlideController exactly once before reading slide state or processing new slide entry. The slide-jump path copies `get_horizontal_velocity()` into `Player.velocity.x`, cancels the slide, starts cooldown, and sets a focused `_slide_jump_momentum_active` flag. The exception preserves no-input airborne momentum and prevents same-direction input from immediately reducing inherited speed; opposing input retains normal air control. Landing clears the exception. Knee Dash and world grapple ownership clear it.

The final crouch state is computed after landing-slide detection and is then applied once to Shield and the modular Player pose, preventing a standing-pose flash on landing-slide entry.

## Physics ordering and preserved ownership

The advancement call runs for Knee Dash, grapple, airborne, and grounded movement because it is outside the movement branches. Player remains the only writer of velocity and caller of `move_and_slide()`. No additional movement call or tuning change was introduced.

## Static validation

- Required base was verified as `012c18ef0b6832cd0a44d55d12aa960c16b33f3e` for both local HEAD and `origin/main`.
- Complete diff scope was reviewed.
- `git diff --check` and staged diff checks passed.
- `slide_controller.advance(delta)` appears exactly once in `_physics_process()` before slide state reads.
- Slide tuning remains unchanged: 260.0 entry, 600.0 minimum initial, 0.65 seconds, 720.0 deceleration, 180.0 minimum active, and 1.0 second cooldown.
- `Game/project.godot`, scenes, resources, SlideController, HUD, and Task 051 report remain untouched.
- Player retains the existing two mutually exclusive `move_and_slide()` calls.
- Cyrillic scan excluding `.git` passed.
- No Godot executable was available; parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows validation remains pending for slide duration, deceleration, cooldown, held-Ctrl non-retriggering, slide-jump momentum, landing pose synchronization, walls, enemies, grapple, Knee Dash, jetpack, Shield, weapons, and HUD.

## Known risks or limitations

The momentum exception is intentionally focused on slide-derived airborne motion and uses existing Player air-control behavior for opposing input. Final feel and balancing remain pending runtime validation.

## Recommended next step

Run the Windows runtime checklist and verify the slide state transitions against actual collision and landing behavior.

## Commit and push results

Implementation commit: `ffb65d136a69019efce620f27392a439a9657067` (`fix: advance slide runtime state`). It was pushed normally to `origin/main`; after the push, `HEAD` and `origin/main` both resolved to `ffb65d136a69019efce620f27392a439a9657067` and the working tree was clean. The report and Project Context publication record are finalized in the separate docs commit required for this task.

## Windows runtime checklist

1. Run and press Ctrl while moving; verify the slide ends after approximately 0.65 seconds and decelerates.
2. Verify the one-second cooldown reaches READY and held Ctrl does not retrigger.
3. Jump during a slide and verify the latest horizontal momentum is preserved on the jump frame and in the air.
4. Verify same-direction airborne input does not immediately reduce inherited speed and opposite input can steer.
5. Hold Ctrl through a fast landing and verify one slide with no standing-pose flash and crouched Shield height.
6. Test walls, living enemies, grapple, Knee Dash, jetpack heat, Shield, weapons, pickups, crouch visuals, and HUD.
7. Confirm no Godot parser or runtime errors.
