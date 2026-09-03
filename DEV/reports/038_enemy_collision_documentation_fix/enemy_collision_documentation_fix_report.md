# Task 038: Enemy Collision Documentation Consistency Fix

## Objective

Correct the stale Technical Design statement about target collision so it matches the implemented Task 035 collision contract without changing gameplay files.

## Exact stale statement

`Target dummies use logical layer 3 with zero mask and do not block player movement.`

## Corrected collision contract

Target dummies use logical enemy layer 3, represented by integer collision layer 4, and keep collision mask 0. Player uses collision mask 5 to detect world layer 1 and enemy layer 4. Living targets therefore physically block Player CharacterBody2D movement through `move_and_slide()`. Defeated targets may clear logical enemy layer 3 and become passable.

## Exact changed file list

- `DEV/docs/TECHNICAL_DESIGN.md`
- `DEV/docs/PROJECT_CONTEXT.md`
- `DEV/reports/038_enemy_collision_documentation_fix/enemy_collision_documentation_fix_report.md`

## Gameplay impact

No gameplay files changed. This task changes documentation only; collision behavior, target behavior, and all other systems remain unchanged.

## Checks actually performed

- Confirmed the required base commit and clean preflight state.
- Reviewed the complete documentation diff.
- Ran `git diff --check`.
- Confirmed the stale “do not block player movement” sentence no longer describes TargetDummy.
- Confirmed docs state Player mask 5 detects world 1 and enemies 4.
- Confirmed living-target blocking and defeated-target passability are documented.
- Confirmed Task 037 plasma Shield documentation remains intact.
- Confirmed no Game files, scripts, scenes, resources, project settings, UID files, or historical reports changed.
- Ran the repository Cyrillic scan; no Cyrillic characters found in tracked content.
- No runtime test was performed or claimed.

## Runtime validation status

No runtime validation was performed. Task 037 Windows validation remains pending.

## Known risks or limitations

This correction does not validate the collision behavior in Godot; it only aligns the documentation with the previously implemented Task 035 contract.

## Recommended next step

Run Windows validation for Task 037 plasma Shield runtime, including energy drain/recharge, depletion release latch, visual aim/mirroring, and firing lock.
