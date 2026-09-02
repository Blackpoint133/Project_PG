---
name: godot-run-and-gun
description: Implement or review OTG Pixel Game gameplay, player equipment, weapons, abilities, enemies, levels, UI, and Godot testing according to the approved run-and-gun design.
---

# Godot Run-and-Gun Gameplay

Before gameplay implementation, architecture, equipment, weapons, abilities, enemies, levels, UI, or Godot testing work in this repository, read:

- `DEV/docs/GAME_DESIGN.md`
- `DEV/docs/TECHNICAL_DESIGN.md`

Preserve the approved gameplay behavior and modular equipment boundaries. The player root is `CharacterBody2D`; body, left arm, right arm, legs, weapon, and jetpack visuals are separate replaceable components in independent slots: `left_arm`, `right_arm`, `legs`, `weapon`, and `jetpack`.

Keep weapon behavior separate from arm visuals, arm abilities separate from weapon behavior, leg abilities separate from leg visuals, and jetpack visuals separate from the shared flight mechanic. Use data-driven custom `Resource` definitions where appropriate and reusable world pickups for dropped equipment.

Do not implement future bleeding or reflected-damage-wave behavior; preserve their extension points. Placeholder visuals must remain swappable for final sprites without altering gameplay systems. Prefer focused composition over deep inheritance and avoid unnecessary abstraction in the first vertical slice.
