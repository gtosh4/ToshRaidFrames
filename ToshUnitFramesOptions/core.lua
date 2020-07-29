local ToshUnitFrames = ToshUnitFrames

local defaultOptions = {}

function ToshUnitFrames:InitializeOptions()
	self.db = ToshUnitFrames.db:RegisterNamespace("ToshUnitFramesOptions",  defaultOptions )
	self:MakeOptions()
	self.InitializeOptions = nil
end

local frame
local optionsAfterCombat

function ToshUnitFrames:OptionsAfterCombat()
    self:Print("opening options after combat")
    optionsAfterCombat = true
end

function ToshUnitFrames:OnChatCommand(input)
    if frame and frame:IsVisible() then
        self:HideOptions()
    elseif InCombatLockdown() then
        ToshUnitFrames:OptionsAfterCombat()
    else
        self:ShowOptions()
    end
end

function ToshUnitFrames:HideOptions()
    if frame then
        frame:Hide()
    end
end

function ToshUnitFrames:ShowOptions()
    if not(frame) then
        self:MakeOptions()
    end
    frame:Show()
end

function ToshUnitFrames:MakeOptions()
    local AceGUI = LibStub("AceGUI-3.0")

    frame = AceGUI:Create("ToshUnitFramesOptions")
    frame:Hide()
    frame:SetTitle("Tosh UF " .. ToshUnitFrames.versionString)

    frame.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame.frame:SetScript("OnEvent", function(self, event)
        if (event == "PLAYER_REGEN_DISABLED") then
            ToshUnitFrames:OptionsAfterCombat()
            ToshUnitFrames.HideOptions()
        elseif (event == "PLAYER_REGEN_ENABLED") then
            if optionsAfterCombat then
                optionsAfterCombat = false
                ToshUnitFrames:ShowOptions()
            end
        end
    end)
end
