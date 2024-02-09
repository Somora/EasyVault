-- Define a function to create the minimap button
local function CreateMinimapButton()
    -- Create a new button frame attached to the Minimap
    local btn = CreateFrame("Button", "WeeklyRewardsMinimapBtn", Minimap)
    -- Set the size of the button
    btn:SetSize(32, 32)
    -- Set the frame strata to ensure the button appears above other UI elements
    btn:SetFrameStrata("MEDIUM")
    -- Set the icon texture of the button to a gold coin
    btn:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_01")
    -- Position the button on the top-left corner of the Minimap (adjust as needed)
    btn:SetPoint("TOPLEFT")

    -- Define the functionality when the button is clicked
    btn:SetScript("OnClick", function()
        -- Check if the Weekly Rewards addon is loaded and the frame is visible
        if IsAddOnLoaded("Blizzard_WeeklyRewards") and WeeklyRewardsFrame:IsShown() then
            -- Hide the frame if it is already shown
            WeeklyRewardsFrame:Hide()
        else
            -- Load the Weekly Rewards addon if not already loaded
            LoadAddOn("Blizzard_WeeklyRewards")
            -- Show the Weekly Rewards frame
            WeeklyRewardsFrame:Show()
        end
    end)

    -- Define the tooltip behavior when the mouse hovers over the button
    btn:SetScript("OnEnter", function(self)
        -- Set the tooltip's anchor to the left of the button
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        -- Add a line to the tooltip indicating the purpose of the button in yellow
        GameTooltip:AddLine("Weekly Rewards", 1, 1, 0) -- Yellow text
        -- Add another line providing instructions to the user
        GameTooltip:AddLine("Click to toggle the Weekly Rewards frame.", 0.8, 0.8, 0.8, 1) -- Light gray text
        -- Show the tooltip
        GameTooltip:Show()
    end)
    
    -- Define the behavior when the mouse leaves the button
    btn:SetScript("OnLeave", function()
        -- Hide the tooltip
        GameTooltip:Hide()
    end)

    -- Enable the button to be movable
    btn:SetMovable(true)
    -- Enable mouse interaction with the button
    btn:EnableMouse(true)
    -- Register the left mouse button for dragging the button
    btn:RegisterForDrag("LeftButton")
    -- Define behavior when dragging starts
    btn:SetScript("OnDragStart", btn.StartMoving)
    -- Define behavior when dragging stops
    btn:SetScript("OnDragStop", btn.StopMovingOrSizing)
end

-- Call the function to create the minimap button
CreateMinimapButton()
