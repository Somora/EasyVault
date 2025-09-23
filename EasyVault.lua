-- Cache global functions for performance
local CreateFrame = CreateFrame
local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn

local function MakeWeeklyRewardsFrameMovable()
    if not WeeklyRewardsFrame._easyvault_movable then
        WeeklyRewardsFrame:SetMovable(true)
        WeeklyRewardsFrame:EnableMouse(true)
        WeeklyRewardsFrame:RegisterForDrag("LeftButton")
        WeeklyRewardsFrame:SetScript("OnDragStart", WeeklyRewardsFrame.StartMoving)
        WeeklyRewardsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            -- Optionally, save the frame's position here
        end)
        WeeklyRewardsFrame._easyvault_movable = true
    end
end

local function CreateMinimapButton()
    local btn = CreateFrame("Button", "WeeklyRewardsMinimapBtn", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_01")
    btn:SetPoint("TOPLEFT")

    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", btn.StartMoving)
    btn:SetScript("OnDragStop", btn.StopMovingOrSizing)

    btn:SetScript("OnClick", function()
        if LoadAddOn then LoadAddOn("Blizzard_WeeklyRewards") end
        if WeeklyRewardsFrame then
            if WeeklyRewardsFrame:IsShown() then
                WeeklyRewardsFrame:Hide()
            else
                WeeklyRewardsFrame:Show()
                MakeWeeklyRewardsFrameMovable()
            end
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Weekly Rewards", 1, 1, 1)
        GameTooltip:AddLine("Click to open the Weekly Rewards window.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

CreateMinimapButton()