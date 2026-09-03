# Project Context

## Current status

The bootstrap project is complete. The approved vertical slice and modular gameplay architecture are documented in `DEV/docs/GAME_DESIGN.md` and `DEV/docs/TECHNICAL_DESIGN.md`.

The playable movement foundation is implemented with a test arena, character movement, crouching, jumping, mouse aim indication, jetpack flight, and a temporary movement-state HUD.

Local Godot 4.7.2 validation confirmed movement, crouching, jumping, vertical mouse aiming, and camera follow. It also found two movement-foundation bugs: the jetpack did not activate when Space remained held after a jump, and the horizontal aim direction was reversed. Both bugs were corrected in the movement validation fix. Weapons, enemies, missions, equipment swapping, and final UI are deferred.

Task 006 applied a focused jetpack physics correction after a full repository audit. The flight model now uses a jump-authorized hold flag, unconditionally clears the flag on landing, and smoothly approaches a controlled negative rise velocity instead of applying insufficient thrust with an abrupt clamp. The temporary HUD reports the actual jetpack-active state. Local Windows gameplay validation is still required.

Task 007 replaced the combined placeholder character visual with a modular visual hierarchy. Body, legs, left arm, right arm, weapon, and jetpack are now separate placeholder scene instances under stable `BodyRoot` and `AimPivot` paths. Gameplay movement, jetpack physics, input mappings, aiming, camera, and collision behavior are preserved. Local visual verification is still pending.

Task 008 cleaned the modular placeholder foundation after a repository audit. The placeholder module scenes no longer reference unnecessary no-op scripts, and the body-plus-legs silhouette now covers the intended 12x28 area without a gap. Local visual verification remains pending.

Task 009 corrected the foot-anchored collision and crouch pose, added mouse-based horizontal facing with a dead zone, flipped body, legs, and jetpack without flipping `BodyRoot`, and moved arm and weapon pivots to the shoulder origin. The user-reported Task 008 visual defects were used as the validation basis. Local Windows visual verification is still required.

Task 010 corrected the audited crouch offset sign and aim-guide origin. Crouching now moves the upper-body modules down by 10 pixels, `AimPivot` moves from Y -18 to Y -8, the standing pose is initialized before the first physics frame, and `AimLine` starts at the temporary weapon muzzle X 17. Local Windows visual verification is still required.

Task 011 reduced the crouching visual offset from 10 to 4 pixels after Windows testing showed the torso sinking too far into the legs. The collision shape and ground anchoring are unchanged. Local Windows re-check of the crouch pose is still required.

Task 012 added the automatic rifle combat foundation: data-driven weapon definition, weapon controller, visible projectiles, ammunition, manual reloading, damage, stationary target dummies, and a weapon/ammo HUD. Movement, crouch pose, jetpack physics, facing, aiming, and modular visual structure are preserved. Local Windows combat validation is still required.

Task 013 repaired the audited rifle integration: attached the weapon controller script, corrected logical collision bits, moved projectile tuning into `WeaponDefinition`, aligned target collision with visuals, and exposed public read-only ammunition to the HUD. Local Windows combat validation is still required.

Task 014 corrected the projectile lifecycle so configuration completes before the projectile enters the scene tree, added a safe zero-direction fallback, removed duplicate ammunition state from the controller, and made the HUD cache ammunition through focused signal updates instead of per-frame reads. Local Windows combat validation is still required.

Task 015 fixed the remaining rifle projectile parse blocker by declaring an explicit movement-velocity field, protected the RELOADING label from ammunition signals, and freed a failed projectile cast before returning. Local Windows combat validation is still required.

Task 016 added a standalone player-scale calibration scene comparing 28, 40, and 48 logical-pixel silhouettes at the real viewport size. The final gameplay player scale has not been chosen yet.

Task 017 migrated the prototype to native 1280x720 rendering and selected the 96-pixel base player scale. Active gameplay geometry, positions, collision, camera limits, projectile dimensions, target scale, spatial movement constants, and effective gravity are doubled. Time-based tuning, rifle cadence, reload behavior, ammunition, and damage remain unchanged; projectile speed is 1800 at native scale. Final artwork has not been added.

Task 018 corrected the native migration audit findings: gravity now uses the correct `physics/2d/default_gravity` ProjectSettings section, all HUD labels use explicit 32-pixel font size, and the scale comparison scene shows the mathematically correct 56/80/96 native equivalents with 96 PX clearly selected.

Task 019 aligned the native scale comparison geometry and labels. The three silhouettes now use exact 56/80/96-pixel native dimensions with proportional weapons, and each option has one non-overlapping label.

Task 020 corrected the modular placeholder crouch pose. The upper-body, aim, and jetpack visuals now use a 32-pixel crouch offset, while the replaceable legs module switches between explicit integer-authored 40x56 standing geometry and 40x24 crouching geometry. Native 1280×720 configuration was statically verified; Windows runtime and visual validation remain pending because no Godot executable is available in the validation environment. No movement, collision, aiming, or combat behavior was changed.

