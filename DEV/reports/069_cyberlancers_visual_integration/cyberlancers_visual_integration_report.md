# Task 069: Cyberlancers Player Visual Integration

## Objective

Replace the red Knee-Dash Legs placeholder with the supplied Cyberlancers player sprite and rename the player-facing leg equipment to `CYBERLANCERS` without changing gameplay behavior.

## Required and art bases

Implementation base: `199083ef6ab990df9de2fa24550094b36d26878c`.

Existing art publications:

- `5d1b546aae449c6ebd69dafda58db46b069aaa9d` — original Cyberlancers source-art publication.
- `199083ef6ab990df9de2fa24550094b36d26878c` — corrected 64x64 runtime sprite publication.

The three tracked art files were present before implementation. The runtime PNG is 64x64, 907 bytes, has an alpha channel, and its SHA-256 is `5DADA02AEA453199F48C279F30F43706DB213FC5F0EAB00234354C9738A7F26E`.

## Exact changed files

- `Game/resources/equipment/knee_dash_legs.tres`
- `Game/scenes/player/modules/cyberlancers_legs.tscn`
- `Game/scenes/player/modules/placeholder_knee_dash_legs.tscn` (renamed/replaced)
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/069_cyberlancers_visual_integration/cyberlancers_visual_integration_report.md`

No gameplay script changed. The existing `placeholder_legs.gd` remains the presentation-only module script and supplies the unchanged `set_crouching(crouching: bool)` API.

## Scene and resource wiring

`knee_dash_legs.tres` now references `res://scenes/player/modules/cyberlancers_legs.tscn` and uses the exact display name `CYBERLANCERS`. Its stable `equipment_id`, ability resource, and internal Knee-Dash identity remain unchanged. Standard Legs still references `placeholder_legs.tscn`, retains `STANDARD`, and keeps its passive C no-op behavior.

The new `CyberlancersLegs` scene reuses `placeholder_legs.gd` and renders `res://assets/sprites/equipment/legs/cyberlancers/cyberlancers_player_64x64.png`. Standing uses a native 64x64 Sprite2D with `centered = false`, position `Vector2(-32, -64)`, and nearest `texture_filter = 1`; its alpha artwork reaches the existing floor baseline at local Y 0 and keeps the upper connection aligned with the 96-pixel player silhouette. Player-owned `LegsSlot` mirroring continues to handle left/right facing.

The crouching visual uses the same texture at integer position `Vector2(-32, -32)` with an integer 64x32 lower region. It remains floor-aligned, reduces visual height for crouch and Slide, and is toggled by the existing `set_crouching` contract. No movement, collision, ability, cooldown, equipment, or pickup state is owned by the visual scene.

WorldLegPickup continues to derive its label and temporary world visual from `LegDefinition`, so the pickup identifies `CYBERLANCERS` and may temporarily display the player sprite. Dedicated folded or ground-pickup Cyberlancers artwork is deferred to the next visual task.

## Preserved behavior

Standard Legs, C input ownership, Knee Dash direction and 45-degree clamp, dash speed/duration, damage, full-body contact, once-per-dash protection, knockback, Bleeding, cooldown persistence, exact-instance transfer, pickup physics, Player collision, crouch, Slide, Jetpack, Hook, Shield, weapons, missions, extraction, HUD layout, collision layers, input mappings, and native 1280x720 configuration remain unchanged.

## Validation performed

- Confirmed repository remote is `Blackpoint133/Project_PG`, branch `main`, clean synchronization, and exact required base.
- Confirmed all three art files exist.
- Confirmed runtime PNG dimensions are 64x64, file size is 907 bytes, and alpha format is present.
- Confirmed the runtime PNG remained byte-for-byte unchanged during the task.
- Reviewed the complete visual/equipment ownership and crouch contract before editing.
- Confirmed only the Knee-Dash definition references the Cyberlancers scene and Standard Legs retains its original scene.
- Confirmed the runtime scene references the 64x64 PNG, reuses `set_crouching`, uses nearest filtering, and uses integer-authored transforms.
- Confirmed no gameplay constants or scripts changed.
- Ran `git diff --check` and staged diff checks.
- Ran the tracked-project Cyrillic scan excluding `.git`.
- Confirmed no `.godot`, import cache, generated `.import`, or manually authored UID file was added or changed.

## Checks not performed

No compatible Godot 4.7.2 executable was available. Godot import, parser, startup, focused scene, and Windows visual/runtime validation were not performed by Codex.

## Known limitations

The same equipped player sprite is temporarily reused by `WorldLegPickup`; a dedicated folded or ground-pickup Cyberlancers sprite is intentionally deferred. The crouch presentation uses an integer lower texture region rather than final authored crouch artwork.

## Publication

Implementation commit: `71d5c589efde398f3b14722780173c32c6cb94d3` (`feat: add Cyberlancers player visual`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after the documentation commit and returned in the final handoff.

## Focused Windows Godot 4.7.2 checklist

1. Start with Standard Legs and confirm the old appearance and C no-op behavior.
2. Pick up Cyberlancers and confirm the red placeholder is replaced.
3. Confirm the HUD shows `LEGS: CYBERLANCERS`.
4. Confirm feet meet the floor and the standing character remains near the intended 96-pixel height.
5. Face right and left and confirm correct mirroring.
6. Crouch while stationary and confirm feet remain grounded.
7. Enter Slide and confirm the visual stays attached and crisp.
8. Use Knee Dash in every supported direction.
9. Confirm damage, knockback, Bleeding, cooldown, full-body contact, and the 45-degree clamp.
10. Swap to Standard Legs and back to Cyberlancers.
11. Inspect temporary WorldLegPickup presentation.
12. Verify weapons, Shield, Hook, Jetpack, missions, extraction, collisions, and HUD.
13. Confirm no red parser/runtime errors or warnings appear.
