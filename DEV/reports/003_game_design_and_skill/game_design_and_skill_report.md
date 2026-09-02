# Report: 003_game_design_and_skill

## Task objective

Define the approved gameplay vertical slice, document a modular data-driven architecture for Godot 4.7.2 Standard, and create the repository-scoped gameplay skill without implementing gameplay or changing files under `Game/`.

## Completed changes

- Added `DEV/docs/GAME_DESIGN.md` with the approved concept, controls, initial equipment, vertical-slice sequence, equipment abilities, leg replacement sequence, prototype enemies, and prototype UI.
- Added `DEV/docs/TECHNICAL_DESIGN.md` with scenes, player composition, state responsibilities, equipment resources, scripts, signals, collision layers, data flow, and testing intent.
- Added the repository skill `.agents/skills/godot-run-and-gun/SKILL.md` with normal implicit invocation retained through the skill-creator default.
- Updated `DEV/docs/PROJECT_CONTEXT.md` to link the approved design and technical design and record that gameplay implementation has not started.
- No gameplay implementation was performed and no visual assets were added.

## Exact created and changed file list

- `DEV/docs/GAME_DESIGN.md` — created.
- `DEV/docs/TECHNICAL_DESIGN.md` — created.
- `.agents/skills/godot-run-and-gun/SKILL.md` — created.
- `DEV/reports/003_game_design_and_skill/game_design_and_skill_report.md` — created.
- `DEV/docs/PROJECT_CONTEXT.md` — changed.

## Design decisions recorded

- The vertical slice is continuous and linear, lasts approximately 80 to 100 seconds, and uses placeholder visuals that can later be replaced without changing gameplay systems.
- The five equipment slots are independent and represented as `left_arm`, `right_arm`, `legs`, `weapon`, and `jetpack`.
- Weapon behavior, arm abilities, leg abilities, and jetpack visuals are behaviorally separate from each other and from their replaceable visual modules.
- Equipment tuning is data-driven with custom Godot `Resource` definitions; dropped equipment uses reusable world pickup scenes.
- Character state remains explicitly decomposed into locomotion, crouch, airborne, jetpack flight, equipment swap, shielding, hook use, knee dash, damage, and death.
- Future bleeding and reflected-wave effects are reserved as extension points only and are explicitly not implemented.
- The leg swap locks control, hovers the legless character, detaches only the visual leg module, attracts and attaches the replacement with electrical arcs, and returns control after roughly one second with temporary invulnerability.
- Collision layers are provisionally allocated for world, player, enemies, player attacks, enemy attacks, interactables, and sensor-only equipment visuals.

## Skill structure and validation

The skill is a concise, instruction-only `SKILL.md` under `.agents/skills/godot-run-and-gun/`. It contains YAML frontmatter with the required `godot-run-and-gun` name and a discriminating description, and its body routes Codex to both design documents before relevant gameplay work. It preserves the approved behavior and modular equipment boundaries, does not duplicate general repository policies, and contains no scripts, assets, examples, or unnecessary folders.

Validation performed:

- Validated with the skill-creator `scripts/quick_validate.py` validator: PASSED.
- Confirmed the skill folder contains only `SKILL.md`.
- Confirmed the description routes gameplay work to this repository and the body references both required design documents.

## Checks actually performed

- Read `AGENTS.md`, `README.md`, `DEV/docs/PROJECT_CONTEXT.md`, and all existing reports under `DEV/reports/`.
- Ran the built-in skill-creator validator: PASSED.
- Ran `git diff --check`: no whitespace errors.
- Ran `git diff -- Game`: empty output; no changes under `Game/`.
- Scanned all tracked project content outside `.git` for Cyrillic characters: zero matches.
- Reviewed the complete Git diff before commit: only the five task-related files changed.

## Pending manual checks

- Godot execution and visual validation were not performed because this task was documentation-only.
- Future gameplay tasks should verify controls, equipment behavior, and UI in Godot after implementation.

## Known risks or limitations

- The architecture is planning-level; exact node and script names may be refined during implementation while preserving responsibility boundaries.
- Collision layer numbers are a starting allocation and should be finalized in the first gameplay implementation task if conflicts appear.
- The skill validator checks structure and frontmatter, not runtime behavior of future gameplay.

## Git publication result

Committed to `main` with the message `docs: define vertical slice and gameplay skill` and pushed normally to `origin/main`. `HEAD` matched `origin/main` after push and the working tree was clean.
