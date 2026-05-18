local addon = CursorSpellIconAddon
local Icon            = LibStub("LibDBIcon-1.0")
local AceGUI          = LibStub("AceGUI-3.0")
local AceConfig       = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM             = LibStub("LibSharedMedia-3.0")

local function db() return addon.db.profile end

local previewWidgetRef = nil

do
    local function Constructor()
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(300, 130)
        frame:SetClipsChildren(true)

        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.05, 0.05, 0.05, 0.35)

        local cursor = CreateFrame("Frame", nil, frame)
        cursor:SetSize(32, 32)
        local cursorTex = cursor:CreateTexture(nil, "ARTWORK")
        cursorTex:SetAllPoints()
        pcall(function() cursorTex:SetTexture("Interface\\Cursor\\Cast") end)

        local iconF = CreateFrame("Frame", nil, frame)
        iconF:SetSize(36, 36)
        local iconTex = iconF:CreateTexture(nil, "ARTWORK")
        iconTex:SetAllPoints()
        pcall(function() iconTex:SetTexture("Interface\\Icons\\spell_holy_prayerofmendingtga") end)

        local bTop    = iconF:CreateTexture(nil, "OVERLAY"); bTop:Hide()
        local bBottom = iconF:CreateTexture(nil, "OVERLAY"); bBottom:Hide()
        local bLeft   = iconF:CreateTexture(nil, "OVERLAY"); bLeft:Hide()
        local bRight  = iconF:CreateTexture(nil, "OVERLAY"); bRight:Hide()

        local spellName = iconF:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        spellName:SetText("Prayer of Mending")
        spellName:Hide()

        local widget = {
            frame     = frame,
            type      = "CSI_Preview",
            height    = 130,
            cursor    = cursor,
            iconF     = iconF,
            iconTex   = iconTex,
            bTop      = bTop, bBottom = bBottom, bLeft = bLeft, bRight = bRight,
            spellName = spellName,
        }

        function widget:OnAcquire()
            previewWidgetRef = self
            self.frame:Show()
            self:UpdatePreview()
        end

        function widget:OnRelease()
            if previewWidgetRef == self then previewWidgetRef = nil end
            self.frame:Hide()
        end

        function widget:SetWidth(w)     self.frame:SetWidth(w) end
        function widget:SetHeight()     end
        function widget:SetLabel()      end
        function widget:SetText()       end
        function widget:DisableButton() end

        function widget:UpdatePreview()
            local d = addon.db and addon.db.profile
            if not d then return end

            local size = d.iconSize or 36
            self.iconF:SetSize(size, size)
            local zc = (d.zoom or 0) / 100
            self.iconTex:SetTexCoord(zc, 1 - zc, zc, 1 - zc)

            local bs = d.borderSize or 2
            local showBorder = d.showBorder and true or false
            self.bTop:SetShown(showBorder)
            self.bBottom:SetShown(showBorder)
            self.bLeft:SetShown(showBorder)
            self.bRight:SetShown(showBorder)
            if showBorder then
                self.bTop:ClearAllPoints()
                self.bTop:SetPoint("TOPLEFT",  self.iconF, "TOPLEFT",  0, 0)
                self.bTop:SetPoint("TOPRIGHT", self.iconF, "TOPRIGHT", 0, 0)
                self.bTop:SetHeight(bs)

                self.bBottom:ClearAllPoints()
                self.bBottom:SetPoint("BOTTOMLEFT",  self.iconF, "BOTTOMLEFT",  0, 0)
                self.bBottom:SetPoint("BOTTOMRIGHT", self.iconF, "BOTTOMRIGHT", 0, 0)
                self.bBottom:SetHeight(bs)

                self.bLeft:ClearAllPoints()
                self.bLeft:SetPoint("TOPLEFT",    self.iconF, "TOPLEFT",    0,  -bs)
                self.bLeft:SetPoint("BOTTOMLEFT", self.iconF, "BOTTOMLEFT", 0,   bs)
                self.bLeft:SetWidth(bs)

                self.bRight:ClearAllPoints()
                self.bRight:SetPoint("TOPRIGHT",    self.iconF, "TOPRIGHT",    0, -bs)
                self.bRight:SetPoint("BOTTOMRIGHT", self.iconF, "BOTTOMRIGHT", 0,  bs)
                self.bRight:SetWidth(bs)
            end

            local bc = d.borderColor or {}
            local bcR, bcG, bcB = bc.r or 1, bc.g or 0.82, bc.b or 0
            for _, t in ipairs({ self.bTop, self.bBottom, self.bLeft, self.bRight }) do
                t:SetColorTexture(bcR, bcG, bcB, 1)
            end

            local showName = d.showSpellName and true or false
            self.spellName:SetShown(showName)
            if showName then
                pcall(self.spellName.SetFont, self.spellName,
                      d.font or "Fonts\\FRIZQT__.TTF", d.textSize or 12, "")
                local tc = d.textColor or {}
                self.spellName:SetTextColor(tc.r or 1, tc.g or 1, tc.b or 1)
                self.spellName:ClearAllPoints()
                local pos = d.textPosition or "above"
                if pos == "below" then
                    self.spellName:SetPoint("TOP",    self.iconF, "BOTTOM",  0, -2)
                elseif pos == "left" then
                    self.spellName:SetPoint("RIGHT",  self.iconF, "LEFT",   -4,  0)
                elseif pos == "right" then
                    self.spellName:SetPoint("LEFT",   self.iconF, "RIGHT",   4,  0)
                else
                    self.spellName:SetPoint("BOTTOM", self.iconF, "TOP",     0,  2)
                end
            end

            local xOff = d.xOffset or 24
            local yOff = d.yOffset or 24
            self.cursor:ClearAllPoints()
            self.cursor:SetPoint("TOPLEFT", self.frame, "CENTER", -xOff / 2, -yOff / 2)
            self.iconF:ClearAllPoints()
            self.iconF:SetPoint("CENTER", self.cursor, "TOPLEFT", xOff, yOff)
        end

        return AceGUI:RegisterAsWidget(widget)
    end

    AceGUI:RegisterWidgetType("CSI_Preview", Constructor, 1)