Task 021 corrected the modular legs pose invocation to use Godot's safe dynamic `StringName` call interface. Crouch geometry and gameplay behavior remain unchanged.

Task 022 fixed the warnings-as-errors parser issue by explicitly typing the crouch visual offset as `float`; crouch geometry and gameplay behavior remain unchanged.

Task 023 added the data-driven shotgun weapon foundation. The automatic rifle remains the default, while temporary 1/2 selection switches between independently preserved ammunition states. Shotgun multi-projectile firing reuses the existing rifle projectile scene; final world pickup and equipment replacement remain pending.

Task 024 added the reusable interaction sensor and physical weapon pickup foundation. F equips the arena shotgun, drops the previously equipped weapon with deterministic motion, and preserves ammunition through the modular weapon controller. Held weapon visuals now install from each weapon definition; radio, loot case, and non-weapon equipment pickups remain pending.

Task 025 synchronized dropped weapon visuals with `WeaponDefinition.held_visual_scene`. The world pickup now rebuilds its visual slot when created or reassigned, so dropped rifles and shotguns retain their distinct placeholder visuals while all swap and physics behavior remains unchanged.

Task 026 attached the existing interaction controller script to the Player InteractionSensor Area2D. The typed player interaction boundary and all interaction behavior remain unchanged.

Task 027 enforced physical single-weapon ownership by removing temporary 1/2 debug switching and adding automatic reload for empty magazines with reserve ammunition. F pickup swapping and per-weapon ammunition preservation remain active; Windows runtime validation is pending.

Task 028 corrected the automatic reload regression: WeaponController now starts automatic reload after firing only when loaded ammunition reaches zero, while empty-fire, empty-weapon equip, manual R reload, reload cancellation, and zero-reserve guards remain active. The approved two-slot physical weapon ownership design is documented for Task 029; implementation is not included here.

Task 029 implements the two physical weapon slots. Slot 1 starts with the automatic rifle and slot 2 is empty; occupied-slot selection uses keys 1 and 2, while F pickups fill empty slots or replace the active slot by transferring exact `WeaponInstance` objects. Per-instance ammunition remains independent for duplicate weapons, including two shotguns. Windows runtime validation is pending.

Task 031 adds the interchangeable leg equipment foundation. Standard Legs remain the starting visual with no ability; a physical Knee-Dash Legs pickup can be equipped with F and swaps exact `LegInstance` ownership through the dedicated controller. The C request is safe for Standard Legs and only emits Knee Dash metadata for future execution. Windows runtime validation is pending; Task 032 will implement dash behavior.

Task 032 implements directional Knee Dash activation for Knee-Dash Legs. Mouse aim is clamped to a 60-degree sector from the selected horizontal side, with movement-priority dash physics, target-only once-per-dash contact damage, capped knockback, and per-instance cooldown preservation. Standard Legs remain passive; final dash presentation and additional effects are deferred. Windows runtime validation is pending.

Task 033 corrected the left-side Knee Dash direction reconstruction so horizontal mirroring preserves the mouse vertical sign while retaining the 60-degree clamp. The dash debug visual is now centered on the 64x28 hitbox. Windows runtime validation is pending.

Task 030 fixed the slot-switch reload regression. Automatic reload requests made by slot selection or active-slot replacement now run only for an instance with zero loaded ammunition; manual partial-magazine reload remains unchanged. Windows runtime validation is pending.

## Game concept

This is a retro 2D pixel-art run-and-gun game inspired by 16-bit console games. The player runs through a side-scrolling level, jumps onto platforms, uses a weapon, destroys enemies, and can briefly fly with a jetpack.

## First playable demo scope

The first demo should eventually contain:

- one short level lasting approximately one minute;
- movement left and right;
- standing, running, jumping, crouching, shooting, and jetpack flight;
- one weapon;
- one enemy type;
- platforms and ground;
- a basic HUD;
- a start point and finish trigger.

## Future modular player architecture

The following components must remain separate:

- body/head — base character identity and shared state;
- legs — separate visuals, movement animations, and leg abilities;
- arms — separate visuals, animations, and arm abilities;
- weapon — a separate visual object and separate shooting behavior;
- jetpack — a replaceable visual module attached to the body; the first demo may use one shared flight mechanic.

Arms and weapons must not be merged into one permanent sprite because both may change independently.

## Deferred features

The following features are explicitly deferred at this stage:

- complete inventory;
- multiple interchangeable body parts;
- multiple weapons;
- shops and progression;
- save system;
- bosses;
- online features;
- polished final art.

## Pixel viewport

The game renders natively at 1280×720 pixels. There is no 640×360 internal resolution or output stretching. The default CanvasItem texture filtering is nearest.
