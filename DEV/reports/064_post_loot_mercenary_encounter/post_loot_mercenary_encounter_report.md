# Task 064: Post-Loot Mercenary Encounter Integration

## Objective

Integrate exactly three pre-authored MissionMercenary nodes into Main after all four exact loot-case rewards are collected. Track their unique defeats and advance the mission objective toward extraction without implementing extraction itself.

## Audited base

Required base: `86910d49c8c6d0e673f4d2482f8643f6bd77d7e2`.

## Exact changed files

Implementation:

- `Game/scripts/main.gd`
- `Game/scenes/main.tscn`
- `Game/scripts/missions/mission_controller.gd`

Documentation:

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/064_post_loot_mercenary_encounter/post_loot_mercenary_encounter_report.md`

## Encounter architecture

MissionController retains the existing `MissionState.COMPLETED` helicopter boundary and adds guarded post-helicopter encounter latches. It owns the accepted typed enemy IDs `upper_ranged`, `mid_ranged`, and `heavy`, the unique defeat booleans, defeat count, required count of three, objective text, and one-shot encounter completion.

Main is the scene composition boundary. It owns typed references to the three exact scene instances, the stopped one-shot `MercenaryEncounterStartTimer`, signal connections, and activation/defeat routing. No groups, global searches, or enemy-to-mission dependencies are used.

## Activation and objective sequence

The fourth reward still first produces `EQUIPMENT COLLECTED`. Main receives the typed `reward_collection_completed` signal, validates `destroy_helicopter`, and starts the 1.0-second timer once. When the timer completes, Main requests the guarded encounter start and activates each exact mercenary once. MissionController then emits:

- `DEFEAT THE ENEMIES (0/3)`
- `DEFEAT THE ENEMIES (1/3)`
- `DEFEAT THE ENEMIES (2/3)`
- `REACH THE EXTRACTION`

There is no visible `(3/3)` objective and no second `mission_completed` signal.

## Exact enemy composition and tuning

- `UpperRangedMercenary`: `Vector2(1300, 228)`, 80 health, ranged, 1.5-second interval, projectile speed 720.0, damage 10.0, lifetime 4.0, restrained blue.
- `MidRangedMercenary`: `Vector2(1800, 388)`, 80 health, ranged, same projectile tuning, related blue.
- `HeavyMercenary`: `Vector2(2240, 624)`, 150 health, ranged disabled, restrained orange.

All three are initially inactive through their existing foundation scene properties, so they remain hidden and non-colliding until the guarded timer transition.

## Defeat routing and duplicate guards

Main connects only the `defeated` signals of the three exact nodes. Each callback verifies that the emitted enemy is the expected exact reference before passing `DESTROY_HELICOPTER_ID` and its typed `StringName` ID to MissionController. MissionController rejects early, mismatched, unknown, duplicate, and post-completion requests. The third unique defeat transitions directly to `REACH THE EXTRACTION`.

## Preserved systems and deferred scope

MissionMercenary, TargetDummy, Player, HUD, weapons, projectiles, equipment, pickups, radio, helicopter, loot case, InteractionController, arena geometry, project settings, input mappings, and UID files remain unchanged. Existing movement, crouch, Slide, Jetpack, Knee Dash, Bleeding, Shield, Hook, collision, and reward flow are preserved.

Extraction zone, final mission ending, enemy waves, level transition, rewards beyond the four existing items, and presentation polish remain deferred to Task 065 or later.

## Validation performed

- Confirmed clean `main` preflight and fast-forwarded to the required base `86910d49c8c6d0e673f4d2482f8643f6bd77d7e2`.
- Reviewed the current Main, Main scene, MissionController, MissionMercenary scene/script, isolated Task 063 scene, arena, and active documentation.
- Confirmed exactly three inactive pre-authored Main-scene mercenaries and one stopped one-shot 1.0-second Timer.
- Confirmed exact-node defeat routing and typed stable IDs.
- Confirmed fourth reward remains `EQUIPMENT COLLECTED` before the delay.
- Confirmed no `(3/3)` objective path and no repeated mission completion path.
- Confirmed no changes to existing combat, movement, ability, pickup, HUD, arena, project, or UID files.
- Ran `git diff --check` and staged checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot parser, startup, visual, and runtime validation were not performed by Codex.

## Known limitations

The encounter only activates the existing MissionMercenary foundation and tracks exact defeats. It does not add extraction, final mission ending, enemy wave behavior, or new enemy mechanics.

## Windows runtime checklist

1. Start Main and confirm all three mercenaries are hidden and non-colliding before reward collection.
2. Complete radio, helicopter, loot case, and four-reward flow.
3. Confirm the fourth reward first shows `EQUIPMENT COLLECTED`.
4. Wait approximately one second and confirm all three enemies activate with `DEFEAT THE ENEMIES (0/3)`.
5. Confirm both blue enemies fire 10-damage projectiles every 1.5 seconds.
6. Confirm the orange heavy does not fire.
7. Test rifle, shotgun, Shield, Hook, Knee Dash, knockback, and Bleeding.
8. Confirm Hook interruption pauses and then resumes ranged firing.
9. Defeat enemies in any order and verify `(1/3)`, `(2/3)`, then `REACH THE EXTRACTION`.
10. Confirm no `(3/3)` objective appears and arena TargetDummy deaths do not count.
11. Confirm defeated mercenaries become gray, passable, and stop firing.
12. Confirm no red Godot parser or runtime errors appear.

## Publication results

Implementation commit: `ed3b95abd3cc624c6d5465966621a5a7e788e6dc` (`feat: add post-loot mercenary encounter`), pushed successfully to `origin/main`.

Documentation commit: the publication commit; its exact SHA is returned in the handoff.

Both commits are intended to be pushed normally to `origin/main`; final HEAD/origin equality and working-tree state are recorded after publication.
