# Game Design

## Concept

OTG Pixel Game is a 2D pixel-art run-and-gun inspired by classic console games. Aiming uses the mouse in any direction, so fire direction is independent of horizontal facing.

The first target is a continuous, linear vertical slice lasting approximately 80 to 100 seconds. Placeholder visuals are acceptable during mechanical prototyping. Final sprite artwork will replace placeholders later without changing gameplay architecture.

The approved visual direction is original high-detail industrial science-fiction pixel art. The environment uses a cold blue and steel palette with snow, weathered industrial surfaces, layered mountains, industrial towers, bridges, pipes, antennas, and machinery. Warm hazard-yellow and restrained red accents provide readability. Characters and equipment must keep readable silhouettes with detailed modular armor, mechanical legs, weapons, jetpack, shield, and hook. The world uses layered parallax backgrounds and independently collidable foreground gameplay objects. The final player scale is 96 logical pixels tall at native 1280x720 rendering.

## Controls

| Input | Action |
| --- | --- |
| A / D | Move left and right |
| Ctrl | Crouch |
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
   - Cyberlancers legs.
9. Each item is independently collectible and occupies only its matching equipment slot.
10. Equipping a replacement drops the previously equipped item onto the ground so it can be equipped again.
11. The next level section lets the player test the new equipment.
12. The player defeats a final enemy group and reaches an extraction point.

The radio foundation presents `OBJECTIVE: FIND THE RADIO` before activation. F near the physical radio activates the `destroy_helicopter` mission once, changes the objective to `OBJECTIVE: DESTROY THE HELICOPTER`, and removes the radio prompt. Helicopter combat, movement, health, destruction, rewards, and extraction remain later mission-slice work.

### Mission Helicopter

- The helicopter is hidden and inactive until the radio activates `destroy_helicopter`.
- Once active, it patrols horizontally between authored world bounds at 120 pixels per second, initially moving left.
- The helicopter has 300 health and accepts generic projectile `take_damage` calls from the existing rifle and shotgun projectiles.
- At zero health it stops, becomes a gray disabled wreck, and completes the mission with the objective `HELICOPTER DESTROYED`.
- Helicopter attacks, AI, explosion, loot, rewards, audio, and extraction remain deferred.

### Helicopter Destruction and Loot Case

- When the mission helicopter reaches zero health, it stops and produces a short restrained placeholder explosion at its destruction point.
- Exactly one closed physical loot case is ejected from that point, falls under gravity, and settles on world geometry.
- After the case lands, the objective becomes `OPEN THE LOOT CASE`.
- The landed case can be opened once with F and then becomes a stable open case without another prompt.

### Loot Case Rewards

- After landing, the closed case shows `F: OPEN LOOT CASE` and can be opened once.
- Opening changes the objective to `COLLECT THE EQUIPMENT` and physically ejects exactly four normal pickups: Shotgun, Shield Left Arm, Hook Right Arm, and Knee-Dash Legs.
- Only those four exact reward pickup nodes count toward collection. The objective shows collected progress and becomes `EQUIPMENT COLLECTED` after all four are successfully transferred to Player.
- Reward tracking does not implement extraction or a final combat encounter.

## Equipment Abilities

### Cyberlancers Legs

- Activated with C.
- Launch toward the mouse cursor, including left, right, and diagonal directions.
- Clamp the dash angle to no more than 45 degrees from the horizontal ground line.
- During the active dash, Player CharacterBody2D contact with a living enemy deals damage once per target per dash activation; the full Player collision body is the contact source.
- Knock contacted enemies backward.
- A successful contact applies four delayed Bleeding ticks of 4 damage at one-second intervals, for 16 total delayed damage. Reapplying Bleeding refreshes four future ticks without stacking.

The current foundation provides physical Standard Legs and CYBERLANCERS equipment. CYBERLANCERS uses the supplied 64x64 pixel-art player visual while preserving the internal Knee-Dash identity, C interaction boundary, directional dash, contact damage, capped knockback, Bleeding, and cooldown metadata. Dedicated folded or ground-pickup artwork remains deferred.

### Left-Arm Equipment

- Standard Left Arm is the passive starting equipment.
- Shield Left Arm is a physical replacement equipped with F.
- Holding Q indefinitely projects a vertical translucent cyan plasma panel from Shield Left Arm and locks firing only while active.
- The panel protects the full standing or crouching body height on only the horizontal side selected by mouse X; mouse Y never tilts it.
- Incoming enemy attacks build stored charge on the exact Shield Left Arm instance. Charge saturates at its maximum and overflow passes through.
- While active, Q plus LMB releases the stored charge as a horizontal counter-blast instead of firing the equipped weapon.
- A successful counter-blast starts a two-second vulnerable recovery on that exact Shield Left Arm instance. Q retains LMB ownership during recovery, and holding Q reactivates the Shield automatically when recovery ends.
- Hostile projectile absorption and the Player damage foundation are implemented as a focused prototype; final damage, effects, and reflected-wave behavior remain deferred.

