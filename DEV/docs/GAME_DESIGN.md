# Game Design

## Concept

OTG Pixel Game is a 2D pixel-art run-and-gun inspired by classic console games. Aiming uses the mouse in any direction, so fire direction is independent of horizontal facing.

The first target is a continuous, linear vertical slice lasting approximately 80 to 100 seconds. Placeholder visuals are acceptable during mechanical prototyping. Final sprite artwork will replace placeholders later without changing gameplay architecture.

The approved visual direction is original high-detail industrial science-fiction pixel art. The environment uses a cold blue and steel palette with snow, weathered industrial surfaces, layered mountains, industrial towers, bridges, pipes, antennas, and machinery. Warm hazard-yellow and restrained red accents provide readability. Characters and equipment must keep readable silhouettes with detailed modular armor, mechanical legs, weapons, jetpack, shield, and hook. The world uses layered parallax backgrounds and independently collidable foreground gameplay objects. The final player scale is 96 logical pixels tall at native 1280x720 rendering.

## Controls

| Input | Action |
| --- | --- |
| A / D | Move left and right |
| S | Crouch |
| Space press | Jump |
| Space held while airborne | Activate the jetpack |
| Mouse | Aim |
| Left mouse button | Fire |
| R | Reload |
| C | Activate the equipped leg ability |
| Q | Activate the equipped left-arm ability |
| E | Activate the equipped right-arm ability |
| F | Interact, accept missions, open cases, and equip nearby items |

Weapon ownership uses exactly two physical weapon slots. Slot 1 starts with the automatic rifle and slot 2 starts empty; keys 1 and 2 switch only between occupied slots. Picking up a weapon fills an empty slot first. When both slots are occupied, a pickup replaces the active slot and drops that exact weapon instance. Duplicate definitions are allowed, including two shotguns, and each weapon instance keeps independent loaded and reserve ammunition.

## Initial Equipment

- Automatic rifle
- Standard left arm
- Standard right arm
- Standard legs
- Standard jetpack

## Vertical-Slice Sequence

1. The player learns movement, jumping, crouching, aiming, shooting, and jetpack flight.
2. The player fights several basic enemies.
3. The player finds a radio item on the ground and accepts a mission with F.
4. A combat helicopter slowly crosses the upper part of the level.
5. The player destroys the helicopter with the automatic rifle.
6. The helicopter explodes and drops a loot case.
7. The player opens the case with F.
8. Four separate items physically emerge from the case:
   - shotgun;
   - shield left arm;
   - hook right arm;
   - knee-dash legs.
9. Each item is independently collectible and occupies only its matching equipment slot.
10. Equipping a replacement drops the previously equipped item onto the ground so it can be equipped again.
11. The next level section lets the player test the new equipment.
12. The player defeats a final enemy group and reaches an extraction point.

## Equipment Abilities

### Knee-Dash Legs

- Activated with C.
- Dash forward in the character's facing direction.
- Damage enemies on contact.
- Knock enemies backward.
- Reserve an extension point for a future bleeding status effect; bleeding is not implemented in the first vertical slice.

### Shield Left Arm

- Activated by holding Q.
- The shield remains active while Q is held.
- The player cannot fire while holding the shield.
- It absorbs frontal incoming damage.
- It has limited energy or durability and a recharge period.
- Reserve an extension point for a future reflected damage wave; the wave is not implemented in the first vertical slice.

### Hook Right Arm

- Activated with E.
- Fire the hook toward the mouse cursor.
- When it hits an enemy, pull that enemy toward the player.
- Briefly interrupt or stun the pulled enemy.

### Jetpack

- Activate by holding Space while airborne.
- Use a heat meter.
- Recover heat after landing.

### Weapons

- Automatic rifle with sustained fire.
- Shotgun with multiple pellets and strong close-range damage.
- Weapons automatically reload only after a shot empties the magazine when reserve ammunition is available. Firing an already empty weapon or equipping a stored empty weapon also starts reload when reserve ammunition exists; pressing R remains supported for manual reloads of partially empty magazines.

## Leg Replacement Presentation

1. The player interacts with the new leg item.
2. Player control is temporarily locked.
3. The jetpack activates and makes the legless character hover slightly above the ground.
4. The old legs detach and fall to the ground as a collectible equipment item.
5. The new legs are pulled toward the character with visible electrical arcs.
6. The new legs attach to the leg socket.
7. The character descends to the ground.
8. The jetpack powers down and control returns.
9. The swap should last roughly one second.
10. The player receives temporary invulnerability during the mandatory swap sequence.
11. Only the visual leg module detaches. The main CharacterBody2D and gameplay collision remain active.

## Prototype Enemies

- Basic ranged mercenary.
- Heavy mercenary, used to test the hook, knee knockback, and shotgun.
- Mission helicopter.

## Prototype UI

- Health.
- Weapon name and ammunition.
- Jetpack heat.
- Q, E, and C ability icons with cooldown or energy state.
- Mission objective text.
- Helicopter health bar while the mission is active.
- F interaction prompt near interactive objects.
