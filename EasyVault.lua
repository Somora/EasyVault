local addonName = ...

local CreateFrame = CreateFrame
local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn
local InCombatLockdown = InCombatLockdown

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local configuredWeeklyRewardsFrame

local DEFAULT_VAULT_POSITION = {
    point = "CENTER",
    relativeTo = "UIParent",
    relativePoint = "CENTER",
    x = 0,
    y = 0,
}

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = value
        end
    end
end

local function GetDatabase()
    EasyVaultDB = EasyVaultDB or {}
    EasyVaultDB.minimap = EasyVaultDB.minimap or {}
    EasyVaultDB.weeklyRewardsFrame = EasyVaultDB.weeklyRewardsFrame or {}

    if EasyVaultDB.minimap.minimapPos == nil and EasyVaultDB.minimap.angle ~= nil then
        EasyVaultDB.minimap.minimapPos = EasyVaultDB.minimap.angle
    end

    CopyDefaults(EasyVaultDB.minimap, {
        minimapPos = 225,
        hide = false,
    })
    CopyDefaults(EasyVaultDB.weeklyRewardsFrame, DEFAULT_VAULT_POSITION)

    return EasyVaultDB
end

local function SavePosition(frame, store, defaultRelativeTo)
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    store.point = point or store.point
    store.relativeTo = defaultRelativeTo
    store.relativePoint = relativePoint or store.relativePoint
    store.x = x or 0
    store.y = y or 0
end

local function ApplyPosition(frame, store, defaultRelativeTo, defaultRelativePoint)
    frame:ClearAllPoints()
    frame:SetPoint(
        store.point or defaultRelativePoint,
        _G[store.relativeTo or defaultRelativeTo] or _G[defaultRelativeTo],
        store.relativePoint or defaultRelativePoint,
        store.x or 0,
        store.y or 0
    )
end

local function MakeWeeklyRewardsFrameMovable(db)
    local frame = WeeklyRewardsFrame
    if not frame or InCombatLockdown() or configuredWeeklyRewardsFrame == frame then
        return
    end

    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    -- Preserve Blizzard's scripts and keep addon bookkeeping off its frame.
    frame:HookScript("OnDragStart", function(self)
        if not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    frame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if not InCombatLockdown() then
            SavePosition(self, db.weeklyRewardsFrame, "UIParent")
        end
    end)
    -- ShowUIPanel restores Blizzard's anchors on each open, before OnShow.
    frame:HookScript("OnShow", function(self)
        if not InCombatLockdown() then
            ApplyPosition(self, db.weeklyRewardsFrame, "UIParent", "CENTER")
        end
    end)
    configuredWeeklyRewardsFrame = frame
end

local function ToggleWeeklyRewards(db)
    -- Blizzard's panel manager rejects addon show/hide requests in combat.
    -- Do this before loading or modifying any Blizzard UI.
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage("EasyVault: Weekly Rewards cannot be toggled during combat.", 1, 0.2, 0.2)
        return
    end

    if LoadAddOn and not WeeklyRewardsFrame then
        local loaded = LoadAddOn("Blizzard_WeeklyRewards")
        if not loaded then
            UIErrorsFrame:AddMessage("EasyVault: Could not load the Weekly Rewards UI.", 1, 0.2, 0.2)
            return
        end
    end

    if not WeeklyRewardsFrame then
        return
    end

    MakeWeeklyRewardsFrameMovable(db)

    if WeeklyRewardsFrame:IsShown() then
        HideUIPanel(WeeklyRewardsFrame)
    else
        ShowUIPanel(WeeklyRewardsFrame)
    end
end

local launcher = LDB:NewDataObject(addonName, {
    type = "launcher",
    icon = "Interface\\Icons\\INV_Misc_Coin_01",
    label = "Weekly Rewards",
    OnClick = function(_, button)
        if button == "LeftButton" then
            ToggleWeeklyRewards(EasyVaultDB)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Weekly Rewards", 1, 1, 1)
        tooltip:AddLine(" ")
        tooltip:AddLine("Left-click to open or close the Weekly Rewards window.", 0.8, 0.8, 0.8)
        tooltip:AddLine("Press ESC to close the Weekly Rewards window.", 0.8, 0.8, 0.8)
        tooltip:AddLine("Drag to move this button around the minimap.", 0.8, 0.8, 0.8)
    end,
})

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("PLAYER_LOGIN")
addonFrame:SetScript("OnEvent", function(_, event)
    if event ~= "PLAYER_LOGIN" then
        return
    end

    local db = GetDatabase()
    LDBIcon:Register(addonName, launcher, db.minimap)
end)
