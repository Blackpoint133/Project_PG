# Task 071: Cyberlancers Pickup and HUD Icon Integration

## Objective

Use the committed Cyberlancers knee-strike icon as a generic data-driven leg-definition visual for world pickups and as a separate framed HUD presentation while CYBERLANCERS is equipped.

## Base and exact changed files

Required and actual implementation base: `ccb77f1c3b114c7ac53f106127e182960dab1f99`.

Exact changed files:

- `Game/scripts/equipment/leg_definition.gd`
- `Game/resources/equipment/knee_dash_legs.tres`
- `Game/scripts/equipment/world_leg_pickup.gd`
- `Game/scenes/equipment/world_leg_pickup.tscn`
- `Game/scripts/hud.gd`
- `Game/scenes/hud.tscn`
- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/071_cyberlancers_icon_integration/cyberlancers_icon_integration_report.md`

## Icon and presentation contract

`LegDefinition` now exposes optional typed `icon_texture: Texture2D`. `knee_dash_legs.tres` assigns `res://assets/sprites/equipment/legs/cyberlancers/cyberlancers_knee_strike_icon_32x32.png`; Standard Legs leave the field empty.

WorldLegPickup selects the icon when present, clears and hides its held-visual fallback, and renders the icon at native 32x32 size with nearest filtering and no panel or frame. When the exact stored LegInstance changes, the presentation rebuilds. An empty icon clears the icon and restores the existing held_visual_scene fallback.

HUD reads the currently equipped definition and renders the same texture inside a separately authored 56x56 dark Panel with a thin red/orange border. The frame is hidden, and its texture is cleared, for definitions without an icon. Existing leg text and controller ownership are unchanged.

## Preserved behavior

- The 64x64 Cyberlancers player-body sprite and scene are unchanged.
- Standard Legs retain their original definition, fallback scene, appearance, and C no-op behavior.
- Pickup interaction, labels, collision, gravity, launch, friction, cooldown, exact-instance transfer, and pickup reporting are unchanged.
- Knee Dash, Bleeding, movement, crouch, Slide, Jetpack, weapons, Shield, Hook, missions, extraction, and input behavior are unchanged.
- The world pickup has no Cyberlancers equipment-id special case.

## Validation performed

- Clean `main` synchronization verified at the required base before editing.
- Confirmed the runtime icon and source-art PNG exist.
- Confirmed runtime icon dimensions are 32x32, pixel format is RGBA-capable `Format32bppArgb`, size is 1465 bytes, and SHA-256 is `64e4318760cb9990afe1ce16c364d24f2362b8814460dee2920fdf6c2a6ff28b`.
- Confirmed the existing 64x64 player PNG and Cyberlancers scene were not changed.
- Reviewed the complete implementation diff and exact staged file list.
- Confirmed no WorldLegPickup equipment-id special case exists.
- Confirmed icon/fallback paths are mutually exclusive and empty icons use the prior fallback.
- Confirmed the HUD frame is hidden for standard definitions and shown from the definition texture for Cyberlancers.
- Ran `git diff --check` and staged diff checks.
- Ran the tracked-project Cyrillic scan excluding `.git` and binary files.
- Confirmed no UID or manually authored import file was created or changed by Task 071.

## Checks not performed

No compatible Godot 4.7.2 executable was available, so parser, import, startup, visual, and runtime validation were not performed. Windows validation remains pending.

## Known limitations

The world Cyberlancers pickup intentionally uses only the new frameless 32x32 icon. Dedicated folded or ground Cyberlancers artwork remains deferred.

## Publication

Implementation commit: `8ff649cfea8070b0f7f5a40bb522948f0ebe6adb` (`feat: add Cyberlancers pickup and HUD icon`), pushed successfully to `origin/main`.

Documentation commit: to be recorded after this report-only commit and push.

## Focused Windows checklist

1. Start the main scene at 1280x720.
2. Confirm a Cyberlancers pickup shows the frameless knee-strike icon.
3. Confirm the old full-height player visual is absent from the ground pickup.
4. Confirm the CYBERLANCERS label and F prompt remain readable.
5. Equip Cyberlancers and confirm the existing 64x64 player sprite remains active.
6. Confirm the upper-right HUD shows the icon inside the separate dark red/orange frame.
7. Confirm the frame does not overlap status text, weapon slots, left-arm status, or the viewport edge.
8. Swap to Standard Legs and confirm the HUD frame disappears.
9. Confirm dropped Cyberlancers preserves its exact instance and cooldown.
10. Confirm Standard Legs retain the previous fallback world visual.
11. Confirm the helicopter loot-case Cyberlancers reward uses the frameless icon.
12. Verify Knee Dash, Bleeding, movement, crouch, Slide, Jetpack, weapons, Shield, Hook, pickups, missions, and extraction.
13. Confirm Godot reports no parser or runtime errors.
