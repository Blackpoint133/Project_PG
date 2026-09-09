# Technical Design

This document defines the architecture for the first Godot 4.7.2 Standard vertical slice. It is a planning contract, not an implementation task. Prefer composition over deep inheritance and avoid unnecessary abstraction.

## Presentation and Scale

The prototype renders natively at 1280x720; there is no 640x360 output stretching or camera zoom. The selected base player is 96 logical pixels tall with an approximately 40-pixel-wide standing collision. Gameplay geometry, positions, dimensions, and spatial movement constants are authored directly at this native scale using integer coordinates. When migrating old 640x360 values, spatial values are doubled, while time-based values remain unchanged and effective 2D gravity is doubled so jump and fall timing remain equivalent.

Future high-detail modular sprites must support the existing slot architecture and must be authored at native resolution. The environment plan uses layered parallax backgrounds with independently collidable foreground gameplay objects in the approved cold industrial winter palette.

## Core Principles

- The player root uses `CharacterBody2D`.
- Body, left arm, right arm, legs, weapon, and jetpack visuals remain separate replaceable components.
- Equipment slots are independent: `left_arm`, `right_arm`, `legs`, `weapon`, and `jetpack`.
- Weapon behavior must not be embedded in arm visuals.
- Arm abilities must not be embedded in weapon behavior.
- Leg abilities must be replaceable independently from movement visuals.
- Jetpack visuals must be replaceable independently from the shared flight mechanic.
- Equipment definitions use custom `Resource` data where appropriate.
- Dropped equipment uses reusable world pickup scenes.
- Character state must explicitly support locomotion, crouching, airborne movement, jetpack flight, equipment swapping, shielding, hook use, knee dash, damage, and death without becoming one monolithic script.
- Bleeding and reflected-wave effects use focused extension points; Bleeding is implemented for Knee Dash while reflected-wave behavior remains unimplemented.
- Placeholder visuals must be replaceable with final sprites without changing gameplay systems.

## Scene Layout

Likely top-level scenes:

- `Game/scenes/level/vertical_slice.tscn` — planned final vertical-slice level.
- `Game/scenes/arena.tscn` — current movement test arena.
- `Game/scenes/player/player.tscn` — player root and equipment sockets.
- `Game/scenes/player.tscn` — current movement-foundation player scene.
- `Game/scenes/enemies/basic_mercenary.tscn`, `heavy_mercenary.tscn`, and `mission_helicopter.tscn`.
- `Game/scenes/projectiles/` — rifle rounds, shotgun pellet bundle, and hook.
- `Game/scenes/equipment/world_pickup.tscn` — reusable pickup for every dropped or case-emitted item.
- `Game/scenes/interactables/` — radio and loot case.
- `Game/scenes/ui/hud.tscn` — health, weapon, heat, abilities, mission, boss health, and interaction prompt.

Likely player node structure:

```text
Player (CharacterBody2D)
|-- CollisionShape2D
|-- Body (Node2D or Sprite2D)
|-- LegSocket (Node2D)
|-- LeftArmSocket (Node2D)
|-- RightArmSocket (Node2D)
|-- WeaponSocket (Node2D)
|-- JetpackSocket (Node2D)
|-- LocomotionController (Node)
|-- JetpackController (Node)
|-- EquipmentController (Node)
|-- WeaponController (Node)
|-- AbilityController (Node)
|-- DamageReceiver (Area2D or Node)
|-- InteractionSensor (Area2D)
`-- StateController (Node)
```

The current movement foundation uses `Game/scenes/player.tscn` with `player.gd`, a modular `BodyRoot`, an `AimPivot`, a runtime `LegEquipmentController`, and a `Camera2D`.

Implemented placeholder visual hierarchy:

```text
Player (CharacterBody2D)
|-- CollisionShape2D
|-- BodyRoot (Node2D)
|   |-- BodySlot (Node2D) -> PlaceholderBody
|   |-- LegsSlot (Node2D) -> active held legs visual
|   |-- JetpackSlot (Node2D) -> PlaceholderJetpack
|   `-- AimPivot (Node2D)
|       |-- LeftArmSlot (Node2D) -> PlaceholderLeftArm
|       |-- RightArmSlot (Node2D) -> active held right-arm visual
|       |-- WeaponSlot (Node2D) -> active held weapon visual
|       `-- AimLine
`-- Camera2D
```

