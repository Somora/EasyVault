# Retail 12.1.5 compatibility review

Reviewed on 2026-10-23: EasyVault.lua, every embedded library, and the TOC load order.

## Findings and changes

1. **Panel state (high):** WeeklyRewardsFrame registers itself as a Blizzard UIPanel.
   Calling Show/Hide directly bypassed that manager; additionally registering it in
   UISpecialFrames gave ESC another direct-Hide route. Use ShowUIPanel/HideUIPanel
   and the normal panel ESC handling instead. Do not remove its panel registration
   or modify UIPanelWindows/UIPanelLayout attributes to work around restrictions.
2. **Combat restrictions (high):** The panel manager explicitly rejects tainted
   addon show/hide requests in combat. Check InCombatLockdown before loading,
   configuring, or toggling the window; explain the blocked click to the user.
   Also prevent starting a drag or restoring/saving its position during combat.
   No requests are queued to open unexpectedly after combat.
3. **Shared library compatibility (high):** The embedded LibDataBroker imitation
   advertised upstream revision 4 but lacked RegisterCallback, used incompatible
   name storage, and never emitted standard creation/attribute callbacks. Loading
   EasyVault before an addon embedding real LibDBIcon could therefore break that
   addon. The LibDBIcon imitation also lacked the upstream API and upgrade layout.
   Replace both with upstream versions, include CallbackHandler before LDB, and
   use upstream LibStub. Upstream LibDBIcon also uses its own tooltip rather than
   writing launcher text into the shared GameTooltip.
4. **Frame hooks and positioning (medium):** Replace SetScript on Blizzard drag
   handlers with HookScript; keep setup bookkeeping in a local variable instead
   of custom fields on Blizzard's frame. Reapply saved anchors in an OnShow hook,
   because the panel manager positions the frame on every opening. Blizzard's
   own OnShow/OnHide and reward interaction logic remain intact.
5. **Load failures (low):** Check C_AddOns.LoadAddOn's success result and report
   failure instead of silently ignoring a disabled/unavailable Blizzard addon.

## Secrets and API removals

No direct consumers of secret combat data were found: no unit identities, health,
auras, spell cooldowns, damage meters, cast IDs, or combat-log events. The launcher
uses static text/icon data, saved settings, and ordinary UI geometry. No deprecated
item/currency/PvP globals removed in 12.1.5 are used. No changes to protected
cooldown frames or secret-driven texture aspects are made. Adding issecretvalue
checks to every number would not address the actual panel/library problems.

This is a source review, not proof that an arbitrary addon combination cannot
taint shared UI. WoW's secure execution, secret propagation, and protected actions
cannot be reproduced by the standalone Lua mocks.

## Validation

Run `lua tests/smoke.lua` from the repository root with Lua 5.1. The test loads the
actual embedded libraries and addon against mocks and checks LDB callbacks,
minimap position migration, right clicks, failed loading, combat clicks before
and after loading, preserved Blizzard scripts, combat drag prevention, saved
position across panel reopenings, duplicate hooks, and repeated library loading.

Before publishing a follow-up release, verify in the 12.1.5 client:

- Enable Lua errors and, if investigating blocked actions, `/console taintLog 1`.
  Reload, open/close via the minimap button, ESC, and Blizzard's close button;
  check that the game menu and other panels still open normally.
- Move the window, close/reopen it, reload, and verify the saved position.
- Try the launcher in combat before its first use and after opening it once.
  It should show the combat message without loading or toggling the panel.
- Repeat with a broker display, minimap button collector, and other addons
  embedding LDB/LibDBIcon, including different load orders.
- Open the actual Great Vault and verify reward previews and the normal reward
  selection flow. Do not claim a reward solely for this test.
- Review Lua errors, blocked-action messages, and Logs/taint.log. Turn logging
  off afterwards with `/console taintLog 0`.

## Sources

- [Blizzard Weekly Rewards Lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_WeeklyRewards/Blizzard_WeeklyRewards.lua): RegisterUIPanel, OnShow/OnHide, reward closing.
- [Blizzard panel manager](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIParentPanelManager/Shared/UIParentPanelManager.lua): combat checks, panel anchoring, ShowUIPanel/HideUIPanel, CloseSpecialWindows.
- [Blizzard Weekly Rewards XML](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_WeeklyRewards/Blizzard_WeeklyRewards.xml): frame templates and handlers.
- [Embedded upstream versions](../Libs/UPSTREAM.md).

The UI links above are extracted Blizzard sources mirrored by Gethe and use the
moving live branch as inspected on the review date.
