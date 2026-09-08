# Task 048: Hold-to-Maintain Hook Input

## Required and actual base

The requested base string contained an extra `cb` segment. The verified existing clean base was `8028ac44d62d8ab938e8de1ace97cb1a7e500c32`, matching the preceding published Task 047 commit.

## Objective

Change the Hook Right Arm from press-to-toggle behavior to press-and-hold maintenance, with release cancellation and cooldown beginning only after the Hook session ends.

## Exact changed files

- `Game/scripts/player.gd`
- `Game/scripts/abilities/hook_controller.gd`
- `Game/scripts/equipment/right_arm_equipment_controller.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/048_hold_to_maintain_hook/hold_to_maintain_hook_report.md`

## Previous behavior

The E input acted as a toggle: a second press cancelled an active Hook, and the right-arm controller started its cooldown when activation was requested. That allowed cooldown time to elapse during an active Hook session.

## Held-input lifecycle

Player accepts a new Hook only on `right_arm_ability` just-pressed, while idle, with an eligible exact current instance, no cooldown, and no active Knee Dash. Once started, the Hook remains active while E is pressed. Player also checks the held state every physics frame, so release or focus-loss-style missing release events cancel extending, enemy pulling, and Player grappling safely.

## Completion paths and idempotence

`HookController` owns a typed `hook_completed` signal and a session-active guard. A session begins only after `start_hook()` successfully installs the projectile and enters `extending`. All existing idle transitions converge through `_set_idle()`, which emits completion once and only once for the active session. Repeated cancellation and duplicate idle transitions cannot emit another completion.

Completion covers release, projectile miss or invalid impact, enemy pull completion or timeout, world arrival, world timeout, obstruction, Space cancellation, Knee Dash, right-arm replacement, invalid origin/target/anchor state, and existing safety cancellation paths.

## Cooldown timing and ownership

`RightArmEquipmentController` reserves the exact active `RightArmInstance` without starting or decrementing its new cooldown. On the single completion signal, it writes the authored three-second cooldown to that reserved instance and emits the current ability state. Cooldown ticking remains in the equipment controller. The controller can abandon an accepted request without cooldown when `start_hook()` fails before a genuine session begins.

## Exact-instance arm-swap behavior

Replacing the Hook arm invokes the existing right-arm visual-change cancellation. Completion applies the full cooldown to the reserved outgoing instance, not the newly equipped instance. The outgoing instance transfers to the pickup with its stored cooldown; re-equipping it preserves that state.

## Space, Knee Dash, and momentum

Space still cancels a Player world grapple before jetpack processing. A successfully started Knee Dash still cancels Hook state and clears grapple-derived momentum while retaining existing dash ownership. Hook cancellation never changes Player velocity, and Task 046/047 momentum preservation remains intact. C plus E protection still prevents a new Hook during active Knee Dash.

## HUD behavior and tuning

Existing `HOOK FIRING`, `HOOK PULLING`, `HOOK GRAPPLING`, cooldown countdown, and ready states remain signal-driven and unchanged in layout. Completion immediately exposes the full three-second cooldown. Projectile, enemy-pull, grapple, movement, and cooldown tuning values remain unchanged.

## Failed-start behavior

If the typed request reaches Player but the Hook origin or projectile configuration is invalid, Player calls the controller's abandonment method. No cooldown is started because no genuine Hook session began.

## Validation performed

- Clean branch, fetch, fast-forward check, and verified actual base passed.
- Complete focused source and documentation diff reviewed.
- `git diff --check` passed.
- Project settings, scenes, resources, HUD, UID files, weapons, Shield, legs, movement, and grapple tuning remained untouched.
- Session completion, release checks, failed-start abandonment, exact-instance reservation, cooldown timing, and idempotence were statically reviewed.
- Player retains at most one `move_and_slide()` call per physics frame and remains the sole velocity owner.
- Repository Cyrillic scan excluding `.git` passed.
- No Godot executable was available, so parser, runtime, and visual validation were not performed.

## Pending manual checks

Windows runtime validation remains pending for release during projectile flight, enemy pull, and world grapple; automatic completion while E remains held; arm replacement; cooldown countdown; Space and Knee Dash interactions; and normal weapon behavior.

## Known risks or limitations

Dropped off-screen RightArmInstance cooldowns retain the existing behavior and do not tick while unequipped. This task does not redesign that ownership model.

## Recommended next step

Run the Windows runtime checklist with E held and released at each Hook state, including focus-loss-style release recovery.

## Commit and push results

Implementation commit: `16c4bd240b2bba977faf6bcb98c6dcbe2179f93e` (`feat: make hook hold-to-maintain`). The commit was pushed normally to `origin/main` and remote verification passed. After the implementation push, `HEAD` and `origin/main` both matched `16c4bd240b2bba977faf6bcb98c6dcbe2179f93e`, and the working tree was clean. This report-only update records that publication result.

## Windows runtime checklist

- Equip Hook Right Arm and press E once; confirm one Hook fires.
- Hold E through extension, enemy pulling, and world grappling; confirm each state remains active.
- Release E during projectile flight, enemy pull, and Player grapple; confirm immediate cancellation and preserved velocity.
- Confirm cable, projectile, anchor marker, and enemy pull cleanup on release.
- Confirm every automatic completion starts exactly one full three-second cooldown.
- Hold E through cooldown completion and confirm no automatic refire; release and press again to fire.
- Replace the Hook arm while active and confirm cooldown belongs to the outgoing exact instance.
- Confirm Space and Knee Dash cancellation preserve existing jetpack, dash, and momentum behavior.
- Confirm Standard Right Arm remains passive and weapons remain unaffected.
