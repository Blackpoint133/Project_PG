# Task 058: Mission Helicopter Combat Slice

## Objective

Reveal a damageable mission helicopter when the radio activates `destroy_helicopter`, patrol it through the upper level, display its health, and complete the mission when its health reaches zero.

## Audited base

- Required base: `01c209355027b845a43703ae558c7b8b137eda61`
- Branch: `main`
- Working tree was clean before implementation and local HEAD was fast-forwarded to the required base.

## Exact changed file list

- `Game/scripts/enemies/mission_helicopter.gd`
- `Game/scenes/enemies/mission_helicopter.tscn`
- `Game/scripts/missions/mission_controller.gd`
- `Game/scripts/main.gd`
- `Game/scenes/main.tscn`
- `Game/scripts/hud.gd`
- `Game/scenes/hud.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/058_mission_helicopter_combat/mission_helicopter_combat_report.md`

## Activation flow

The existing MissionRadio remains the only F interaction object for mission activation. Main receives its typed request, MissionController accepts `destroy_helicopter` only while `AVAILABLE`, emits `mission_activated`, and Main calls `MissionHelicopter.activate()`. The helicopter starts hidden and with collision layer 0 before activation. Duplicate activation and mismatched mission completion requests are rejected.

## Movement tuning

- Initial world position: `(1440, 180)`.
- Initial direction: left.
- Horizontal speed: `120.0` pixels per second.
- Patrol bounds: X `360.0` through `2200.0`.
- Movement uses CharacterBody2D horizontal motion with no gravity and reverses direction at bounds.
- Destruction immediately stops movement.

## Health and damage contract

MissionHelicopter owns `300` maximum health and exposes typed `take_damage(amount: int)`, health getters, and `health_changed`. Non-positive damage, inactive state, and destroyed state are rejected. Health clamps to zero. Existing rifle and shotgun projectiles continue using their generic `take_damage` method contract; no projectile code changed.

## Collision contract

The helicopter is inactive with collision layer 0. While active it uses logical enemy layer 3 / integer layer 4 and world collision mask 1. On destruction it clears layer 3, becoming passable like other defeated enemies. It does not inherit TargetDummy and does not expose Hook pull, Bleeding, or knockback contracts, so Hook treats it as neither a pullable target nor world geometry.

## Destruction lifecycle

The first transition to zero health sets the destroyed latch, stops horizontal motion, disables enemy collision, applies restrained gray modulation, and emits `destroyed` exactly once. Main completes `destroy_helicopter` through MissionController, which changes state to `COMPLETED`, updates the objective to `HELICOPTER DESTROYED`, and emits `mission_completed`. Main then hides the dedicated helicopter health label and bar.

## Mission and HUD wiring

Main explicitly connects MissionController activation and objective signals, MissionHelicopter health and destroyed signals, and HUD setters. HUD owns no mission state. The helicopter health label and 0-300 ProgressBar are hidden before activation, shown from supplied health data while active, and hidden after destruction.

## Preserved systems

No Player, weapon, equipment, ability, pickup, target, movement controller, input map, project setting, arena scene, or collision contract outside the new helicopter was changed. Radio interaction and nearest-candidate selection remain Task 057 behavior.

## Static validation performed

- Confirmed required clean base after fast-forward-only synchronization.
- Inspected all changed scripts and scenes plus existing mission, projectile, HUD, and interaction boundaries.
- Confirmed inactive visibility and collision layer 0.
- Confirmed activation is restricted to `destroy_helicopter`.
- Confirmed health clamps at zero, damage rejects non-positive values, and destruction is latched.
- Confirmed Main owns mission/helicopter/HUD wiring and objective rendering remains signal-driven.
- Confirmed generic projectile `take_damage` boundary remains unchanged.
- Ran `git diff --check` and staged diff checks.
- Ran repository Cyrillic scan excluding `.git`.
- Confirmed no UID file was created manually.

## Checks not performed

Godot 4.7.2 parser, import, startup, runtime, and visual validation were not performed because a compatible Godot executable was not available in the environment.

## Known limitations

The helicopter has no attacks, AI, explosion, falling wreck physics, loot, rewards, dialogue, audio, particles, screen shake, final artwork, or extraction behavior. Patrol and projectile collision require Windows runtime verification in the complete main scene.

## Focused Windows runtime checklist

1. Start the main scene and verify the helicopter is invisible and non-colliding before radio activation.
2. Use F at the radio and confirm the helicopter appears near the upper-right at approximately `(1440, 180)`.
3. Confirm it initially moves left and reverses at the authored patrol bounds.
4. Confirm the helicopter health label and 0-300 bar appear after activation.
5. Hit it with rifle and shotgun projectiles and confirm health decreases through `take_damage`.
6. Confirm the health bar reaches zero without negative values.
7. Confirm destruction happens once, movement stops, enemy collision clears, and the wreck becomes gray and passable.
8. Confirm the health HUD hides and the objective becomes `HELICOPTER DESTROYED`.
9. Confirm repeated damage and repeated mission signals are harmless.
10. Verify Hook, Knee Dash, Bleeding, Shield, Jetpack, Slide, weapons, pickups, radio interaction, and HUD remain error-free.
11. Confirm no red Godot parser or runtime errors appear.

## Publication results

- Implementation commit: `c1bd9ab93af6bc6e96c5912de052befec3aee998`.
- Implementation push to `origin/main`: succeeded.
- Documentation publication commit: recorded in the final task handoff.
- Windows runtime validation remains pending.
