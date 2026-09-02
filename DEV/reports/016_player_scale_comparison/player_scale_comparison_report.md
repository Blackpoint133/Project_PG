# Report: 016_player_scale_comparison

## Task objective

Create a dedicated visual calibration scene for comparing 28, 40, and 48 logical-pixel player heights without choosing or applying a final gameplay scale.

## Viewport and output explanation

The project renders its gameplay at a real 640x360 logical viewport and then displays that image in a 1280x720 window. The window override does not add world space; integer output stretching doubles each logical pixel uniformly. Because every silhouette in this scene is authored directly in logical pixels and no camera zoom or fractional scaling is used, the 720p output stretches the same 640x360 world and does not change the characters' relative world size.

## Exact comparison dimensions

All three characters share feet at local Y 0 and a shared scene baseline at Y 280. Positions, sizes, offsets, line widths, and pivot positions use integer values.

### CURRENT 28 PX

| Component | Size / geometry |
| --- | --- |
| Torso | 12x28 region above legs: Y -28 to -16, width 12 |
| Legs | 12 wide, 16 tall: Y -16 to 0 |
| Jetpack | 4x8 at left side |
| Left arm | Shoulder to +5/+1, width 2 |
| Right arm | Shoulder to +5/-1, width 2 |
| Rifle | 10 long, width 3, muzzle at +10 |
| Shoulder pivot | Y -22 |
| Muzzle | Weapon local X +10 |

### MEDIUM 40 PX

| Component | Size / geometry |
| --- | --- |
| Torso | 16 wide, 16 tall: Y -40 to -24 |
| Legs | 16 wide, 24 tall: Y -24 to 0 |
| Jetpack | 6x10 at left side |
| Left arm | Shoulder to +7/+1, width 3 |
| Right arm | Shoulder to +7/-1, width 3 |
| Rifle | 14 long, width 4, muzzle at +14 |
| Shoulder pivot | Y -30 |
| Muzzle | Weapon local X +14 |

### LARGE 48 PX

| Component | Size / geometry |
| --- | --- |
| Torso | 20 wide, 20 tall: Y -48 to -28 |
| Legs | 20 wide, 28 tall: Y -28 to 0 |
| Jetpack | 7x12 at left side |
| Left arm | Shoulder to +8/+1, width 3 |
| Right arm | Shoulder to +8/-1, width 3 |
| Rifle | 18 long, width 4, muzzle at +18 |
| Shoulder pivot | Y -36 |
| Muzzle | Weapon local X +18 |

Displayed viewport-height shares are 7.8%, 11.1%, and 13.3%.

## Gameplay confirmation

Gameplay files were not changed:

- `player.gd` unchanged
- `player.tscn` unchanged
- movement, collision, and combat scripts unchanged
- HUD unchanged
- arena unchanged
- `project.godot` and input mappings unchanged
- the current main scene remains unchanged

The comparison scene is standalone and requires no script.

## Checks performed

- Confirmed the working tree was clean and synchronized with `origin/main`.
- Confirmed `origin/main` includes `45b0853ee0bb7cdd1a81bf010146ab7d7e85b0ab`.
- Confirmed all scene positions, dimensions, offsets, and widths use integers.
- Confirmed all three feet meet the same Y 280 baseline.
- Confirmed silhouettes are authored at real 28, 40, and 48 logical-pixel heights rather than fractional scaling.
- Confirmed the main scene and gameplay scripts are unchanged.
- Reviewed the complete Git diff before commit.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Visual Godot validation was not performed and remains a Windows manual check.

## Pending Windows manual checks

- Open `Game/project.godot` in Godot 4.7.2 Standard.
- Open `Game/scenes/dev/player_scale_comparison.tscn`.
- Press F6.
- At the 1280x720 window, compare silhouettes and available equipment detail at each size.

## Risks or limitations

- The comparison silhouettes use the existing placeholder color language and are not final artwork.
- Proportions are intentionally simple and may require tuning after the final scale is chosen.

## Recommended next step

Run the comparison scene on Windows, choose the final gameplay scale, and apply it in a separate focused task.
