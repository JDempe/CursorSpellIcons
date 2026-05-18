# Cursor Spell Icon

A World of Warcraft retail addon that displays the active spell's icon next to your cursor while you are targeting — both for ground-placement reticle spells (AoE circles) and cursor-glow unit-targeted spells.

## Features

- **Spell icon follows your cursor** during targeting, for both reticle and interactive targeting modes
- **Fully configurable** via the Blizzard Settings UI (`Escape → Options → AddOns → Cursor Spell Icons`)
- **Live preview** in the settings panel showing exactly how your icon will look and where it will appear relative to the cursor
- Minimap button and Addon Compartment button support

## Settings

| Section | Options |
|---|---|
| **Minimap** | Show/hide minimap button; show/hide in Addon Button Compartment |
| **Position** | X Offset, Y Offset (how far from the cursor the icon appears) |
| **Appearance** | Icon Size, Icon Zoom (crops built-in border art) |
| **Spell Name** | Show/hide; Text Location (above/below/left/right); Text Size; Text Color; Font |
| **Border** | Show/hide; Border Color; Border Size |

## Slash Commands

| Command | Description |
|---|---|
| `/csi` | Open the settings panel |

## Installation

1. Copy the `CursorSpellIcon` folder into `World of Warcraft\_retail_\Interface\AddOns\`
2. Restart WoW or reload your UI (`/reload`)
3. The addon activates automatically — no configuration required to get started

## Requirements

- World of Warcraft Retail (Interface 12.0.0+)
- No external dependencies beyond the bundled libraries

## Bundled Libraries

- AceAddon-3.0, AceDB-3.0, AceEvent-3.0
- AceConfig-3.0, AceGUI-3.0, AceConfigDialog-3.0
- LibDataBroker-1.1, LibDBIcon-1.0
- LibSharedMedia-3.0

## Author

Doryndinan
