# Task 047: Grapple Momentum Ground-Contact Fix

## Objective

Correct the remaining Task 046 momentum lifecycle defect so temporary floor contact cannot clear grapple-derived airborne momentum while an active world grapple is still pulling the Player.

## Completed changes

Player now keeps `_world_grapple_momentum_active` enabled whenever `HookController` remains in its Player grappling state. The flag is cleared by the grounded condition only after the grapple is inactive. Ground friction still applies whenever the Player is actually grounded because the flag only bypasses the no-input damping branch while airborne.

The stale Task 045 documentation references to fixed future task numbers were replaced with semantic later-focused-task wording.

## Exact changed files

- `Game/scripts/player.gd`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/047_grapple_momentum_ground_contact_fix/grapple_momentum_ground_contact_fix_report.md`

## Lifecycle condition

- A successful world grapple still enables the flag through `player_grapple_started`.
- Active world grappling explicitly retains the flag even after `move_and_slide()` reports floor contact.
- E, Space, arrival, timeout, obstruction, and right-arm replacement remain velocity-preserving Hook detach paths.
- After Hook becomes inactive, the flag remains available while airborne and clears when the Player is grounded.
- Successful Knee Dash still clears the flag because Knee Dash replaces velocity.

## Preserved Task 046 behavior

Airborne no-input horizontal damping remains bypassed only for momentum inherited from a successful world grapple. Ordinary airborne movement, grounded friction, movement constants, grapple tuning, Player velocity ownership, and the one-call-per-frame `move_and_slide()` contract remain unchanged. C plus E protection remains intact: an active Knee Dash suppresses new Hook activation, while E still cancels an active Hook without starting cooldown.

## Validation performed

- Required clean base, branch, fetch, fast-forward, and exact HEAD/origin verification passed.
- Complete focused source and documentation changes were reviewed.
- `git diff --check` passed.
- Game/project.godot, all scenes, resources, HookController, HUD, weapons, Shield, equipment, and Knee Dash files remained untouched.
- Movement and grapple constants were reviewed as unchanged.
- The lifecycle condition was statically verified for active grapple retention, inactive airborne preservation, inactive grounded clearing, and grounded friction.
- Player remains the only owner of velocity and `move_and_slide()`; no more than one call exists in each physics branch.
- The repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending for platform contact during an active grapple, re-airborne momentum preservation, grounded friction, all detach paths, and simultaneous C plus E input.

## Known risks or limitations

This is a focused lifecycle correction and does not redesign grapple movement, detachment, tuning, or input ownership.

## Recommended next step

Run the Windows runtime checklist with a world grapple that slides across or briefly contacts a platform before becoming airborne again.

## Commit and push results

Implementation commit: `44b90664cd8e8110b213d6234c7b481097059f4f` (`fix: retain momentum through grapple ground contact`). The commit was pushed normally to `origin/main` and remote verification passed. After the implementation push, `HEAD` and `origin/main` both matched `44b90664cd8e8110b213d6234c7b481097059f4f`, and the working tree was clean. This report-only update records that publication result.

## Windows runtime checklist

- Launch the project and confirm no Godot parse or runtime errors.
- Start a world grapple while airborne and confirm horizontal momentum persists after temporary platform contact.
- Confirm an active grapple pulling the Player airborne again still bypasses no-input horizontal damping.
- Confirm grounded grapple movement still applies ordinary ground friction.
- Confirm E, Space, arrival, timeout, obstruction, and right-arm replacement preserve airborne momentum.
- Confirm successful Knee Dash clears grapple-derived momentum and retains existing dash behavior.
- Press C and E together and confirm no new Hook starts during the active dash.
- Confirm ordinary jumps and airborne movement retain their original damping.
