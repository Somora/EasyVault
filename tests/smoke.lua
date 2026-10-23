-- Run from the repository root with Lua 5.1: lua tests/smoke.lua
-- These mocks verify addon logic, not WoW's secure execution or taint engine.
unpack = unpack or table.unpack
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
securecallfunction = function(fn, ...) return fn(...) end

local frames = {}
local combat, failLoad = false, false
local loads, panelShows, panelHides = 0, 0, 0
local methods = {}
local function noop() end
for _, name in ipairs({"SetSize", "SetFrameStrata", "SetFixedFrameStrata", "SetFrameLevel",
    "SetFixedFrameLevel", "RegisterForClicks", "RegisterForDrag", "SetHighlightTexture",
    "SetTexture", "SetVertexColor", "SetTexCoord", "SetOrder", "SetDuration", "SetFromAlpha",
    "SetToAlpha", "SetStartDelay", "SetToFinalAlpha", "SetClampedToScreen", "SetMovable",
    "SetOwner", "AddLine", "SetAlpha", "LockHighlight", "UnlockHighlight", "Play", "Stop"}) do
    methods[name] = noop
end
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:GetScript(name) return self.scripts[name] end
function methods:HookScript(name, fn)
    self.hooks[name] = self.hooks[name] or {}
    table.insert(self.hooks[name], fn)
end
function methods:RunScript(name, ...)
    if self.scripts[name] then self.scripts[name](self, ...) end
    for _, fn in ipairs(self.hooks[name] or {}) do fn(self, ...) end
