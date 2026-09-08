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

Task 032 implements directional Knee Dash activation for Knee-Dash Legs. Mouse aim is clamped to a 45-degree sector from the selected horizontal side, with movement-priority dash physics, target-only once-per-dash contact damage, capped knockback, and per-instance cooldown preservation. Standard Legs remain passive; final dash presentation and additional effects are deferred. Windows runtime validation is pending.

Task 033 corrected the left-side Knee Dash direction reconstruction so horizontal mirroring preserves the mouse vertical sign while retaining the 45-degree clamp. The dash debug visual is now centered on the 64x28 hitbox. Windows runtime validation is pending.

Task 035 makes living targets physically block the Player through collision mask 5, while defeated targets remain passable after clearing their enemy layer. Knee-Dash placeholder knockback now permits the authored 640.0 horizontal impulse cap; other dash behavior remains unchanged. Windows runtime validation is pending.

Task 036 adds interchangeable left-arm equipment. Standard Left Arm is installed dynamically at startup, while a physical Shield Left Arm pickup transfers exact instances through F and updates the held visual and HUD. Q is a held-input metadata boundary only; shield protection and energy behavior are deferred to Task 037. Windows runtime validation is pending.

Task 037 added the initial plasma Shield runtime; its temporary time-energy model was superseded by Task 039.

Task 038 corrected the stale Technical Design collision sentence to match the Task 035 solid-enemy contract. No gameplay behavior changed; Task 037 Windows runtime validation remains pending.

Task 039 reworks Shield Left Arm as an indefinite kinetic absorber. Held Q projects a stable vertical full-height panel on the mouse-selected side, incoming enemy attacks build per-instance charge with overflow passing through, and Q plus LMB releases stored charge as a cyan counter-blast while weapon firing is locked. A focused enemy projectile and 100-health Player damage foundation were added; final hostile damage behavior and effects remain deferred. Windows runtime validation is pending.

Task 040 corrected the kinetic Shield audit defects: new Shield instances start empty, empty shields can activate, ShieldArea routes hits to its parent ShieldController, and saturated HUD state has priority over active-state text. No scenes, resources, tuning, or unrelated gameplay systems changed. Windows runtime validation remains pending.

Task 041 adds a two-second per-instance kinetic Shield counter-blast cooldown. Q retains LMB ownership during the vulnerable cooldown, held Q reactivates the Shield when recovery ends, and exact-instance cooldown state persists through equipment swaps. Windows runtime validation remains pending.

Task 042 adds the separate Right Arm equipment foundation. Standard Right Arm starts passively, while a physical Hook Right Arm pickup transfers exact `RightArmInstance` ownership through F. E emits the typed Hook ability request and updates the HUD; hook projectile, cable, pulling, damage, stun, and cooldown runtime remain deferred. Windows runtime validation is pending.

Task 043 adds the Hook Right Arm runtime: full-direction E firing, a world-blocked hook projectile, a transform-safe cable, and a reusable target pull/stun boundary without hook damage. Hook cooldown is three seconds and belongs to the exact right-arm instance across swaps. Final hook presentation, audio, effects, and production enemy AI remain pending. Windows runtime validation is pending.

Task 044 corrects Hook pull collision: the target now pulls toward the stable Player `HookPullAnchor` at `(0, -40)`, floor contact alone no longer cancels horizontal movement, and `HookController` validates the reusable hook-compatible method contract without a `TargetDummy` type dependency. Windows runtime validation remains pending.

Task 045 adds world grapple movement. Solid Hook hits retain the exact collision point as a fixed anchor, and Player adds acceleration toward it while preserving velocity, gravity, collisions, and jetpack follow-up behavior. E, Space, arrival, timeout, obstruction, arm replacement, and Knee Dash detach paths preserve momentum; enemy pulls remain unchanged. This is retracting movement, not final rope-swing physics. Final jetpack heat balancing remains deferred to later focused work; grounded and landing slide remain deferred to the next focused task. Windows runtime validation remains pending.

Task 046 corrects post-grapple horizontal momentum preservation. Airborne no-input damping is bypassed only for momentum inherited from a successful world grapple and only until landing; ground friction, movement constants, and ordinary airborne behavior remain unchanged. Knee Dash clears this exception because it replaces velocity, and active Knee Dash suppresses same-frame Hook firing. Windows runtime validation remains pending.

Task 048 changes the Hook input to hold-to-maintain behavior: E fires on press, remains active while held, and cancels every active Hook state on release. The full exact-instance Hook cooldown starts only after the session finishes, including automatic completion, and holding E through cooldown completion does not refire. Player world-grapple momentum remains preserved after release.

Task 049 adds finite Jetpack heat. `JetpackController` owns 100.0 maximum heat, 40.0 per-second thrust gain, 50.0 per-second grounded cooling, and the overheat latch; heat never cools airborne, and Player remains the sole movement authority. Windows runtime validation remains pending.

Task 051 adds grounded and landing Slide runtime. A new Ctrl press with at least 260.0 horizontal speed starts a locked 0.65-second slide, while held Ctrl can start an edge-triggered landing slide at the same threshold. Slide cooldown is one second, jump preserves horizontal momentum, and Player remains the movement authority. Windows runtime validation remains pending.