### Shield Left Arm

- Activated by holding Q.
- The shield remains active while Q is held.
- The player cannot fire while holding the shield.
- It is a vertical full-height barrier on the selected left or right side.
- Incoming attacks charge the barrier, and damage beyond remaining capacity reaches the Player.
- Stored charge remains on the exact left-arm instance when it is dropped and equipped again.
- Counter-blast cooldown also remains on the exact left-arm instance when it is dropped and equipped again.
- Reserve an extension point for a future reflected damage wave; the wave is not implemented in the first vertical slice.

### Hook Right Arm

- Press E to fire and hold E to maintain the current Hook use.
- Releasing E cancels extending, enemy pulling, or Player world grappling immediately; release during projectile flight is supported.
- Hook Right Arm is acquired as a physical replacement for Standard Right Arm.
- E is the dedicated typed right-arm ability request.
- The hook fires in the full mouse aim direction with a visible world-blocked projectile and transform-safe cable.
- A living hook-compatible enemy is pulled toward the Player, stops before overlap, and is briefly stunned without taking damage.
- A solid world hit creates a fixed grapple anchor and retracts the Player toward it with preserved momentum; E detaches manually and arrival, timeout, obstruction, arm replacement, Space, and Knee Dash also detach safely.
- Every Hook session starts its full authored cooldown only after completion or cancellation. Automatic completion while E remains held does not refire; E must be released and pressed again.
- The grapple is acceleration-based retracting movement rather than final rope-swing physics; final jetpack heat balancing remains deferred to later focused work, while grounded and landing slide remain deferred to the next focused task.
- Hook cooldown belongs to the exact RightArmInstance and remains preserved through pickup swaps.
- Final animation, audio, effects, and production enemy AI remain deferred.

### Jetpack

- Activate by holding Space while airborne.
- Use a 100.0-unit heat meter with 40.0 heat gain per second during actual thrust.
- Heat never recovers in the air. Grounded cooling removes 50.0 heat per second, and an overheat latch clears only at zero heat.
- Pulsing Space cannot bypass the finite airborne heat limit; Player movement remains the sole authority for velocity and collisions.

### Sliding

- Ctrl while standing still keeps the existing ordinary crouch.
- A new Ctrl press while grounded with at least 260.0 horizontal speed starts a slide; holding Ctrl while accelerating does not auto-start one.
- Holding Ctrl through an airborne-to-grounded landing with at least 260.0 horizontal speed starts a slide.
- Slides last 0.975 seconds, decelerate toward 180.0 pixels per second, preserve their locked horizontal momentum, and continue briefly after Ctrl is released.
- Slide completion or cancellation starts a one-second cooldown. Jumping from a slide preserves horizontal momentum and starts the cooldown.
- Final slide animation, effects, and production balancing remain deferred.

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

### Mission Mercenary Foundation

- `MissionMercenary` is a reusable placeholder enemy for the post-loot combat section and inherits the existing `TargetDummy` combat contracts.
- Inactive mercenaries are hidden, non-solid, non-damaging, and non-firing. Explicit activation makes them living enemies on the existing enemy collision layer.
- Ranged and heavy configurations share rifle, shotgun, Hook pull and stun, Knee Dash, knockback, and Bleeding behavior. The ranged configuration fires existing hostile projectiles; the heavy configuration is non-ranged.
- Defeat disables enemy collision and firing, leaves a gray passable placeholder, and reports defeat once. Main integrates three exact post-loot mercenaries after the reward objective completes.

### Post-Loot Mercenary Encounter

- After `EQUIPMENT COLLECTED`, the existing mission objective remains visible for one second before three exact MissionMercenary instances activate.
- The objective then becomes `DEFEAT THE ENEMIES (0/3)`. Unique defeats update `(1/3)` and `(2/3)`; the third changes the objective directly to `REACH THE EXTRACTION`.
- Encounter progress is owned by MissionController and counts only the three exact Main-scene mercenary nodes. Extraction and final mission completion remain deferred.

### Mission Extraction

- After the third exact mercenary defeat, a physical non-solid extraction field activates at the far-right end of the arena while the objective remains `REACH THE EXTRACTION`.
- Entering the field with the Main Player completes the first mission flow once and changes the objective to `MISSION COMPLETE`.
- The extraction zone is not an interaction prompt and does not block movement. Final artwork, level transitions, menus, rewards, and restart behavior remain deferred.

Living enemies physically block the Player during ordinary movement, jumping, falling, jetpack movement, and Knee Dash. Defeated enemies may become non-solid when their gameplay collision is disabled.

## Prototype UI

- Health.
- Weapon name and ammunition.
- Jetpack heat.
- Q, E, and C ability icons with cooldown or energy state.
- Mission objective text.
- Helicopter health bar while the mission is active.
- F interaction prompt near interactive objects.
