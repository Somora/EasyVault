-- Define a function to create the minimap button
local function CreateMinimapButton()
    -- Create a new button frame attached to the Minimap
    local btn = CreateFrame("Button", "WeeklyRewardsMinimapBtn", Minimap)
    btn:SetSize(32, 32)  -- Set the size of the button
    btn:SetFrameStrata("MEDIUM")  -- Ensure the button appears above other UI elements
    btn:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_01")  -- Set the icon texture
    btn:SetPoint("TOPLEFT")  -- Position the button on the top-left corner of the Minimap (adjust as needed)

    -- Enable dragging of the minimap button
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", btn.StartMoving)
    btn:SetScript("OnDragStop", btn.StopMovingOrSizing)

    -- Define the functionality when the button is clicked
    btn:SetScript("OnClick", function()
        -- Load the Weekly Rewards addon using C_AddOns.LoadAddOn
        C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")

        -- Toggle the visibility of the Weekly Rewards frame
        if WeeklyRewardsFrame:IsShown() then
            WeeklyRewardsFrame:Hide()
        else
            WeeklyRewardsFrame:Show()
        end

        -- Make the Weekly Rewards frame movable and draggable
        WeeklyRewardsFrame:SetMovable(true)
        WeeklyRewardsFrame:EnableMouse(true)
        WeeklyRewardsFrame:RegisterForDrag("LeftButton")
        WeeklyRewardsFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        WeeklyRewardsFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            -- Optionally, save the frame's position to retain it between sessions
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            self:ClearAllPoints()
            self:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        end)

        -- Ensure the frame is registered to be closed with the ESC key
        -- Commented out to remove ESC key functionality
        -- table.insert(UISpecialFrames, "WeeklyRewardsFrame")
    end)

    -- Define the behavior when the mouse leaves the button
    btn:SetScript("OnLeave", function()
        -- Hide the tooltip
        GameTooltip:Hide()
    end)
end

-- Create the minimap button
CreateMinimapButton()