Each placeholder module is a separate scene instance and can later be replaced without changing player movement code. Legs and jetpack remain outside `AimPivot`; arms and weapon follow it.

The current jetpack model authorizes flight only from a grounded jump, requires a held jump input while airborne, clears authorization on landing, and smoothly approaches a controlled negative rise velocity. The HUD and state reporting use the actual jetpack-active result rather than raw input.

The player local origin represents the feet. Collision height uses `collision_shape.position.y = -target_height * 0.5`, so standing and crouching bottoms both remain at local Y 0. The crouch visual offset is `CROUCH_VISUAL_OFFSET = 4`; crouching moves `BodySlot` and `JetpackSlot` down to Y 4 and `AimPivot` from Y -18 to Y -14, while `LegsSlot` remains fixed at Y 0. This keeps the torso visibly above the legs while communicating the pose.

Facing is derived from the mouse horizontal offset with a small dead zone and preserved inside that zone. `BodySlot`, `LegsSlot`, and `JetpackSlot` flip horizontally without flipping `BodyRoot`. `AimPivot` independently aims at the global mouse and mirrors its local Y axis when facing left so arm and weapon artwork remain upright while local +X continues to point toward the cursor.

Socket children represent the currently equipped visual module. Behavior controllers communicate with the player root through well-defined signals and explicit state requests.

## State Responsibility

Use a small finite-state controller or one focused state node per major mode. The first slice needs these states or their clear equivalents:

- `Locomotion` — grounded horizontal movement and facing.
- `Crouch` — reduced movement/pose and tighter targeting constraints.
- `Airborne` — jumping and falling.
- `JetpackFlight` — shared thrust, heat drain, and landing recovery.
- `EquipmentSwap` — locked control, hover, detach/attach sequence, and temporary invulnerability.
- `Shielding` — frontal damage absorption and firing lock.
- `HookUse` — hook firing, pull, and brief enemy interruption/stun.
- `KneeDash` — directional dash, Player-body contact damage, and backward knockback.
- `Damage` — hit reaction and source bookkeeping.
- `Death` — disable control and gameplay interactions.

Locomotion, airborne, crouch, and jetpack logic should share movement intent through the player root rather than duplicating physics. Ability states should request priority from the state controller. Equipment swap is mandatory while it runs and applies invulnerability during that sequence.

## Equipment Resources

Use custom `Resource` classes for data-driven definitions. Keep tuning values in exported properties; add new resource classes only when behavior differs structurally.

- `EquipmentDefinition` — id, display name, slot, scene or component reference.
- `WeaponDefinition` — fire timing, projectile behavior, magazine, reload, damage, and spread data.
- `LegAbilityDefinition` — stable ability id and display name; future dash speed, duration, cooldown, contact damage, and knockback values remain deferred.
- `ArmAbilityDefinition` — shield charge, counter-blast, and hook pull/stun values.
- `JetpackDefinition` — thrust, heat drain, and cooling values.

Task 031 adds `LegDefinition`, `LegAbilityDefinition`, and `LegInstance` resources/runtime ownership, plus `LegEquipmentController` and `WorldLegPickup`. The player owns one leg slot that starts with Standard Legs; physical F interaction transfers exact leg instances and preserves the existing LegsSlot crouch contract. Standard Legs have no ability, while Knee-Dash Legs expose only ability metadata until Task 032.

Bleeding is implemented as a focused `BleedingStatusController` state component for Knee Dash contacts and remains extensible through generic damage/status boundaries. Future reflected damage is an optional response hook on the shield handler and remains unimplemented.

## Scripts and Responsibility Boundaries

Likely scripts, kept focused:

- `player.gd` — player root API, input routing, facing, aim, and state requests.
- `player_state.gd` or focused state scripts — mode transitions and active mode behavior.
- `locomotion_controller.gd` — grounded, crouched, and airborne movement.
- `jetpack_controller.gd` — shared flight mechanic, heat meter, landing recovery, and activation conditions.
- `equipment_controller.gd` — slot ownership, equip/unequip, dropped-item creation, and socket updates.
- `weapon_controller.gd` — weapon resource execution, firing, reloading, and weapon-specific projectiles. It must not own arm visuals or arm abilities.
- `leg_ability.gd`, `shield_left_arm.gd`, and `hook_right_arm.gd` — ability implementations instantiated or configured from their definitions.
- `world_pickup.gd` — pickup identity, interaction availability, and reuse for dropped or newly found equipment.
- `enemy.gd` plus focused enemy scripts — health, damage, movement, attacks, and knockback/pull reactions.
- `interaction_system.gd` or per-object interaction component — shared F prompt and interaction handling.
- `mission_hud.gd` — read-only presentation of player, weapon, jetpack, ability, mission, and target state.

