# Task 063: Mission Mercenary Combat Foundation

## Objective

Add a reusable placeholder MissionMercenary enemy that reuses the existing TargetDummy combat contracts and an isolated development scene for Windows testing. The normal Main scene and mission objective remain unchanged.

## Audited base

Required base: `36dc96d4cdd6e332d38699b3ac8633b8ba8f65db`.

## Exact changed files

- `Game/scripts/enemies/mission_mercenary.gd`
- `Game/scenes/enemies/mission_mercenary.tscn`
- `Game/scenes/dev/mission_mercenary_test.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/063_mission_mercenary_foundation/mission_mercenary_foundation_report.md`

## Inheritance and ownership

`MissionMercenary` extends `TargetDummy`; it does not duplicate damage, Hook, Bleeding, knockback, or collision logic. It owns only activation state, ranged attack configuration, emitter interruption, defeat reporting, and placeholder presentation configuration. No Player, Main, MissionController, or ability-controller dependency was added.

## Lifecycle and collision contract

New mercenaries initialize inherited health, then start hidden with physics disabled, collision layer zero, and the existing hostile emitter disabled. `activate()` is one-shot, makes the instance visible, enables enemy layer 3 / integer layer 4 with world mask 1, enables inherited physics, and enables firing only for the ranged configuration. Repeated activation and activation after defeat return false.

The inherited CharacterBody2D remains solid while alive. Defeat is handled after inherited damage reaches zero: firing stops, living-enemy collision is cleared, physics processing stops, the gray inherited presentation remains visible and passable, and `defeated(self)` emits exactly once. Later non-positive, inactive, or defeated damage is rejected.

## Damage and combat compatibility

The active mercenary retains the generic inherited boundaries `take_damage`, `apply_knockback`, `apply_bleeding`, `begin_hook_pull`, `cancel_hook_pull`, `is_hook_pull_active`, `get_hook_anchor_position`, and `is_hook_stunned`. Rifle and shotgun projectiles therefore use the existing generic damage contract. Hook and Knee Dash remain generic and do not depend on the MissionMercenary class.

## Ranged attack contract

The scene contains one existing `HostileProjectileEmitter` and the existing `EnemyProjectile` scene reference. MissionMercenary configures interval, speed, damage, and lifetime from typed exports. Ranged firing is horizontally aimed by the existing emitter. The emitter is disabled while inactive, defeated, Hook-pulled, or Hook-stunned, and resumes when the interruption ends if the mercenary remains active. The heavy variant has `ranged_attack_enabled = false`.

## Test-scene composition and tuning

`mission_mercenary_test.tscn` is isolated and is not the project main scene. It contains native-scale floor and boundary collision, Player, HUD, one active ranged mercenary, one active heavy mercenary, and the existing Shotgun, Shield Left Arm, Hook Right Arm, and Knee-Dash Legs pickups.

Ranged variant: 80 health, 1.5-second attack interval, projectile speed 720, damage 10, lifetime 4 seconds. Heavy variant: 150 health and no ranged firing. The mercenary placeholder uses integer-authored ColorRect geometry without imported art, animation, audio, particles, or shaders.

## Preserved systems and deferred integration

Main, MissionController, HUD scripts/scenes, Player, existing projectile/emitter scripts, equipment and pickup implementations, resources, project settings, input mappings, collision mappings, arena geometry, and all existing mission flow remain unchanged. Task 063 does not spawn mercenaries in Main or replace `EQUIPMENT COLLECTED`.

Task 064 will integrate an exact post-loot group, activate it after reward completion, track three exact defeats, and advance the objective. Extraction remains deferred.

## Validation performed

- Confirmed clean `main` preflight at the required base and fetched origin.
- Reviewed TargetDummy, BleedingStatusController, HostileProjectileEmitter, EnemyProjectile, existing player/HUD/pickup scenes, and relevant documentation before editing.
- Confirmed `MissionMercenary extends TargetDummy` and no shared combat implementation was copied.
- Confirmed inactive collision, physics, and firing state; one-shot activation; one-shot defeat reporting; and gray passable defeat state.
- Confirmed the heavy variant disables firing and the dev scene is not Main.
- Confirmed Main, MissionController, Player, existing projectile/emitter scripts, resources, and project settings are untouched.
- Ran `git diff --check` and staged checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.
- No UID file was created manually.

## Checks not performed

No compatible Godot 4.7.2 executable was available in this environment. Godot parser, import, startup, runtime, and visual validation were not performed by Codex.

## Known limitations

The hostile emitter uses its existing player-group lookup and projectile implementation. MissionMercenary does not add enemy AI, attacks beyond deterministic emitter firing, damage effects, final art, or mission composition. The inherited TargetDummy placeholder remains the combat foundation.

## Windows runtime checklist

1. Open `Game/scenes/dev/mission_mercenary_test.tscn` and press F6.
2. Confirm the ranged variant fires 10-damage projectiles approximately every 1.5 seconds.
3. Confirm the heavy variant never fires.
4. Test Shield absorption and counter-blast against the ranged mercenary.
5. Test Shotgun damage and Hook pull/stun against both variants.
6. Confirm Hook interruption stops ranged firing and firing resumes afterward.
7. Test Knee Dash direct damage, knockback, and four Bleeding ticks.
8. Defeat both variants and confirm gray presentation, passability, no later firing, and one defeat behavior.
9. Confirm the normal Main mission remains unchanged.
10. Confirm no red Godot parser or runtime errors appear.

## Publication

Implementation commit: `7a3e5e403d379a3767255e9dfe227d09e44b4098` (`feat: add mission mercenary foundation`), pushed successfully to `origin/main`.

Documentation commit: pending until publication.

Windows runtime validation remains pending.