end
function methods:RegisterEvent(name) self.events[name] = true end
function methods:GetParent() return self.parent end
function methods:GetVertexColor() return 1, 1, 1, 1 end
function methods:GetWidth() return 140 end
function methods:GetHeight() return 140 end
function methods:GetEffectiveScale() return 1 end
function methods:GetCenter() return 70, 70 end
function methods:IsShown() return self.shown end
function methods:Show() self.shown = true; self:RunScript("OnShow") end
function methods:Hide() self.shown = false; self:RunScript("OnHide") end
function methods:ClearAllPoints() self.point = nil end
function methods:SetPoint(...) self.point = {...} end
function methods:GetPoint() return unpack(self.point) end
function methods:StartMoving() self.moving = true end
function methods:StopMovingOrSizing() self.moving = false end
function CreateFrame(kind, name, parent)
    local frame = setmetatable({scripts = {}, hooks = {}, events = {}, parent = parent, shown = false}, {__index = methods})
    frames[#frames + 1] = frame
    if name then _G[name] = frame end
    return frame
end
function methods:CreateTexture() return CreateFrame("Texture", nil, self) end
function methods:CreateAnimationGroup() return CreateFrame("AnimationGroup", nil, self) end
function methods:CreateAnimation() return CreateFrame("Animation", nil, self) end
UIParent = CreateFrame("Frame")
Minimap = CreateFrame("Frame", nil, UIParent)
UIErrorsFrame = {AddMessage = function(self, text) self.message = text end}
UISpecialFrames = {"ExistingFrame"}
function GetCursorPosition() return 100, 100 end
function InCombatLockdown() return combat end
local blizzardShows, blizzardDrags = 0, 0
C_AddOns = {LoadAddOn = function(name)
    assert(name == "Blizzard_WeeklyRewards")
    loads = loads + 1
    if failLoad then return false, "DISABLED" end
    WeeklyRewardsFrame = CreateFrame("Frame", "WeeklyRewardsFrame", UIParent)
    WeeklyRewardsFrame:SetScript("OnShow", function() blizzardShows = blizzardShows + 1 end)
    WeeklyRewardsFrame:SetScript("OnDragStart", function() blizzardDrags = blizzardDrags + 1 end)
    return true
end}
function ShowUIPanel(frame)
    assert(not combat, "panel shown in combat")
    panelShows = panelShows + 1
    frame:SetPoint("CENTER", UIParent, "CENTER", 123, 456)
    frame:Show()
end
function HideUIPanel(frame)
    assert(not combat, "panel hidden in combat")
    panelHides = panelHides + 1
    frame:Hide()
end

local libraryFiles = {
    "Libs/LibStub/LibStub.lua",
    "Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua",
    "Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua",
    "Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua",
}
for _, path in ipairs(libraryFiles) do assert(loadfile(path))() end
local ldb, icons = LibStub("LibDataBroker-1.1"), LibStub("LibDBIcon-1.0")
local created = 0
ldb.RegisterCallback("test", "LibDataBroker_DataObjectCreated", function(_, name)
    if name == "EasyVault" then created = created + 1 end
end)
EasyVaultDB = {minimap = {angle = 90}, weeklyRewardsFrame = {x = 10, y = 20}}
assert(loadfile("EasyVault.lua"))("EasyVault")
for _, frame in ipairs(frames) do
    if frame.events.PLAYER_LOGIN then frame:RunScript("OnEvent", "PLAYER_LOGIN") end
end
assert(created == 1, "LDB creation callback missing")
assert(EasyVaultDB.minimap.minimapPos == 90, "old minimap position not migrated")
local button = assert(icons:GetMinimapButton("EasyVault"))
local launcher = assert(ldb:GetDataObjectByName("EasyVault"))
assert(ldb:GetNameByDataObject(launcher) == "EasyVault")
launcher.icon = 42
assert(button.icon ~= nil, "minimap icon missing")
local iconUpdates = 0
button.icon.SetTexture = function(_, value) assert(value == 43); iconUpdates = iconUpdates + 1 end
launcher.icon = 43
assert(iconUpdates == 1, "upstream LDB icon callback missing")
local click = function(mouseButton) button:RunScript("OnClick", mouseButton or "LeftButton") end
click("RightButton")
assert(loads == 0)
combat = true
click()
assert(loads == 0 and panelShows == 0, "combat must stop before loading the Blizzard UI")
combat = false
failLoad = true
click()
assert(loads == 1 and panelShows == 0, "load failure must not open a panel")
failLoad = false
click()
assert(loads == 2 and panelShows == 1 and blizzardShows == 1)
assert(WeeklyRewardsFrame.point[4] == 10 and WeeklyRewardsFrame.point[5] == 20)
assert(#UISpecialFrames == 1, "UIPanels must not be added to UISpecialFrames")
assert(WeeklyRewardsFrame._easyvault_movable == nil, "addon state leaked onto Blizzard frame")
WeeklyRewardsFrame:RunScript("OnDragStart")
assert(blizzardDrags == 1 and WeeklyRewardsFrame.moving, "Blizzard drag script was replaced")
WeeklyRewardsFrame:SetPoint("CENTER", UIParent, "CENTER", 30, 40)
WeeklyRewardsFrame:RunScript("OnDragStop")
assert(not WeeklyRewardsFrame.moving and EasyVaultDB.weeklyRewardsFrame.x == 30)
combat = true
WeeklyRewardsFrame:RunScript("OnDragStart")
assert(not WeeklyRewardsFrame.moving, "dragging started in combat")
click()
assert(panelHides == 0 and WeeklyRewardsFrame:IsShown())
combat = false
click()
assert(panelHides == 1 and not WeeklyRewardsFrame:IsShown())
click()
assert(panelShows == 2 and loads == 2 and blizzardShows == 2)
assert(WeeklyRewardsFrame.point[4] == 30 and WeeklyRewardsFrame.point[5] == 40, "position lost on reopening")
assert(#WeeklyRewardsFrame.hooks.OnShow == 1, "duplicate hooks")
for _, path in ipairs(libraryFiles) do assert(loadfile(path))() end
assert(ldb == LibStub("LibDataBroker-1.1") and icons == LibStub("LibDBIcon-1.0"), "shared libraries replaced on reload")
print("PASS: libraries, callbacks, load failures, combat guards, preserved scripts, position persistence, repeated loads")