Task 057 adds a scene-owned `MissionController` and reusable `MissionRadio`. Main is the composition boundary: it connects the radio activation request to the controller and forwards the controller objective signal to HUD. The radio uses the existing interactable layer 6 / integer layer 32 and exposes only the generic `get_interaction_prompt` and `interact` methods. Mission state is not stored in Player, HUD, or an autoload; the initial `AVAILABLE` state changes once to `ACTIVE` for `destroy_helicopter`.

Task 058 adds `MissionHelicopter` as a separate CharacterBody2D mission actor. Main connects `MissionController.mission_activated` to explicit helicopter activation, forwards typed health signals to HUD, and completes the mission from the helicopter's one-shot destroyed signal. The helicopter is hidden with collision disabled before activation, uses enemy layer 3 / integer layer 4 and world mask 1 while active, patrols without gravity, and accepts only the generic `take_damage` contract. Its disabled gray wreck clears the enemy collision layer; attacks, AI, explosion, loot, and rewards remain deferred.

Task 059 replaces the permanent helicopter wreck with a deterministic 0.4-second local explosion presentation and typed destruction payload. Main owns the reusable `WorldLootCase` scene, spawns exactly one case at the supplied destruction position plus offset, and launches it with inherited horizontal momentum. The case uses interactable layer 6 / integer layer 32 and world mask 1, does not implement the interaction contract, and changes the objective to `OPEN THE LOOT CASE` only after its one-shot landing signal. Opening, rewards, and item ejection remain deferred to Task 060.

Task 060 makes the landed WorldLootCase a one-shot F interactable. Main connects its opened signal, assigns each existing pickup definition before adding four typed pickup scenes to World, launches them with a deterministic fan, and then requests the MissionController transition to `COLLECT THE EQUIPMENT`. The case owns only opening presentation and its interaction latch; it does not own mission state or reward construction. Reward collection tracking and final completion remain deferred.

Task 061 adds one-shot `pickup_completed` signals to the four existing pickup classes. Each signal is emitted only after the Player returns a successful exact-instance transfer, so replacement pickups cannot report the same reward twice. Main retains and connects only the four exact nodes created for the loot case; unrelated arena pickups are never connected. MissionController tracks the four typed `StringName` reward IDs `shotgun`, `shield_left_arm`, `hook_right_arm`, and `knee_dash_legs`, with the matching mission id. Opening starts `COLLECT THE EQUIPMENT (0/4)`, progress reaches only `(1/4)` through `(3/4)`, and the fourth transfer changes the objective directly to `EQUIPMENT COLLECTED`.

Task 062 corrects the reward progress boundary without changing pickup or equipment behavior. Main supplies `destroy_helicopter` and the exact typed reward ID to the guarded registration method; invalid, duplicate, early, and post-completion requests remain no-ops.

Task 063 adds `MissionMercenary` as a focused `TargetDummy` subclass for isolated combat testing. It owns only activation, typed ranged-projectile configuration, defeat reporting, and presentation. Inactive instances are hidden with collision and physics disabled; activation enables enemy layer 3 / integer layer 4 and an existing `HostileProjectileEmitter` when configured. Defeat stops firing, clears living-enemy collision, preserves the inherited generic rifle, shotgun, Hook, Knee Dash, knockback, and Bleeding contracts, and emits a typed one-shot signal. Main and mission objective state remain untouched; Task 064 will compose and activate an exact post-loot group.

Weapon and ability components should communicate through signals such as `fired`, `reloaded`, `ability_started`, `ability_ended`, and `ability_state_changed`. The player emits input intents; components never reach into unrelated sibling components.

The current combat foundation adds:

- `Game/scripts/combat/weapon_definition.gd` — data-driven rifle tuning.
- `Game/scripts/combat/weapon_controller.gd` — fire cadence, ammunition, reloading, and focused signals.
- `Game/scripts/combat/rifle_projectile.gd` — transform-safe projectile movement, lifetime, and single-hit damage.
- `Game/scripts/targets/target_dummy.gd` — stationary 50-health target with visible feedback.
- `Game/scenes/projectiles/rifle_projectile.tscn` — placeholder rifle projectile.
- `Game/scenes/targets/target_dummy.tscn` — reusable target dummy.
- `Game/resources/weapons/automatic_rifle.tres` — automatic rifle definition.
- `Muzzle` Marker2D under the weapon module defines the projectile spawn point.

The current combat foundation also includes `Game/resources/weapons/shotgun.tres`, a data-driven eight-projectile weapon that reuses the rifle projectile scene. `WeaponDefinition` controls automatic-fire mode, projectile count, and complete-cone spread. `WeaponInstance` owns one immutable definition reference plus loaded and reserve ammunition. `WeaponController` owns exactly two nullable instances, one active slot index, independent slot selection, and focused weapon/ammo/slot signals. Empty magazines automatically reload when reserve ammunition is available.

Task 024 adds a reusable `InteractionSensor` Area2D under Player with collision mask layer 6 (integer 32), plus a `WorldWeaponPickup` CharacterBody2D using layer 6 and world mask 1. The sensor owns candidate selection and prompt signaling while Player reads F and requests interaction. Weapon pickups support deterministic fall/drop motion, modular held weapon visuals, and physical weapon replacement while WeaponController remains the sole owner of per-weapon ammunition. The current pickup implementation supports weapons only; radio, loot case, and other equipment pickups remain pending.

Task 027 temporarily enforces single-active-weapon ownership by removing the debug selection inputs and gameplay paths. The automatic rifle remains equipped at startup, and physical F pickup swaps preserve each weapon's stored ammunition. WeaponController starts reload automatically after an emptying shot or when an equipped weapon has zero loaded ammunition with reserve remaining; no reload starts when reserve ammunition is zero.

Task 028 corrects automatic reload so a partially empty magazine never reloads as a side effect of firing.

Task 029 implements two physical weapon slots. Slot 1 starts with the rifle and slot 2 is empty; keys 1 and 2 select occupied slots only. F pickups fill the first empty slot and otherwise replace the active slot while transferring the exact outgoing instance back into the same pickup. Duplicate definitions are allowed, and each `WeaponInstance` retains independent ammunition while moving between a slot and the world.

Task 031 keeps leg equipment in a separate controller and ownership boundary from both weapon slots. `leg_ability` is the physical C request; it safely returns without effect for Standard Legs and emits only a typed request for Knee-Dash Legs. The one-second swap presentation remains pending.

Task 032 adds a `KneeDashController` that owns active dash timing, dash direction/velocity, and once-per-activation hit tracking. Player computes the mouse-directed dash vector and clamps its signed angle to -45 through +45 degrees relative to the selected horizontal side, using current facing for near-vertical or origin aim. Player retains CharacterBody2D velocity and move_and_slide ownership, while normal locomotion, gravity, jump, and jetpack are suspended only during the active dash. The controller emits typed dash signals; target dummies provide a capped horizontal placeholder knockback API. Bleeding, invulnerability, camera effects, final animation, and full dash presentation remain deferred.

Task 054 replaces the former offset Knee Dash Area2D with Player CharacterBody2D slide contacts. After the existing dash `move_and_slide()` call, Player forwards each frame collision to `KneeDashController`, which filters generic living enemy-layer contacts exposing `take_damage`, tracks each target once per dash, and applies the existing damage and knockback. World and defeated-target contacts remain passable to damage dispatch.

Task 055 adds `BleedingStatusController` as a state-only target child. Knee Dash keeps its 25 direct damage and requests generic `apply_bleeding` only after valid living enemy contact. Bleeding deals 4 damage per tick at one-second intervals for exactly four delayed ticks, refreshes without stacking, and clears on defeat. Hook stun presentation takes priority over the red bleeding tint while the timer continues.

Task 036 adds the independent left-arm equipment boundary: `LeftArmDefinition` is shared configuration, `LeftArmInstance` owns one exact runtime item, and `LeftArmEquipmentController` owns the single equipped instance. `LeftArmSlot` is populated dynamically from the definition's held visual scene. `WorldLeftArmPickup` transfers exact instances through F while remaining separate from leg and weapon ownership. Standard Left Arm has no ability; Shield Left Arm exposes only typed shield metadata and held-Q input state until Task 037. Right-arm equipment follows the same separate slot boundary and does not share left-arm instances or behavior.

