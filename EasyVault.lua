local addonName = ...

local CreateFrame = CreateFrame
local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

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

local function RegisterWeeklyRewardsFrameForEscape()
    if not WeeklyRewardsFrame or WeeklyRewardsFrame._easyvault_escape_registered then
        return
    end

    UISpecialFrames = UISpecialFrames or {}

    for _, frameName in ipairs(UISpecialFrames) do
        if frameName == "WeeklyRewardsFrame" then
            WeeklyRewardsFrame._easyvault_escape_registered = true
            return
        end
    end

    table.insert(UISpecialFrames, "WeeklyRewardsFrame")
    WeeklyRewardsFrame._easyvault_escape_registered = true
end

local function MakeWeeklyRewardsFrameMovable(db)
    if not WeeklyRewardsFrame then
        return
    end

    RegisterWeeklyRewardsFrameForEscape()

    if not WeeklyRewardsFrame._easyvault_positioned then
        ApplyPosition(WeeklyRewardsFrame, db.weeklyRewardsFrame, "UIParent", "CENTER")
        WeeklyRewardsFrame._easyvault_positioned = true
    end

    if WeeklyRewardsFrame._easyvault_movable then
        return
    end

    WeeklyRewardsFrame:SetClampedToScreen(true)
    WeeklyRewardsFrame:SetMovable(true)
    WeeklyRewardsFrame:EnableMouse(true)
    WeeklyRewardsFrame:RegisterForDrag("LeftButton")
    WeeklyRewardsFrame:SetScript("OnDragStart", WeeklyRewardsFrame.StartMoving)
    WeeklyRewardsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self, db.weeklyRewardsFrame, "UIParent")
    end)
    WeeklyRewardsFrame._easyvault_movable = true
end

local function ToggleWeeklyRewards(db)
    if LoadAddOn and not WeeklyRewardsFrame then
        LoadAddOn("Blizzard_WeeklyRewards")
    end

    if not WeeklyRewardsFrame then
        return
    end

    MakeWeeklyRewardsFrameMovable(db)

    if WeeklyRewardsFrame:IsShown() then
        WeeklyRewardsFrame:Hide()
    else
        WeeklyRewardsFrame:Show()
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
