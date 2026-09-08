# Task 060: Loot Case Opening and Equipment Rewards

## Objective

Make the landed helicopter loot case openable through the existing F interaction system and eject exactly four normal equipment pickups. Do not implement reward collection tracking or final mission completion.

## Audited base

- Required base: `da80d74d447cb17c1bc726fd4c637b617ddd21c9`
- Branch: `main`
- Working tree was clean before implementation and local HEAD matched the required base after synchronization.

## Exact changed file list

- `Game/scripts/interactables/world_loot_case.gd`
- `Game/scenes/interactables/world_loot_case.tscn`
- `Game/scripts/missions/mission_controller.gd`
- `Game/scripts/main.gd`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/060_loot_case_rewards/loot_case_rewards_report.md`

No Player, HUD, pickup implementation, project settings, helicopter, movement, combat, ability, resource, or UID file was changed.

## Case interaction conditions

WorldLootCase returns no prompt and ignores interaction before launch or while airborne. After its one-shot landed latch is set, it returns exactly `F: OPEN LOOT CASE`. The first valid interaction sets the opened latch, stops motion, clears interactable layer 6, swaps from ClosedVisuals to OpenVisuals, and emits `opened(global_position)` exactly once. The open case remains in the scene and stable on world geometry without implementing reward or mission ownership.

## Presentation

ClosedVisuals is visible initially. OpenVisuals is hidden initially and shows a lower case body, raised lid, and brighter inner accent after opening. Geometry is integer-authored placeholder Line2D/Polygon2D content with no imported art, animation, audio, particles, or shaders.

## Main reward ownership

Main owns the four PackedScene references, the reward-spawn latch, the opened-signal connection, and the reward construction boundary. WorldLootCase never searches for Main, MissionController, HUD, or Player and never instantiates rewards.

## Exact pickup scene/resource mappings

- `WorldWeaponPickup` <- `res://resources/weapons/shotgun.tres`
- `WorldLeftArmPickup` <- `res://resources/equipment/shield_left_arm.tres`
- `WorldRightArmPickup` <- `res://resources/equipment/hook_right_arm.tres`
- `WorldLegPickup` <- `res://resources/equipment/knee_dash_legs.tres`

Each scene is instantiated and cast to its required typed pickup class. Every exported definition is assigned before the node is added to World. After `add_child`, each pickup receives the common source position and its existing `launch` method with a deterministic velocity. A failed cast frees the raw instantiated nodes and emits a clear error without substituting another type.

## Deterministic launch velocities

The common source is the opened case position plus `Vector2(0, -48)`. The fan uses:

- Shotgun: `Vector2(-360.0, -620.0)`
- Shield Left Arm: `Vector2(-140.0, -760.0)`
- Hook Right Arm: `Vector2(140.0, -760.0)`
- Knee-Dash Legs: `Vector2(360.0, -620.0)`

Existing pickup gravity, floor friction, interaction cooldown, exact-instance creation, and equipment swap behavior remain authoritative.

## MissionController guards and objective transition

`mark_loot_case_opened(mission_id)` succeeds only for the completed matching `destroy_helicopter` mission after the landed-ready latch and before the opened latch. It changes the objective to exactly `COLLECT THE EQUIPMENT`, emits `objective_changed`, and emits a future-facing `loot_case_opened` signal. Duplicate, early, and mismatched requests return false without changing state. Main requests this transition only after all four reward nodes are created and launched successfully.

## Duplicate protection

WorldLootCase prevents repeated opens. Main prevents repeated reward construction. MissionController prevents repeated ready/opened transitions. Existing InteractionController nearest-candidate selection ignores the open case after its layer is cleared, and the case does not expose interaction methods after opening.

## Deferred behavior

Task 061 remains responsible for reward collection tracking, requiring all four rewards, final reward objective completion, extraction, and any additional mission progression. Task 060 does not add loot-only pickup rules, randomized contents, opening animation, dialogue, audio, particles, screen shake, or final artwork.

## Preserved systems

Radio activation, helicopter destruction, case launch/gravity/landing, Player movement, weapons, equipment ownership, existing pickup implementations, InteractionController, HUD objective API, collision contracts, input mappings, arena geometry, and native 1280x720 settings remain unchanged outside the required opening/reward wiring.

## Static validation

- Confirmed required clean base and branch after synchronization.
- Read the specified active docs, Task 059 report, Main, MissionController, WorldLootCase, InteractionController, all four pickup scripts/scenes, and four reward resources.
- Confirmed no interaction prompt before case landing.
- Confirmed one-shot opening latch and layer 6 removal.
- Confirmed exactly four typed reward construction paths.
- Confirmed definitions are assigned before `add_child` and existing pickup `launch` methods are used.
- Confirmed mission objective changes only after successful reward creation.
- Ran `git diff --check` and staged diff checks for both commits.
- Ran repository Cyrillic scan excluding `.git`.
- Confirmed no UID file was created or edited manually.

## Checks not performed

Godot 4.7.2 parser, import, startup, runtime, and visual validation were not performed because no compatible Godot executable was available in the environment.

## Known limitations

The case does not track collected rewards or complete the mission. Rewards use the existing pickup behavior and can be collected independently; final objective completion and extraction are deferred.

## Focused Windows runtime checklist

1. Activate the radio, destroy the helicopter, and wait for the case to land.
2. Confirm no F prompt appears while the case is airborne.
3. Confirm `F: OPEN LOOT CASE` appears only after landing.
4. Press F once and confirm the case visibly opens and the prompt disappears.
5. Confirm exactly one Shotgun, Shield Left Arm, Hook Right Arm, and Knee-Dash Legs pickup eject.
6. Confirm the deterministic fan, gravity, world collision, separate landing, and settling.
7. Confirm the objective becomes `COLLECT THE EQUIPMENT`.
8. Press F repeatedly near the open case and confirm no duplicate rewards appear.
9. Pick up and test every reward through the existing systems.
10. Verify radio, helicopter, weapons, equipment swapping, movement, Slide, Jetpack, Bleeding, collisions, and HUD.
11. Confirm no red Godot parser or runtime errors appear.

## Publication results

- Implementation commit: `af50959a15b01334f68b441d908eab6c8f64eedd`.
- Implementation push to `origin/main`: succeeded.
- Documentation publication commit: recorded in the final task handoff.
- Windows runtime validation remains pending.
