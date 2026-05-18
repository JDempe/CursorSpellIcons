CursorSpellIconAddon =
    LibStub("AceAddon-3.0"):NewAddon("CursorSpellIconAddon")

local defaults = {
    profile = {
        minimap      = { hide = true },
        xOffset      = 24,
        yOffset      = 24,
        iconSize     = 36,
        zoom         = 0,
        showSpellName = false,
        showBorder   = false,
        borderSize   = 2,
        borderColor  = { r = 1, g = 0.82, b = 0 },
        textColor    = { r = 1, g = 1,    b = 1 },
        fontName     = "Friz Quadrata TT",
        font         = "Fonts\\FRIZQT__.TTF",
        textSize     = 12,
        textPosition = "above",
    },
}

function CursorSpellIconAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CursorSpellIconDB", defaults, true)
end

local addon = CursorSpellIconAddon

local LDB  = LibStub("LibDataBroker-1.1")
local Icon = LibStub("LibDBIcon-1.0")

function addon:CreateLDB()
    if self.dataObject then return end

    self.dataObject = LDB:NewDataObject("Cursor Spell Icons", {
        type = "launcher",
        text = "Cursor Spell Icons",
        icon = "Interface\\Cursor\\Cast",

        OnClick = function(_, button)
            if button == "LeftButton" then
                addon:ToggleUI()
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Cursor Spell Icons")
            tooltip:AddLine("Left-click to open settings", 1, 1, 1)
        end,
    })
end

function addon:OnEnable()
    self:CreateLDB()

    if Icon and not Icon:IsRegistered("Cursor Spell Icons") then
        Icon:Register("Cursor Spell Icons", self.dataObject, self.db.profile.minimap)
    end
end

function CursorSpellIconAddon:ToggleUI()
    if self.settingsCategory then
        Settings.OpenToCategory(self.settingsCategory.name)
    end
end

SLASH_CSI1 = "/csi"
SlashCmdList["CSI"] = function() addon:ToggleUI() end
