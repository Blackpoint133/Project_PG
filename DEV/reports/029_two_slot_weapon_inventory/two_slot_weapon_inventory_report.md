# Task 029: Two-Slot Weapon Inventory

## Objective

Implement exactly two physical weapon slots with distinct `WeaponInstance` ammunition state, physical pickup transfer, occupied-slot selection, and duplicate weapon support.

## Completed changes

- Added `WeaponInstance` as the runtime owner of a `WeaponDefinition`, loaded ammunition, and reserve ammunition.
- Replaced the definition-keyed ammunition dictionary with two nullable controller slots and one active slot index.
- Restored physical 1/2 input routing for occupied-slot selection only.
- Preserved automatic reload, manual reload, reload cancellation, zero-reserve guards, rifle hold-fire, and shotgun semi-automatic behavior.
- Updated pickups to create fresh instances from scene-authored definitions and transfer exact instances during swaps.
- Allowed duplicate weapon definitions and added a second arena shotgun pickup.
- Added a typed slot-state signal and compact HUD readout for both slots and the active marker.
- Updated design documentation and preserved all historical reports.

## Exact changed and created file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/029_two_slot_weapon_inventory/two_slot_weapon_inventory_report.md`
- `Game/project.godot`
- `Game/scenes/arena.tscn`
- `Game/scenes/hud.tscn`
- `Game/scripts/combat/weapon_controller.gd`
- `Game/scripts/combat/weapon_instance.gd`
- `Game/scripts/equipment/world_weapon_pickup.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`

## Ownership and transfer architecture

`WeaponDefinition` remains shared immutable configuration. Each inventory slot and world pickup owns one distinct `WeaponInstance`; ammunition is stored directly on that object and is never keyed by definition. Scene pickups create one fresh instance in `_ready()`. F interaction takes the pickup instance, fills the first empty slot, or replaces the active slot and returns the exact outgoing instance to the same pickup before launch. Duplicate rifle and shotgun definitions are therefore valid and retain independent ammunition.

## Signal ordering

Initial setup emits `weapon_changed`, `weapon_ammo_changed`, then `weapon_slots_changed`. Slot selection and active-slot replacement cancel reload/reset cooldown, emit `weapon_changed`, emit active ammo, optionally start reload, then emit `weapon_slots_changed`. A shot emits `fired`, then active ammo; if that shot reaches zero loaded ammo, `reload_started` follows. Reload completion emits active ammo, then `reload_completed`.

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Fetched origin and fast-forwarded to `7d60a60add9d3f9baf89661ab6745a547233bf30` before editing.
- Confirmed a clean working tree before implementation.
- Reviewed the complete diff and ran `git diff --check`.
- Confirmed no ammunition dictionary keyed by `WeaponDefinition` remains.
- Confirmed duplicate definitions are not rejected and both arena shotgun instances use the same definition while creating distinct runtime instances.
- Confirmed active-slot replacement affects only the active slot and preserves the inactive slot.
- Confirmed the Task 028 zero-ammo reload guard remains intact.
- Confirmed only the requested project input actions were restored; display, physics, rendering, and other input settings were preserved.
- Confirmed no generated Godot content, credentials, executables, caches, unexpected UID files, or historical report edits were included.
- Ran the repository Cyrillic scan; no Cyrillic characters were found in tracked project content.
- No Godot runtime validation was performed or claimed.

## Pending manual checks

- Launch Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Verify slot 1 starts with a rifle, slot 2 starts empty, and selecting an empty or active slot does nothing.
- Pick up the first shotgun with F and verify it fills slot 2 without dropping the rifle.
- Fire both weapons to different ammunition states, switch with 1/2, and verify independent state.
- Pick up the second shotgun and verify duplicate definitions create independent shotgun instances.
- With both slots occupied, pick up a weapon and verify only the active instance is dropped and launched.
- Recollect dropped weapons and verify exact ammunition state transfer.
- Verify held visuals, Muzzle firing, HUD slot markers, prompts, reload behavior, movement, crouch, aim, facing, jetpack, targets, and native 1280x720 layout.

## Known risks or limitations

Godot runtime/parser validation was unavailable in this environment. The typed nullable `Array[WeaponInstance]` and signal parameter behavior should be confirmed by Godot 4.7.2 on Windows. Final equipment types beyond weapons remain pending.

## Recommended next step

Run the complete Windows two-slot and duplicate-shotgun checklist, then extend the same ownership boundary to the next approved equipment type.
