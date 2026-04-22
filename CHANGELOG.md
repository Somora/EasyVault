# EasyVault Changelog
All notable changes to this project will be documented in this file.

## Version 1.0 (2024-02-09):
- Initial release of the addon.
- Implemented a minimap button for toggling the Weekly Rewards frame.
- Added tooltip information to provide users with instructions.
- Implemented draggable functionality for the minimap button.

## Version 1.01 (2024-03-24):
- Updated addon for patch 10.2.6 (Plunderstorm).

## Version 1.02 (2024-05-08):
- Updated addon for patch 10.2.7 (The Dark Heart).

## Version 1.03 (2024-07-24):
- Updated addon for The War Within expansion.

## Version 1.04 (2024-08-15):
- Updated addon for The War Within build version 110002.

## Version 1.05 (2024-12-19):
- Updated addon for The War Within build version 110007.

## Version 1.06 (2025-02-26):
- Updated addon for The War Within build version 110100. (Undermine(d))

## Version 1.07 (2025-04-25):
- Updated addon for The War Within build version 110105. (Nightfall)

## Version 1.08 (2025-06-18):
- Updated addon for The War Within build version 110107. (Legacy of Arathor)

## Version 1.09 (2025-08-29):
- Updated addon for The War Within build version 110205. (Ghosts of K'aresh)

## Version 1.10 (2025-09-23):
- Fixed version number in TOC file (incompatibility error in client) 110205 -> 110200
- Drag scripts for WeeklyRewardsFrame are set only once.
- Added tooltip on hover.
- Added checks for WeeklyRewardsFrame and LoadAddOn.
- Cached global functions for minor performance gain.

## Version 1.11 (2025-12-07):
- Updated addon for The War Within build version 110207. (The Warning)

## Version 1.12 (2026-02-22):
- Updated addon for Midnight build version 120001.

## Version 1.13 (2026-04-04):
- Delayed button creation until player login for safer UI initialization.
- Added SavedVariables support so the minimap button and Weekly Rewards window keep their position.
- Improved frame handling by restoring the saved Weekly Rewards position after loading the Blizzard UI.
- Added a button highlight and clearer tooltip instructions.

## Version 1.14 (2026-04-04):
- Reworked the minimap button so it snaps to the minimap edge instead of floating freely.
- Updated the button visuals to better match the standard round minimap addon style.
- Stored the button position as an angle around the minimap, with migration support for older saved positions.

## Version 1.15 (2026-04-04):
- Removed the square pressed/highlight artifact around the minimap button.
- Tuned the minimap radius and icon sizing for a closer match to common minimap addon buttons.
- Added a softer hover/pressed treatment so the button blends in better with default WoW minimap styling.

## Version 1.16 (2026-04-04):
- Switched the minimap button to a dynamic radius based on the actual minimap size for better circular alignment.
- Simplified the hover treatment to avoid square highlight artifacts.
- Adjusted the pressed-state so the button keeps its round minimap-button look while clicking.

## Version 1.17 (2026-04-04):
- Applied circular masking to the minimap button textures to prevent square artifacts in minimap button bars.
- Reduced the button footprint to a more standard minimap addon size for better compatibility with icon collectors.
- Kept the round border styling while improving how the button renders outside the minimap itself.

## Version 1.18 (2026-04-04):
- Rebuilt the minimap icon flow around embedded `LibDataBroker-1.1` and `LibDBIcon-1.0` style libraries.
- Moved EasyVault to a launcher-based minimap button registration model for better compatibility with minimap button managers.
- Migrated stored minimap position data to `minimapPos` while keeping older saved angles working.

## Version 1.19 (2026-04-04):
- Polished the embedded `LibDBIcon` implementation to better match the look and feel of common minimap launcher buttons.
- Added broader minimap shape handling for square, side, and corner-style minimaps.
- Improved tooltip handling so launcher data objects can provide their own tooltip content cleanly.

## Version 1.20 (2026-04-09):
- Added an explicit launcher tooltip for the minimap button so hover text also works reliably through LibDataBroker displays.

## Version 1.21 (2026-04-21):
- Registered the Weekly Rewards frame with `UISpecialFrames` so it can be closed with ESC.
- Updated the minimap tooltip to mention ESC close support.

## Version 1.22 (2026-04-22):
- Updated addon interface version for World of Warcraft patch 12.0.5 (`120005`).
