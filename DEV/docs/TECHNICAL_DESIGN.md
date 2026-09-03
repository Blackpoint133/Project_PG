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
- Future bleeding and reflected-wave effects must have clean extension points but remain unimplemented.
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

The current movement foundation uses `Game/scenes/player.tscn` with `player.gd`, a modular `BodyRoot`, an `AimPivot`, and a `Camera2D`.

Implemented placeholder visual hierarchy:

```text
Player (CharacterBody2D)
|-- CollisionShape2D
|-- BodyRoot (Node2D)
|   |-- BodySlot (Node2D) -> PlaceholderBody
|   |-- LegsSlot (Node2D) -> PlaceholderLegs
|   |-- JetpackSlot (Node2D) -> PlaceholderJetpack
|   `-- AimPivot (Node2D)
|       |-- LeftArmSlot (Node2D) -> PlaceholderLeftArm
|       |-- RightArmSlot (Node2D) -> PlaceholderRightArm
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
- `KneeDash` — forward dash, contact damage, and backward knockback.
- `Damage` — hit reaction and source bookkeeping.
- `Death` — disable control and gameplay interactions.

Locomotion, airborne, crouch, and jetpack logic should share movement intent through the player root rather than duplicating physics. Ability states should request priority from the state controller. Equipment swap is mandatory while it runs and applies invulnerability during that sequence.

## Equipment Resources

Use custom `Resource` classes for data-driven definitions. Keep tuning values in exported properties; add new resource classes only when behavior differs structurally.

- `EquipmentDefinition` — id, display name, slot, scene or component reference.
- `WeaponDefinition` — fire timing, projectile behavior, magazine, reload, damage, and spread data.
- `LegAbilityDefinition` — dash speed, duration, cooldown, contact damage, and knockback values.
- `ArmAbilityDefinition` — shield energy/durability, recharge, and hook pull/stun values.
- `JetpackDefinition` — thrust, heat drain, and cooling values.

Future bleeding is an effect or damage-extension point on `DamageReceiver` or contact attacks. Future reflected damage is an optional response hook on the shield handler. Neither is implemented in the first slice.

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

Player input routes fire and reload actions to the `WeaponController`; cadence, ammunition, reloading, and projectile behavior remain outside `player.gd` and arm visuals. Collision uses logical layers with integer bit values: world 1/1, player 2/1, targets 3/4, and player projectiles 4/8 with mask 5 detecting world and targets. Target dummies use logical layer 3 with zero mask and do not block player movement.

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
4. Player attacks — weapon projectiles, shotgun pellets, hook, and dash hitbox.
5. Enemy attacks — enemy projectiles and contact hazards.
6. Interactables — radio, loot case, and equipment pickups.
7. Equipment visuals / sensor-only shapes — detached legs, sockets, and presentation effects.

Player gameplay collision remains active during the leg swap. Only the leg visual module detaches. Use masks sparingly and document any exception if layer allocation changes.

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
