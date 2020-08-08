local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

-- Adapted from Grid2Options
local GetAllProfiles, GetUnusedProfiles
do
	local profiles, values = {}, {}
	local function GetProfiles(showCurrent)
		wipe(profiles)
		wipe(values)
		ToshUnitFrames.db:GetProfiles(profiles)
		for _,k in pairs(profiles) do
			values[k] = k
		end
		if not showCurrent then
			values[ToshUnitFrames.db:GetCurrentProfile()] = nil
		end
		return values
	end
	GetAllProfiles    = function() return GetProfiles(true)  end
	GetUnusedProfiles = function() return GetProfiles(false) end
end

function ns:CreateProfilesWidget()
    local root = AceGUI:Create("SimpleGroup")
    root:SetFullWidth(true)

    local current = AceGUI:Create("SimpleGroup")
    current:SetFullWidth(true)
    current:SetLayout("Flow")
    root:AddChild(current)

    local allProfiles = GetAllProfiles()

    local profile = AceGUI:Create("Dropdown")
    profile:SetLabel("Current Profile")
    profile:SetList(allProfiles)
    profile:SetValue(ToshUnitFrames.db:GetCurrentProfile())
    profile:SetWidth(120)
    profile:SetCallback("OnValueChanged", function(w, msg, key)
        ToshUnitFrames.db:SetProfile(key)
    end)
    current:AddChild(profile)

    local reset = AceGUI:Create("Button")
    reset:SetText("Reset")
    reset:SetWidth(80)
    reset:SetCallback("OnClick", function()
        ns:Confirm(("Really reset %s?"):format(ToshUnitFrames.db:GetCurrentProfile()), function()
            ToshUnitFrames.db:ResetProfile()
        end)
    end)
    current:AddChild(reset)

    local spec = AceGUI:Create("SimpleGroup")
    spec:SetFullWidth(true)
    root:AddChild(spec)

    function loadSpecConfig()
        spec:ReleaseChildren()

        local perSpec = AceGUI:Create("CheckBox")
        perSpec:SetLabel("Profile per Specialization")
        perSpec:SetValue(ToshUnitFrames.db:IsDualSpecEnabled())
        perSpec:SetCallback("OnValueChanged", function(w, msg, v)
            ToshUnitFrames.db:SetDualSpecEnabled(v)
            loadSpecConfig()
        end)
        spec:AddChild(perSpec)
    
        if ToshUnitFrames.db:IsDualSpecEnabled() then
            local specProfiles = AceGUI:Create("InlineGroup")
            specProfiles:SetFullWidth(true)
            specProfiles:SetLayout("Flow")
            for i=GetNumSpecializations(),1, -1 do
                local specSelect = AceGUI:Create("Dropdown")
                specSelect:SetLabel(select(2, GetSpecializationInfo(i)))
                specSelect:SetList(allProfiles)
                specSelect:SetValue(ToshUnitFrames.db:GetDualSpecProfile(i))
                specSelect:SetWidth(120)
                specSelect:SetCallback("OnValueChanged", function(w, msg, v)
                    ToshUnitFrames.db:SetDualSpecProfile(v, i)
                end)
        
                specProfiles:AddChild(specSelect)
            end
            spec:AddChild(specProfiles)
            profile:SetDisabled(true)
        else
            profile:SetDisabled(false)
        end
    end
    loadSpecConfig()

    return root
end
