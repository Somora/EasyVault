local MAJOR, MINOR = "LibDBIcon-1.0", 5
local LibStub = _G.LibStub
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then
    return
end

local Minimap = _G.Minimap
local UIParent = _G.UIParent
local GameTooltip = _G.GameTooltip
local GetCursorPosition = _G.GetCursorPosition
local math = math
local unpack = unpack or table.unpack

lib.objects = lib.objects or {}
lib.notCreated = lib.notCreated or {}

local DEFAULT_ANGLE = 225
local BUTTON_RADIUS_OFFSET = 5
local minimapShapes = {
    ROUND = { true, true, true, true },
    SQUARE = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function getMinimapShape()
    if type(_G.GetMinimapShape) == "function" then
        return _G.GetMinimapShape()
    end

    return "ROUND"
end

local function normalizeAngle(angle)
    angle = tonumber(angle) or DEFAULT_ANGLE
    angle = angle % 360

    if angle < 0 then
        angle = angle + 360
    end

    return angle
end

local function getRadius()
    return ((Minimap and Minimap:GetWidth()) or 140) / 2 + BUTTON_RADIUS_OFFSET
end

local function applyCircularMask(texture)
    if texture and texture.SetMask then
        texture:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    end
end

local function setPressed(button, pressed)
    button.icon:ClearAllPoints()
    button.background:ClearAllPoints()
    button.border:ClearAllPoints()

    if pressed then
        button.icon:SetPoint("CENTER", 1, -1)
        button.background:SetPoint("CENTER", 1, -1)
        button.border:SetPoint("TOPLEFT", 1, -1)
    else
        button.icon:SetPoint("CENTER", 0, 0)
        button.background:SetPoint("CENTER", 0, 0)
        button.border:SetPoint("TOPLEFT", 0, 0)
    end
end

local function calculateAngleFromCursor()
    local scale = (UIParent and UIParent:GetEffectiveScale()) or 1
    local cursorX, cursorY = GetCursorPosition()
    local centerX, centerY = Minimap:GetCenter()

    if not cursorX or not cursorY or not centerX or not centerY then
        return DEFAULT_ANGLE
    end

    local x = (cursorX / scale) - centerX
    local y = (cursorY / scale) - centerY
    local radians

    if math.atan2 then
        radians = math.atan2(y, x)
    else
        radians = math.atan(y / (x == 0 and 0.00001 or x))
        if x < 0 then
            radians = radians + math.pi
        elseif y < 0 then
            radians = radians + (2 * math.pi)
        end
    end

    return normalizeAngle(math.deg(radians))
end

local function placeButton(button, angle)
    angle = normalizeAngle(angle)

    local radians = math.rad(angle)
    local radius = getRadius()
    local x = math.cos(radians) * radius
    local y = math.sin(radians) * radius
    local shape = minimapShapes[getMinimapShape()]

    if shape and not shape[1] and x >= 0 and y <= 0 then
        x = math.min(x, radius * 0.70710678)
        y = math.max(y, -radius * 0.70710678)
    elseif shape and not shape[2] and x >= 0 and y >= 0 then
        x = math.min(x, radius * 0.70710678)
        y = math.min(y, radius * 0.70710678)
    elseif shape and not shape[3] and x <= 0 and y <= 0 then
        x = math.max(x, -radius * 0.70710678)
        y = math.max(y, -radius * 0.70710678)
    elseif shape and not shape[4] and x <= 0 and y >= 0 then
        x = math.max(x, -radius * 0.70710678)
        y = math.min(y, radius * 0.70710678)
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    button.db.minimapPos = angle
end

local function updatePosition(button)
    placeButton(button, calculateAngleFromCursor())
end

local function refreshButtonVisuals(button, dataObject)
    if dataObject.icon then
        button.icon:SetTexture(dataObject.icon)
    end

    if dataObject.iconCoords then
        button.icon:SetTexCoord(unpack(dataObject.iconCoords))
    else
        button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    end

    button.tooltipText = dataObject.label or dataObject.text or button.name
end

local function showTooltip(button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")

    if type(button.dataObject.OnTooltipShow) == "function" then
        button.dataObject.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
        return
    end

    GameTooltip:SetText(button.tooltipText or button.name, 1, 1, 1)

    if button.dataObject.type == "launcher" then
        GameTooltip:AddLine("Left-click to open or close Weekly Rewards.", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag to move this button around the minimap.", 0.8, 0.8, 0.8)
    end

    GameTooltip:Show()
end

local function createButton(name, dataObject, db)
    local button = CreateFrame("Button", "LibDBIcon10_" .. name, Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:SetClampedToScreen(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button.name = name
    button.dataObject = dataObject
    button.db = db

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("CENTER", 0, 0)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    background:SetVertexColor(0, 0, 0, 0.9)
    applyCircularMask(background)
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER", 0, 0)
    applyCircularMask(icon)
    button.icon = icon

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetAllPoints(icon)
    overlay:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    overlay:SetBlendMode("ADD")
    overlay:SetAlpha(0.2)
    overlay:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    applyCircularMask(overlay)
    overlay:Hide()
    button.overlay = overlay

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border = border

    button:SetScript("OnEnter", function(self)
        self.overlay:Show()
        self.border:SetVertexColor(1, 0.92, 0.72, 1)
        showTooltip(self)
    end)

    button:SetScript("OnLeave", function(self)
        self.overlay:Hide()
        self.border:SetVertexColor(1, 1, 1, 1)
        setPressed(self, false)
        GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            setPressed(self, true)
        end
    end)

    button:SetScript("OnMouseUp", function(self)
        setPressed(self, false)
    end)

    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", updatePosition)
    end)

    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        updatePosition(self)
    end)

    button:SetScript("OnClick", function(self, buttonName)
        local handler = self.dataObject.OnClick
        if handler then
            handler(self, buttonName)
        end
    end)

    refreshButtonVisuals(button, dataObject)
    placeButton(button, db.minimapPos or DEFAULT_ANGLE)

    return button
end

function lib:Register(name, dataObject, db)
    assert(type(name) == "string", "Name must be a string")
    assert(type(dataObject) == "table", "Data object must be a table")
    assert(type(db) == "table", "DB must be a table")

    db.minimapPos = normalizeAngle(db.minimapPos or db.angle or DEFAULT_ANGLE)
    db.hide = db.hide or false

    local button = self.objects[name]
    if not button then
        button = createButton(name, dataObject, db)
        self.objects[name] = button
    else
        button.db = db
        button.dataObject = dataObject
        refreshButtonVisuals(button, dataObject)
        placeButton(button, db.minimapPos)
    end

    if db.hide then
        button:Hide()
    else
        button:Show()
    end

    return button
end

function lib:Refresh(name, db)
    local button = self.objects[name]
    if not button then
        return
    end

    button.db = db or button.db
    refreshButtonVisuals(button, button.dataObject)

    if button.db.hide then
        button:Hide()
    else
        button:Show()
        placeButton(button, button.db.minimapPos)
    end
end

function lib:Show(name)
    local button = self.objects[name]
    if not button then
        return
    end

    button.db.hide = false
    button:Show()
    placeButton(button, button.db.minimapPos)
end

function lib:Hide(name)
    local button = self.objects[name]
    if not button then
        return
    end

    button.db.hide = true
    button:Hide()
end

function lib:GetMinimapButton(name)
    return self.objects[name]
end