Task 052 corrects the Slide runtime integration: Player advances `SlideController` exactly once before reading slide state, so duration, deceleration, and cooldown progress in every movement state. Slide-jump copies the latest signed slide velocity before cancellation and preserves it through the transition, while final crouch state is synchronized with the Shield presentation after landing-slide detection. Implementation commit `ffb65d136a69019efce620f27392a439a9657067` is published; Windows runtime validation remains pending.

Task 053 supersedes the previous 0.65-second Slide runtime duration with 0.975 seconds. Entry rules, deceleration, momentum, cooldown, crouch synchronization, and movement ownership are unchanged. Implementation commit `adb155ef65326fc067de0afa5bd8f5021e11db9b` is published; Windows runtime validation remains pending.

Task 054 replaces the former 64x28 Knee Dash attack Area2D with Player CharacterBody2D movement contacts. During an active dash, eligible living enemy-layer collisions are forwarded after `move_and_slide()` and damage each target once per dash; world and defeated-target contacts remain non-damaging. Implementation commit `b1df00cbe49dbdc1083a3fd3661a1f67f2b39b96` is published; Windows runtime validation remains pending.

Task 055 adds reusable BleedingStatusController state to TargetDummy. Knee Dash applies 4 damage per tick for four delayed one-second ticks, totaling 16 damage; reapplication refreshes four future ticks without stacking, and defeat clears the effect. Implementation commit `26a6cd2ef4056cbf765694df182b826c8b2bda71` is published; Windows runtime validation remains pending.

Task 056 completes the integrated movement, combat, equipment, and ability static audit at base `41a6d8f67bbcf630a29ce34411b7fb2d4a4bf74c`. No BLOCKER, HIGH, MEDIUM, or LOW gameplay findings were identified. User-reported Windows validation covers the integrated systems; Codex performed static checks only. Result: GO for Task 057, the first radio/helicopter mission foundation. Windows runtime validation by Codex remains pending.

The remaining focused roadmap begins with Task 057, the first radio/helicopter mission foundation.

Task 057 adds the first radio mission activation foundation. A physical MissionRadio uses the existing F interaction selector, Main explicitly connects its typed activation request to MissionController, and the controller changes the objective from FIND THE RADIO to DESTROY THE HELICOPTER exactly once. The HUD renders the supplied objective, while helicopter combat, movement, health, destruction, rewards, and extraction remain deferred. Implementation commit `1fa31f926ee58934a2b8b10a30a2a9553b4aabc0` is published; Windows runtime validation remains pending.

Task 058 adds the first mission helicopter combat slice. Activating `destroy_helicopter` reveals a 300-health horizontal patrol at 120 pixels per second; existing rifle and shotgun projectiles use the generic `take_damage` boundary. Zero health stops movement, disables living-enemy collision, applies a gray wreck presentation, completes the mission, hides the helicopter HUD, and changes the objective to HELICOPTER DESTROYED. Helicopter attacks, AI, explosion, loot, rewards, audio, and extraction remain deferred. Implementation commit `c1bd9ab93af6bc6e96c5912de052befec3aee998` is published; Windows runtime validation remains pending.

Task 059 adds deterministic helicopter destruction presentation and a physical closed loot-case drop. The 0.4-second explosion emits the exact destruction position and ejection velocity; Main spawns one non-interactive WorldLootCase, which falls with gravity and emits landed once. Only after landing does the objective become OPEN THE LOOT CASE. Opening, rewards, and item ejection remain deferred to Task 060. Implementation commit `c9b36cb93991e3e980425983069b46e4c146a715` is published; Windows runtime validation remains pending.

Task 060 makes the landed loot case openable once through F. Main physically ejects exactly four existing normal pickups with their authored definitions assigned before `add_child`: Shotgun, Shield Left Arm, Hook Right Arm, and Knee-Dash Legs. After successful reward creation, the objective becomes COLLECT THE EQUIPMENT. Reward collection tracking and final mission completion remain deferred. Implementation commit `af50959a15b01334f68b441d908eab6c8f64eedd` is published; Windows runtime validation remains pending.

Task 061 tracks successful collection of the four exact loot-case pickup nodes. Pickup classes emit one-shot completion signals only after Player returns a successful transfer; Main connects only those retained reward nodes and forwards stable reward IDs to MissionController. The objective reports progress and becomes `EQUIPMENT COLLECTED` after all four rewards are equipped. Implementation commit `102e1f9553ad6e0807eb1111909494d79fa525f1` is published; Windows runtime validation remains pending.

Task 062 corrects the Task 061 reward progress contract. Opening now shows `COLLECT THE EQUIPMENT (0/4)`, the first three unique exact rewards show `(1/4)` through `(3/4)`, and the fourth changes directly to `EQUIPMENT COLLECTED`. MissionController uses typed `StringName` reward IDs and requires the matching `destroy_helicopter` mission id; unrelated, duplicate, failed, early, and post-completion requests remain rejected. Implementation commit `cfb6d4b02fc6f60008b4d400122c419d93e5efad` is published; Windows runtime validation remains pending.

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