Task 037 added `ShieldController`; Task 039 reworks it as a kinetic absorber under stable `BodyRoot` rather than the freely rotating `AimPivot`. The inactive Shield Arm remains a compact emitter, while held Q projects a vertical translucent cyan panel covering 96 standing pixels or 64 crouching pixels on the mouse-selected horizontal side. Incoming attacks build charge on the exact `LeftArmInstance`, saturating at the authored maximum with overflow passing through. While active, Player applies the firing lock before processing LMB; a distinct Q plus LMB press releases stored charge as a horizontal cyan counter-projectile. Task 041 adds a two-second per-instance counter-blast recovery: Q retains LMB ownership during the vulnerable cooldown, and held Q reactivates the Shield when it reaches zero. Enemy attacks use logical layer 5 and the Player damage receiver provides a 100-health foundation. Recharge, passive drain, depletion latches, hostile projectile absorption beyond this focused test foundation, and final damage effects remain deferred.

Task 042 adds `RightArmDefinition`, `RightArmInstance`, `RightArmEquipmentController`, and `WorldRightArmPickup`. Standard Right Arm is installed dynamically at startup; Hook Right Arm is acquired with F and transfers exact instances back into the same pickup. E emits a typed Hook ability request, while projectile, cable, pulling, damage, stun, and cooldown behavior remain deferred.

Task 043 adds `HookController` and a configured `HookProjectile`. E fires in the full mouse direction, the projectile uses continuous segment collision against world and enemy layers, and a Line2D cable converts global endpoints into the controller's local space. Hook-compatible living targets expose pull and stun methods; they move as CharacterBody2D instances toward a 72-pixel stop distance with world collision and no hook damage. The three-second cooldown is stored on the exact `RightArmInstance` and survives swaps. Task 044 binds pull direction to the stable `BodyRoot/HookPullAnchor` at `(0, -40)`, uses the generic hook contract, and ends movement only when progress is obstructed rather than on tangential floor contact.

Player input routes fire and reload actions to the `WeaponController`; cadence, ammunition, reloading, and projectile behavior remain outside `player.gd` and arm visuals. Collision uses logical layers with integer bit values: world 1/1, player 2/1, targets 3/4, and player projectiles 4/8 with mask 5 detecting world and targets. Living hook-compatible targets use enemy layer 3 (integer collision layer 4); `TargetDummy` uses world collision mask 1 for collision-aware pull and knockback movement. Floating targets remain stationary while idle without gravity, living targets block Player CharacterBody2D movement, and defeated targets may become passable after clearing enemy layer 3.

Task 045 adds the explicit Hook `grappling` state for solid world hits. The projectile forwards the exact collision position; `HookController` owns the fixed anchor, cable, marker, lifetime, arrival, timeout, and obstruction bookkeeping, while Player remains the sole owner of velocity and `move_and_slide()`. Player grapple acceleration is added to existing velocity and capped without resetting tangential momentum. E, Space, arm replacement, arrival, timeout, obstruction, and successful Knee Dash detach without clearing velocity. This is retracting acceleration movement rather than pendulum or rope-swing physics; final jetpack heat balancing remains deferred to later focused work and grounded and landing slide remain deferred to the next focused task.

Task 046 adds a Player-owned exception for horizontal momentum inherited from a successful world grapple. While airborne, no-input horizontal damping is bypassed only for that inherited momentum and the exception ends on landing. Ground friction, movement constants, and ordinary airborne behavior are unchanged. A successfully started Knee Dash clears the exception because dash movement replaces velocity. The physics input order resolves the active Knee Dash state before E can request a new Hook, suppressing same-frame Hook firing while preserving normal E cancellation.

Task 048 changes Hook input ownership to a held session. `Player` accepts only a discrete E press, `HookController` emits one idempotent completion signal for each started session, and `RightArmEquipmentController` reserves the exact `RightArmInstance` until completion before starting its full cooldown. Release, automatic completion, invalidation, Space, Knee Dash, and arm replacement all converge on completion without resetting Player velocity or the preserved grapple-momentum exception.