end

local function RefreshPreview()
    if previewWidgetRef then previewWidgetRef:UpdatePreview() end
end

addon.RefreshPreview = RefreshPreview

local function refresh()
    if addon.RefreshIndicatorSettings then addon.RefreshIndicatorSettings() end
    if addon.RefreshPreview then addon.RefreshPreview() end
end

local options = {
    type = "group",
    name = "Cursor Spell Icons",
    args = {

        preview = {
            type          = "input",
            name          = "",
            order         = 5,
            width         = "full",
            dialogControl = "CSI_Preview",
            get           = function() return "" end,
            set           = function() end,
        },

        minimapHeader = { type = "header", name = "Minimap", order = 10 },
        minimap = {
            type  = "toggle",
            name  = "Minimap Icon",
            desc  = "Show or hide the minimap button",
            order = 11,
            get   = function() return not db().minimap.hide end,
            set   = function(_, v)
                db().minimap.hide = not v
                if db().minimap.hide then Icon:Hide("Cursor Spell Icons")
                else Icon:Show("Cursor Spell Icons") end
            end,
        },
        compartment = {
            type   = "toggle",
            name   = "Addon Button Compartment",
            desc   = "Show the button in Blizzard's Addon Button menu",
            order  = 12,
            hidden = function() return not Icon:IsButtonCompartmentAvailable() end,
            get    = function() return Icon:IsButtonInCompartment("Cursor Spell Icons") end,
            set    = function(_, v)
                if v then Icon:AddButtonToCompartment("Cursor Spell Icons")
                else Icon:RemoveButtonFromCompartment("Cursor Spell Icons") end
            end,
        },

        positionHeader = { type = "header", name = "Position", order = 20 },
        xOffset = {
            type  = "range",
            name  = "X Offset",
            desc  = "Horizontal offset of the icon from the cursor",
            order = 21,
            min = -100, max = 100, step = 1,
            get   = function() return db().xOffset end,
            set   = function(_, v) db().xOffset = v; refresh() end,
        },
        yOffset = {
            type  = "range",
            name  = "Y Offset",
            desc  = "Vertical offset of the icon from the cursor",
            order = 22,
            min = -100, max = 100, step = 1,
            get   = function() return db().yOffset end,
            set   = function(_, v) db().yOffset = v; refresh() end,
        },

        appearanceHeader = { type = "header", name = "Appearance", order = 30 },
        iconSize = {
            type  = "range",
            name  = "Icon Size",
            desc  = "Size of the spell icon in pixels",
            order = 31,
            min = 16, max = 128, step = 1,
            get   = function() return db().iconSize end,
            set   = function(_, v) db().iconSize = v; refresh() end,
        },
        zoom = {
            type  = "range",
            name  = "Icon Zoom",
            desc  = "Crop the outer edges of the spell icon (removes built-in border art)",
            order = 32,
            min = 0, max = 40, step = 1,
            get   = function() return db().zoom end,
            set   = function(_, v) db().zoom = v; refresh() end,
        },

        spellNameSpacer = { type = "description", name = " ", order = 39, width = "full" },

        showSpellName = {
            type  = "toggle",
            name  = "Show Spell Name",
            desc  = "Display the spell name next to the icon",
            order = 40,
            get   = function() return db().showSpellName end,
            set   = function(_, v) db().showSpellName = v; refresh() end,
        },
        textPosition = {
            type     = "select",
            name     = "Text Location",
            desc     = "Where the spell name appears relative to the icon",
            order    = 41,
            disabled = function() return not db().showSpellName end,
            values   = { above = "Above", below = "Below", left = "Left", right = "Right" },
            get      = function() return db().textPosition end,
            set      = function(_, v) db().textPosition = v; refresh() end,
        },
        textSize = {
            type     = "range",
            name     = "Text Size",
            desc     = "Font size of the spell name",
            order    = 42,
            disabled = function() return not db().showSpellName end,
            min = 6, max = 32, step = 1,
            get      = function() return db().textSize end,
            set      = function(_, v) db().textSize = v; refresh() end,
        },
        textColor = {
            type     = "color",
            name     = "Spell Name Color",
            desc     = "Color of the spell name text",
            order    = 43,
            disabled = function() return not db().showSpellName end,
            hasAlpha = false,
            get      = function()
                local c = db().textColor
                return c.r, c.g, c.b
            end,
            set      = function(_, r, g, b)
                local c = db().textColor
                c.r, c.g, c.b = r, g, b
                refresh()
            end,
        },
        font = {
            type          = "select",
            name          = "Spell Name Font",
            desc          = "Font used for the spell name text",
            order         = 44,
            disabled      = function() return not db().showSpellName end,
            values        = function() return LSM:HashTable("font") end,
            dialogControl = "LSM30_Font",
            get           = function() return db().fontName end,
            set           = function(_, v)
                db().fontName = v
                db().font = LSM:Fetch("font", v)
                refresh()
            end,
        },

        borderSpacer = { type = "description", name = " ", order = 49, width = "full" },

        showBorder = {
            type  = "toggle",
            name  = "Show Border",
            desc  = "Draw a border around the icon",
            order = 50,
            get   = function() return db().showBorder end,
            set   = function(_, v) db().showBorder = v; refresh() end,
        },
        borderColor = {
            type     = "color",
            name     = "Border Color",
            desc     = "Color of the icon border",
            order    = 51,
            disabled = function() return not db().showBorder end,
            hasAlpha = false,
            get      = function()
                local c = db().borderColor
                return c.r, c.g, c.b
            end,
            set      = function(_, r, g, b)
                local c = db().borderColor
                c.r, c.g, c.b = r, g, b
                refresh()
            end,
        },
        borderSize = {
            type     = "range",
            name     = "Border Size",
            desc     = "Thickness of the icon border in pixels",
            order    = 52,
            disabled = function() return not db().showBorder end,
            min = 1, max = 10, step = 1,
            get      = function() return db().borderSize end,
            set      = function(_, v) db().borderSize = v; refresh() end,
        },
    },
}

AceConfig:RegisterOptionsTable("CursorSpellIcons", options)
local frame = AceConfigDialog:AddToBlizOptions("CursorSpellIcons", "Cursor Spell Icons")
addon.settingsCategory = frame
