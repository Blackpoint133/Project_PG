# Task 024: Weapon Pickup and Swap Foundation

## Objective

Create a reusable interaction foundation and physical world weapon pickup so the player can equip the arena shotgun with F, visibly drop the rifle, and collect the rifle again with its ammunition state preserved.

## Completed changes

- Added a Player child `InteractionSensor` Area2D with a 100-pixel CircleShape2D, layer 0, and mask 32.
- Added dynamic interaction candidate tracking, nearest-candidate selection, prompt signaling, availability refresh, and F-independent `try_interact(actor)` behavior.
- Added `WorldWeaponPickup` as a deterministic falling `CharacterBody2D` on collision layer 32 with world collision mask 1.
- Added configurable weapon definitions, placeholder weapon visuals, weapon names, interaction cooldowns, and upward/opposite-facing launch behavior.
- Added Player weapon swap API, pickup replacement, and immediate interaction prompt refresh.
- Converted Player WeaponSlot to dynamic held visual installation from `WeaponDefinition.held_visual_scene` and validated each direct `Muzzle` Marker2D.
- Added a distinct shorter/thicker shotgun placeholder and references for rifle and shotgun held visuals.
- Added an arena shotgun pickup and the physical F input action.
- Updated the HUD with a presentation-only interaction prompt and the F equip control hint.

## Exact changed file list

- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/024_weapon_pickup_and_swap_foundation/weapon_pickup_and_swap_foundation_report.md`
- `Game/project.godot`
- `Game/resources/weapons/automatic_rifle.tres`
- `Game/resources/weapons/shotgun.tres`
- `Game/scenes/arena.tscn`
- `Game/scenes/equipment/world_weapon_pickup.tscn`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/player/modules/placeholder_shotgun.tscn`
- `Game/scripts/combat/weapon_definition.gd`
- `Game/scripts/equipment/world_weapon_pickup.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/interaction/interaction_controller.gd`
- `Game/scripts/player.gd`

## Interaction architecture

`InteractionSensor` is a reusable Area2D boundary under Player. It detects layer-6 physics bodies, stores typed `Array[Node2D]` candidates, validates the dynamic `get_interaction_prompt(actor)` and `interact(actor)` contract, and selects the nearest currently actionable candidate. Dynamic return values are held in explicitly typed `Variant` variables before validation. The sensor never reads keyboard input; Player owns F input and forwards the actor context.

## Pickup and collision behavior

`WorldWeaponPickup` uses a `CharacterBody2D` root with collision layer 32, world mask 1, and a small shape centered at `Y -4` so the root origin is the ground-contact point. It falls using project gravity, settles with zero downward velocity, and supports deterministic launch velocity. A 0.35-second interaction cooldown prevents accidental immediate re-pickup after a drop. Invalid definitions display as `UNKNOWN WEAPON` and provide no actionable prompt.

## Weapon swap sequence

F selects the nearest available pickup. Player reads its incoming `WeaponDefinition`, remembers the current definition, equips the incoming definition through `WeaponController`, and receives the held visual through the synchronous `weapon_changed` signal. The old definition is assigned to the same pickup, which is moved above the player and launched upward with horizontal velocity opposite the current facing. The sensor then refreshes its prompt. A pickup containing the currently equipped definition is not actionable and cannot refill, duplicate, destroy, or swap the weapon.

## Ammunition ownership decision

Per-weapon ammunition remains exclusively in `WeaponController` snapshots keyed by `WeaponDefinition`. Pickups contain only a typed weapon definition and never duplicate ammo state. Switching back restores the previous loaded/reserve values, while the switched-away weapon retains its current values.

## Checks actually performed

- Read `AGENTS.md`, the `godot-run-and-gun` skill, `GAME_DESIGN.md`, and `TECHNICAL_DESIGN.md`.
- Fetched origin and fast-forwarded to `fb71850fd18b137b6eceea46124bfc37723b76da` before implementation.
- Confirmed `HEAD` matched `origin/main` and the working tree was clean before implementation.
- Reviewed the complete diff and verified only Task 024 files changed.
- Ran `git diff --check`.
- Confirmed project settings changed only by adding the physical F `interact` action; existing viewport, physics, rendering, movement, weapon, and debug inputs remain unchanged.
- Confirmed existing rifle and shotgun tuning, Task 021/022 corrections, projectile code/collision, target behavior, movement, crouch, facing, aiming, jetpack, and camera code remain preserved.
- Confirmed all configured projectiles are added only after `configure()`.
- Confirmed no generated `.godot` or `.import` content, credentials, executables, caches, unexpected UID changes, or unrelated files are included.
- Confirmed all new script and scene references match repository paths.
- Confirmed no Cyrillic characters exist in tracked project content.

## Pending Windows runtime checks

- Run Godot 4.7.2 on Windows and confirm parser/runtime startup is clean.
- Approach the arena shotgun from both sides and verify the sensor prompt appears, disappears, and selects the nearest candidate.
- Press F to equip the shotgun; verify the rifle visual drops, the shotgun visual installs, and the HUD prompt/name/ammo update immediately.
- Fire the shotgun and verify one shell, eight pellets, one firing event, and preserved shotgun ammo.
- Pick up the dropped rifle and verify the shotgun drops, the rifle visual returns, and rifle ammo is restored from before the first swap.
- Repeat switching and confirm neither weapon refills or duplicates ammo.
- Verify reload cancellation, cooldown reset, 1/2 debug selection, facing, aiming, crouching, movement, jetpack, collisions, target damage, and native 1280x720 presentation.

## Known risks or limitations

Godot runtime and visual validation were not performed in this environment. The pickup currently supports weapons only, uses placeholder visuals, and intentionally does not implement radio, loot case, or other equipment replacement flows. The visual replacement contract requires a direct `Marker2D` child named `Muzzle`.

## Recommended next step

Run the Windows runtime checklist, then extend the reusable pickup/interaction boundaries to the planned radio and loot case flows.
