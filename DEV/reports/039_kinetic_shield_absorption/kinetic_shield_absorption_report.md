# Task 039: Kinetic Shield Absorption and Counter-Blast

## Objective

Replace the temporary time-draining Shield runtime with an indefinite kinetic absorber. Incoming hostile attacks build stored charge on the exact Shield Left Arm instance, overflow reaches the Player, and Q plus LMB releases stored charge as a cyan counter-projectile.

## Confirmed base commit

`7770700900c42e13959da09eb8d09ba337fa6423`

## Completed changes

- Replaced active drain, recharge delay, and depletion-latch state with per-instance stored charge.
- Added typed Shield absorption, saturation, and counter-blast behavior.
- Moved the shield controller from the freely rotating AimPivot to stable BodyRoot space.
- Added vertical standing/crouching shield geometry selected by horizontal mouse side only.
- Added enemy projectile and Player damage foundation scripts.
- Added the focused `kinetic_shield_test.tscn` scene with a deterministic hostile emitter, Shield pickup, target dummy, floor, HUD, and instructions.
- Added signal-driven stored-charge and Player-health HUD presentation.

## Exact changed and created file list

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/reports/039_kinetic_shield_absorption/kinetic_shield_absorption_report.md`
- `Game/resources/equipment/shield_ability.tres`
- `Game/scenes/dev/kinetic_shield_test.tscn`
- `Game/scenes/hud.tscn`
- `Game/scenes/player.tscn`
- `Game/scenes/projectiles/enemy_projectile.tscn`
- `Game/scenes/projectiles/kinetic_counter_projectile.tscn`
- `Game/scripts/abilities/enemy_projectile.gd`
- `Game/scripts/abilities/hostile_projectile_emitter.gd`
- `Game/scripts/abilities/kinetic_counter_projectile.gd`
- `Game/scripts/abilities/shield_controller.gd`
- `Game/scripts/equipment/left_arm_ability_definition.gd`
- `Game/scripts/equipment/left_arm_instance.gd`
- `Game/scripts/hud.gd`
- `Game/scripts/player.gd`
- `Game/scripts/player_damage_receiver.gd`

## Energy and charge architecture

`LeftArmAbilityDefinition` owns immutable maximum-charge and counter-projectile tuning. `LeftArmInstance` owns the mutable `ability_charge` value. Shield swaps continue transferring the exact instance, so stored charge moves with the dropped or equipped arm without reset. No passive drain, recharge, delay, or depletion-release state remains in active Shield code.

## Shield state and absorption

Q activates a valid Shield regardless of stored charge and keeps it active indefinitely while held. New Shield instances start with zero charge. `absorb_damage(incoming_damage: float) -> float` clamps negative input to zero, returns all damage when inactive, fills only available capacity when active, and returns overflow. Full storage is represented by the typed saturated state signal. Each enemy projectile resolves its overlapping ShieldArea to the parent ShieldController and marks its shield interaction as processed once.

## Geometry and orientation

The ShieldController is a direct child of `BodyRoot`, not `AimPivot`, so mouse Y and weapon rotation cannot tilt the barrier. Standing collision and visual coverage are 96 pixels from local Y -96 through 0. Crouching coverage is 64 pixels from local Y -64 through 0. The panel is placed at local X +/-44 through +/-60, with a 16-pixel collision thickness centered at X +/-52. Mouse X selects the side; the horizontal dead zone preserves the current side.

## Counter-blast and firing lock

While active, Player disables WeaponController firing before processing LMB. A distinct `fire` press calls ShieldController counter-blast logic, which spawns one configured cyan projectile at 900 speed with a 2-second lifetime and damage equal to stored charge, then clears charge. The shield remains active while Q is held. Zero charge produces no projectile and no weapon shot. Weapon ammunition and cadence are untouched.

## Enemy projectile and Player damage foundation

The focused hostile projectile uses layer 5 / integer 16 and mask 67 for world layer 1, Player layer 2, and active shield layer 7 / integer 64. It processes one shield absorption and then applies only the remainder to Player. `PlayerDamageReceiver` provides 100 maximum health, clamped damage, and typed health signals; full death behavior remains deferred.

## Checks actually performed

- Confirmed the clean required base and fast-forwarded to `7770700900c42e13959da09eb8d09ba337fa6423`.
- Reviewed all changed scripts, scenes, resources, and documentation.
- Confirmed `Game/project.godot` is unchanged.
- Confirmed no UID files were created or modified.
- Confirmed the old active drain, recharge, delay, and release-latch fields are absent from active Shield code.
- Audited typed Shield signals, instance charge ownership, projectile configure-before-tree ordering, and collision masks.
- Ran `git diff --check`.
- Checked the complete diff and changed-file scope.
- No Godot executable is available in this environment, so GDScript parse/runtime validation was not performed.
- No Windows or Godot runtime validation was performed or claimed.

## Pending Windows visual/runtime checklist

- Launch `kinetic_shield_test.tscn` in Godot 4.7.2 Standard and confirm no parser/runtime errors.
- Equip Shield with F and confirm the inactive arm remains a compact emitter.
- Hold Q while aiming right and left; verify the panel is vertical, full-height, stable against mouse Y, and mirrored to the selected side.
- Verify standing height is 96 pixels and crouching height is 64 pixels with both feet and the panel baseline at local Y 0.
- Face the hostile emitter and absorb five 20-damage projectiles to reach 100 charge; verify the sixth projectile damages Player for overflow.
- Aim away from the emitter and confirm the projectile reaches Player instead of the unprotected side being blocked.
- Confirm health displays 100 and decreases only from unabsorbed damage.
- Press LMB while active with stored charge and confirm one cyan counter-blast, exact charge damage, charge reset, no weapon ammo consumption, and continued Shield activity.
- Confirm Q release hides the panel and restores normal rifle firing; confirm zero-charge LMB does not fire the rifle.
- Confirm the target dummy receives one counter-blast hit and that the projectile expires or stops correctly at world collision.

## Known risks or limitations

- Godot parsing and runtime behavior remain unverified in this environment because the Godot executable is unavailable.
- The Player damage receiver has no death, invulnerability, knockback, or final damage feedback yet.
- Enemy projectile handling is a focused deterministic test foundation, not a complete enemy attack system.
- Counter-projectile damage is converted to the existing integer target-damage API at impact; the prototype charge values are integer-valued in the test flow.
- Final plasma artwork, shader, particles, sounds, and reflected damage wave remain deferred.

## Recommended next step

Run the focused Windows Godot validation, then extend the hostile projectile and Player damage systems only after the absorption, overflow, counter-blast, and side-orientation behavior is confirmed.
