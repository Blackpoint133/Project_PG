# Report: 019_scale_comparison_cleanup

## Task objective

Correct the remaining geometry and label-layout inconsistencies in the player-scale comparison scene without changing active gameplay, project settings, HUD, physics, player, arena, targets, weapons, or input mappings.

## Root cause

The earlier comparison rework preserved old proportional guesses instead of exact native geometry, used approximate weapon lengths and widths, retained both an obsolete 48 PX label and a redundant 96 PX label, and left the title with default font presentation.

## Exact changed files

- `Game/scenes/dev/player_scale_comparison.tscn`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/019_scale_comparison_cleanup/scale_comparison_cleanup_report.md`

## Final geometry table

| Option | Total height | Torso | Legs | Jetpack | Shoulder Y | Weapon position X | Weapon length | Weapon width |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 56 PX | 56 | 24x24, Y -56 to -32 | 24x32, Y -32 to 0 | 8x16, (-18, -48) to (-10, -32) | -44 | 8 | 20 | 6 |
| 80 PX | 80 | 32x32, Y -80 to -48 | 32x48, Y -48 to 0 | 12x20, (-24, -64) to (-12, -44) | -60 | 10 | 28 | 8 |
| SELECTED 96 PX | 96 | 40x40, Y -96 to -56 | 40x56, Y -56 to 0 | 14x24 at active player placement | -72 | 14 | 36 | 8 |

All three options share the Y 560 feet baseline. Every coordinate, dimension, offset, and line width is integer-authored. No node scaling or fractional transforms are used.

## Label-layout result

- Title uses explicit 32-pixel font size and has a 44-pixel-tall rectangle.
- Option labels are exactly one per silhouette and non-overlapping.
- Labels display `56 PX  7.8%`, `80 PX  11.1%`, and `SELECTED  96 PX  13.3%`.
- The redundant second 96 PX label was removed.
- The footnote remains readable at 32 pixels.
- All labels remain inside the 1280x720 viewport.

## Checks performed

- Compared the selected 96 PX option with the active player and placeholder module scenes before editing.
- Verified total heights are exactly 56, 80, and 96.
- Verified weapon lengths are exactly 20, 28, and 36.
- Verified the 96 PX proportions match the active player modules.
- Verified percentages are correct for a 720-pixel viewport.
- Verified there is only one label for each option.
- Verified no active gameplay file changed.
- Reviewed the complete Git diff before staging.
- Ran `git diff --check`: passed.
- Scanned all tracked content outside `.git` for Cyrillic characters: zero matches.
- Godot visual validation was not performed and remains deferred to Windows.

## Pending Windows visual check

- Run `Game/scenes/dev/player_scale_comparison.tscn` with F6.
- Confirm three silhouettes, shared baseline, non-overlapping labels, and selected 96 PX option.

## Risks or limitations

- The silhouettes remain placeholder geometry and are not final artwork.
- Label spacing should be visually confirmed after Godot loads the explicit font sizes.

## Recommended next step

Perform the Windows visual check and continue with the next approved environment or gameplay task.