Task 049 adds `JetpackController` as a state-only child owned by Player. It owns 100.0 maximum heat, 40.0 per-second airborne thrust gain, 50.0 per-second grounded cooling, and the overheat latch; Player remains the sole authority for authorization, gravity, jetpack acceleration, velocity, and `move_and_slide()`. Heat never cools in the air, so pulsing Space cannot bypass the limit, and an overheat latch clears only after grounded heat reaches zero. JetpackController is advanced exactly once per physics frame and never moves the Player directly.

Task 051 adds `SlideController` as a state-only Player child. It owns slide timing, locked signed horizontal speed, and cooldown while Player remains the sole authority for velocity, crouch pose, collisions, jumping, gravity, and `move_and_slide()`. A new grounded Ctrl press requires at least 260.0 horizontal speed; held Ctrl can start an edge-triggered landing slide at the same threshold. Slides use a 600.0 minimum initial speed, 0.975-second duration, 720.0 deceleration, 180.0 minimum active speed, and a one-second cooldown. Jump, Knee Dash, grapple, jetpack, wall, enemy, and shield interactions preserve existing movement ownership and collision boundaries. Task 053 supersedes the previous 0.65-second runtime duration with 0.975 seconds.

Task 052 advances `SlideController` exactly once at the start of each Player physics frame, before slide state is read or new entry is requested. A slide-jump stores the latest signed controller velocity before cancellation and uses a focused Player-owned momentum exception so grounded movement cannot reduce it on the jump frame or immediately during same-direction airborne input; landing, Knee Dash, and world grapple clear that exception as appropriate. Final crouch state is applied to both Player visuals and Shield after landing-slide detection.

## Signals

Important expected signals:

- `equipment_changed(slot, definition)` — equipment controller to player, UI, and visual sockets.
- `state_changed(previous_state, new_state)` — state controller to locomotion and presentation.
- `health_changed(current_value, maximum_value)`, `damaged(amount, source)`, `died` — player and enemies to UI and gameplay systems.
- `jetpack_heat_changed(current_heat, maximum_heat)` — flight mechanic to UI.
- `weapon_ammo_changed(loaded_ammo, reserve_ammo)`, `weapon_changed(definition)` — weapon controller to UI.
- `ability_state_changed(slot, active, cooldown_or_energy)` — ability controller to UI.
- `interaction_available(prompt_text)` and `interaction_unavailable` — interaction system to UI.
- `mission_changed(objective_text)`, `mission_target_health_changed(current_value, maximum_value)`, and `mission_completed` — mission flow to UI.

## Collision Layers

Suggested layer allocation:

1. World — ground, platforms, and static level collision.
2. Player body — player gameplay collision.
3. Enemies — enemy gameplay collision.
4. Player attacks — weapon projectiles, shotgun pellets, and Hook behavior.
5. Enemy attacks — enemy projectiles and contact hazards.
6. Interactables — radio, loot case, and equipment pickups.
7. Equipment visuals / sensor-only shapes — detached legs, sockets, and presentation effects.

Player gameplay collision remains active during the leg swap. The Player uses collision layer 2 and mask 5 to detect world layer 1 and enemy layer 4, while living enemies block CharacterBody2D movement through standard `move_and_slide` resolution. Full-body Knee Dash contact uses this Player layer 2 against enemy layer 3; it is not a Player Attacks layer 4 hitbox. Defeated targets may clear their enemy layer and become passable. Only the leg visual module detaches. Use masks sparingly and document any exception if layer allocation changes.

## Data Flow

Definitions configure behavior; `WeaponInstance` objects own runtime ammunition. Pickup and case flows reference definitions and transfer distinct instances through the reusable world pickup scene. For weapons, the current data flow is:

1. Take the incoming instance from a physical pickup.
2. Fill the first empty slot, or replace the active slot and return its exact instance to that pickup.
3. Activate the filled/replaced slot and rebuild the held visual from its definition.
4. Emit weapon, ammo, and slot-state signals.

The leg swap uses the same ownership boundary but wraps it in the mandatory hover, detach, attract, attach, and landing sequence.

## Testing Intent

For Godot testing in this repository, prefer focused scene/script checks where practical and manual runs for gameplay feel:

- Launch scenes and inspect parse/runtime errors.
- Verify input bindings, equipment swaps, slot exclusivity, and dropped pickups.
- Verify shield firing lock, jetpack heat, knee knockback, hook pull/stun, and weapon behavior.
- Verify UI bindings and interaction prompts.

Do not create the implementation in the current planning task.
