ToshUnitFrames = LibStub("AceAddon-3.0"):NewAddon("ToshUnitFrames", "AceEvent-3.0", "AceConsole-3.0")
ToshUnitFrames.versionString = GetAddOnMetadata("ToshUnitFrames", "Version")

local insert = table.insert

local defaults = {
	profile = {
		regions = {},
	},
	global = {
		options = {
			width = 700,
			height = 500,
			pos = {from="CENTER", to="CENTER", x=0, y=0},
		},
	},
}

ToshUnitFrames.regions = {}
ToshUnitFrames.units = {}
ToshUnitFrames.frames = {}

function ToshUnitFrames:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ToshUnitFramesDB", defaults, true)
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.db, "ToshUnitFrames")
	if not self.db.profile.regions then
		self.db.profile.regions = {}
	end
	
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	self:RegisterChatCommand("toshuf", "OnChatCommand")
	self:RegisterChatCommand("tuf", "OnChatCommand")

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateUnitFrames")
	self:RegisterMessage("TUF_FRAMES_UPDATED", "UpdateUnitFrames")
end

function ToshUnitFrames:RefreshConfig()
    self:SendMessage("TUF_FRAMES_UPDATED")
end

function ToshUnitFrames:LoadToshUnitFramesOptions()
    local optionsAddon = "ToshUnitFramesOptions"
	if not IsAddOnLoaded(optionsAddon) then
		if InCombatLockdown() then
			self:Printf("%s cannot be loaded in combat.", optionsAddon)
			return
        end
        local success, reason = LoadAddOn(optionsAddon)
        if not success then
            self:Printf("Could not load %s: %s", optionsAddon, reason)
        end
	end
	if self.InitializeOptions then -- defined in ToshUnitFramesOptions
		self:LoadOptions()
		self.LoadToshUnitFramesOptions = function() return true end
		return true
	end
	self:Print("You need ToshRaidFramesOptions addon enabled to be able to configure ToshUnitFrames.")
end

function ToshUnitFrames:OnChatCommand(input)
	if self:LoadToshUnitFramesOptions() then
		self:OnChatCommand(input)
	end
end

function ToshUnitFrames:LoadOptions()
	self:InitializeOptions()
	self.LoadOptions = nil
end

function ToshUnitFrames:Debug(data, msg)
    if ViragDevTool_AddData then
        ViragDevTool_AddData(data, msg)
    end
end
