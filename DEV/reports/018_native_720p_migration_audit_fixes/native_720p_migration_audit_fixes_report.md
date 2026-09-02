# Report: 018_native_720p_migration_audit_fixes

## Task objective

Correct three audited native 720p migration findings without changing gameplay tuning, collision, arena geometry, projectile behavior, modular architecture, or input mappings.

## Root causes and corrections

### Finding 1: gravity in the wrong section

`physics/2d/default_gravity=1960.0` was mistakenly written inside `[rendering]`, which does not define the intended ProjectSettings path. It now lives in a dedicated `[physics]` section as:

```ini
[physics]

2d/default_gravity=1960.0
```

The resulting active ProjectSettings path is exactly `physics/2d/default_gravity`, and the value remains `1960.0`. `[rendering]` now contains only rendering settings.

### Finding 2: HUD font size

HUD rectangles were doubled during the native migration, but default font presentation was not. `MovementLabel`, `WeaponLabel`, and `ControlsLabel` now use explicit `theme_override_font_sizes/font_size = 32`, preserving text, functionality, and integral coordinates.

### Finding 3: misleading comparison values

The comparison scene still showed old 640x360-era figures. It now displays mathematically correct native equivalents:

| Native height | Share of 720 | Label |
| --- | --- | --- |
| 56 PX | 7.8% | NATIVE |
| 80 PX | 11.1% | MEDIUM |
| 96 PX | 13.3% | LARGE and SELECTED |

Every silhouette is authored at actual native dimensions with integer coordinates and no node scaling or fractional transforms. All feet share the same baseline, and torso, legs, jetpack, shoulder pivot, and weapon remain separate. The 96-pixel silhouette matches the active player proportions.

## Final comparison dimensions

- 56 PX: torso 24 tall from Y -56 to -32; legs 32 tall from Y -32 to 0; jetpack 4x10; shoulder Y -44.
- 80 PX: torso 32 tall from Y -80 to -48; legs 48 tall from Y -48 to 0; jetpack 9x20; shoulder Y -60.
- 96 PX: torso 40 tall from Y -96 to -56; legs 56 tall from Y -56 to 0; jetpack 14x24; shoulder Y -72.

## Exact changed files

- `Game/project.godot`
- `Game/scenes/hud.tscn`
- `Game/scenes/dev/player_scale_comparison.tscn`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/018_native_720p_migration_audit_fixes/native_720p_migration_audit_fixes_report.md`

## Checks performed

- Confirmed branch `main`, clean working tree, and synchronized history including `eaa88e996fed22716efc538eb8b304b1dfba2f84`.
- Verified `[physics]` contains `2d/default_gravity=1960.0`.
- Verified `[rendering]` no longer contains `physics/2d/default_gravity`.
- Verified every HUD label has explicit font size 32.
- Verified comparison heights are exactly 56, 80, and 96.
- Verified labels use 7.8%, 11.1%, and 13.3% of 720 and that the 96 PX option is marked SELECTED.
- Confirmed active gameplay files outside the approved scope are unchanged.
- Reviewed the complete Git diff before staging.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Godot runtime validation was not performed and remains deferred to Windows.

## Pending Windows checks

- Verify gravity timing remains equivalent after the corrected ProjectSettings path.
- Verify HUD labels are readable at the doubled 32-pixel font size.
- Run the scale comparison scene and verify labels, baseline, and selected silhouette.

## Risks or limitations

- The comparison silhouettes remain placeholder geometry.
- Visual overlap should be confirmed after the label font increase.

## Recommended next step

Perform the Windows checks, then continue with the next approved environment or gameplay task.
