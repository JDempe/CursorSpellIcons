local addon = CursorSpellIconAddon
local eventFrame = CreateFrame("Frame")

local iconFrame = CreateFrame("Frame", nil, UIParent)
iconFrame:SetFrameStrata("TOOLTIP")
iconFrame:Hide()

local texture = iconFrame:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints()

local borderTop    = iconFrame:CreateTexture(nil, "OVERLAY")
local borderBottom = iconFrame:CreateTexture(nil, "OVERLAY")
local borderLeft   = iconFrame:CreateTexture(nil, "OVERLAY")
local borderRight  = iconFrame:CreateTexture(nil, "OVERLAY")
for _, t in ipairs({ borderTop, borderBottom, borderLeft, borderRight }) do
    t:Hide()
end

local spellNameText = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spellNameText:Hide()

local activeReticleSpell     = nil
local activeInteractiveSpell = nil
local lastActivatedSpellID   = nil

local function ApplySettings()
    local db = addon.db and addon.db.profile
    if not db then return end

    local size = db.iconSize or 36
    iconFrame:SetSize(size, size)

    local c = (db.zoom or 0) / 100
    texture:SetTexCoord(c, 1 - c, c, 1 - c)

    local bs = db.borderSize or 2
    local showBorder = db.showBorder and true or false
    borderTop:SetShown(showBorder)
    borderBottom:SetShown(showBorder)
    borderLeft:SetShown(showBorder)
    borderRight:SetShown(showBorder)
    if showBorder then
        borderTop:ClearAllPoints()
        borderTop:SetPoint("TOPLEFT",  iconFrame, "TOPLEFT",  0,   0)
        borderTop:SetPoint("TOPRIGHT", iconFrame, "TOPRIGHT", 0,   0)
        borderTop:SetHeight(bs)

        borderBottom:ClearAllPoints()
        borderBottom:SetPoint("BOTTOMLEFT",  iconFrame, "BOTTOMLEFT",  0, 0)
        borderBottom:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 0, 0)
        borderBottom:SetHeight(bs)

        borderLeft:ClearAllPoints()
        borderLeft:SetPoint("TOPLEFT",    iconFrame, "TOPLEFT",    0,   -bs)
        borderLeft:SetPoint("BOTTOMLEFT", iconFrame, "BOTTOMLEFT", 0,    bs)
        borderLeft:SetWidth(bs)

        borderRight:ClearAllPoints()
        borderRight:SetPoint("TOPRIGHT",    iconFrame, "TOPRIGHT",    0,  -bs)
        borderRight:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 0,   bs)
        borderRight:SetWidth(bs)
    end

    local bc = db.borderColor or {}
    local bcR, bcG, bcB = bc.r or 1, bc.g or 0.82, bc.b or 0
    for _, t in ipairs({ borderTop, borderBottom, borderLeft, borderRight }) do
        t:SetColorTexture(bcR, bcG, bcB, 1)
    end

    pcall(spellNameText.SetFont, spellNameText, db.font or "Fonts\\FRIZQT__.TTF", db.textSize or 12, "")
    local tc = db.textColor or {}
    spellNameText:SetTextColor(tc.r or 1, tc.g or 1, tc.b or 1)
    spellNameText:ClearAllPoints()
    local pos = db.textPosition or "above"
    if pos == "below" then
        spellNameText:SetPoint("TOP",    iconFrame, "BOTTOM",  0, -2)
    elseif pos == "left" then
        spellNameText:SetPoint("RIGHT",  iconFrame, "LEFT",   -4,  0)
    elseif pos == "right" then
        spellNameText:SetPoint("LEFT",   iconFrame, "RIGHT",   4,  0)
    else
        spellNameText:SetPoint("BOTTOM", iconFrame, "TOP",     0,  2)
    end

    local hasSpell = activeReticleSpell or activeInteractiveSpell
    spellNameText:SetShown(db.showSpellName and hasSpell ~= nil)
end

addon.RefreshIndicatorSettings = ApplySettings

local function ShowIcon(spellID)
    local textureID = C_Spell.GetSpellTexture(spellID)
    if not textureID then return false end
    texture:SetTexture(textureID)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then spellNameText:SetText(spellInfo.name) end
    ApplySettings()
    iconFrame:Show()
    return true
end

local function HideIcon()
    iconFrame:Hide()
end

local function TryShowInteractiveIcon()
    if not SpellIsTargeting() then return end
    if activeReticleSpell then return end
    local spellID = lastActivatedSpellID
    if not spellID then return end
    if activeInteractiveSpell == spellID then return end
    activeInteractiveSpell = spellID
    ShowIcon(spellID)
end

local function UpdateCursorPosition()
    if activeInteractiveSpell and not SpellIsTargeting() then
        activeInteractiveSpell = nil
        if not activeReticleSpell then
            HideIcon()
            return
        end
    end

    local db = addon.db and addon.db.profile
    local xOff = (db and db.xOffset) or 24
    local yOff = (db and db.yOffset) or 24
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()

    iconFrame:SetPoint(
        "CENTER",
        UIParent,
        "BOTTOMLEFT",
        (x / scale) + xOff,
        (y / scale) + yOff
    )
end

iconFrame:SetScript("OnShow", function(self)
    self:SetScript("OnUpdate", UpdateCursorPosition)
end)

iconFrame:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
end)

hooksecurefunc("UseAction", function(slot)
    local actionType, id = GetActionInfo(slot)
    if actionType == "spell" then
        lastActivatedSpellID = id
        TryShowInteractiveIcon()
    end
end)

eventFrame:RegisterEvent("UNIT_SPELLCAST_RETICLE_TARGET")
eventFrame:RegisterEvent("UNIT_SPELLCAST_RETICLE_CLEAR")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "UNIT_SPELLCAST_RETICLE_TARGET" then
        local unit, _, spellID = ...
        if unit ~= "player" or not spellID then return end
        activeReticleSpell = spellID
        activeInteractiveSpell = nil
        ShowIcon(spellID)

    elseif event == "UNIT_SPELLCAST_RETICLE_CLEAR" then
        activeReticleSpell = nil
        activeInteractiveSpell = nil
        HideIcon()

    elseif event == "UNIT_SPELLCAST_SENT" then
        local unit, _, _, spellID = ...
        if unit ~= "player" then return end
        if spellID and spellID ~= 0 then
            lastActivatedSpellID = spellID
        end
        TryShowInteractiveIcon()

    elseif event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then

        local unit, _, spellID = ...
        if unit ~= "player" then return end

        if spellID == activeReticleSpell then
            activeReticleSpell = nil
            if not activeInteractiveSpell then HideIcon() end
        end

        if spellID == activeInteractiveSpell then
            activeInteractiveSpell = nil
            if not activeReticleSpell then HideIcon() end
        end
    end
end)
