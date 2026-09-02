# Project Context

## Current status

The bootstrap project is complete. The approved vertical slice and modular gameplay architecture are documented in `DEV/docs/GAME_DESIGN.md` and `DEV/docs/TECHNICAL_DESIGN.md`. Gameplay implementation has not started.

## Game concept

This is a retro 2D pixel-art run-and-gun game inspired by 16-bit console games. The player runs through a side-scrolling level, jumps onto platforms, uses a weapon, destroys enemies, and can briefly fly with a jetpack.

## First playable demo scope

The first demo should eventually contain:

- one short level lasting approximately one minute;
- movement left and right;
- standing, running, jumping, crouching, shooting, and jetpack flight;
- one weapon;
- one enemy type;
- platforms and ground;
- a basic HUD;
- a start point and finish trigger.

## Future modular player architecture

The following components must remain separate:

- body/head — base character identity and shared state;
- legs — separate visuals, movement animations, and leg abilities;
- arms — separate visuals, animations, and arm abilities;
- weapon — a separate visual object and separate shooting behavior;
- jetpack — a replaceable visual module attached to the body; the first demo may use one shared flight mechanic.

Arms and weapons must not be merged into one permanent sprite because both may change independently.

## Deferred features

The following features are explicitly deferred at this stage:

- complete inventory;
- multiple interchangeable body parts;
- multiple weapons;
- shops and progression;
- save system;
- bosses;
- online features;
- polished final art.

## Pixel viewport

The internal game resolution is 640×360 pixels. The debug window uses 1280×720. Scaling uses `viewport` while preserving the aspect ratio (`keep`) and using integer scaling (`integer`) so pixel art remains crisp. The default CanvasItem texture filtering is nearest.
