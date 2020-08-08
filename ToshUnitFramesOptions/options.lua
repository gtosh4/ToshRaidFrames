local _, ns = ...

local ToshUnitFrames = ToshUnitFrames

local tinsert = table.insert

local defaultOptions = {}

function ToshUnitFrames:InitializeOptions()
	self:MakeOptions()
	self.InitializeOptions = nil
end

local optionsFrame
local optionsAfterCombat

function ToshUnitFrames:OptionsAfterCombat()
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
    if optionsFrame then
        optionsFrame:Hide()
    end
end

function ToshUnitFrames:ShowOptions()
    if not(optionsFrame) then
        self:MakeOptions()
    end
    optionsFrame:Show()
end

local function treeFromObj(obj)
    if obj == nil then return end

    local tree = {}

    for _, region in ipairs(obj) do
        local t = {
            value = region.id,
            text = region:Name(),
        }

        if region.Children then
            t.children = treeFromObj(region:Children())
        end

        tree[#tree+1] = t
    end

    return tree
end

function ToshUnitFrames:TreeFromDB()
    local tree = {}

    tree[#tree+1] = {
        value = "GENERAL",
        text = "General",
        children = {
            {
                value = "PROFILES",
                text = "Profiles",
            }
        },
    }

    local units = {}

    for id, unit in self.units() do
        local t = {
            value = id,
            text = unit:Name(),
            visible = true,
        }
        if unit.children then
            t.children = treeFromObj(unit:Children())
        end
        units[#units+1] = t
    end

    units[#units+1] = {
        value = "NEWUNIT",
        text = "+ New Unit",
    }

    tree[#tree+1] = {
        value = "UNITS",
        text = "Units",
        children = units,
    }

    return tree
end

function ToshUnitFrames:MakeOptions()
    local AceGUI = LibStub("AceGUI-3.0")

    local frame = ns:CreateRootWidget()

    frame.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame.frame:SetScript("OnEvent", function(self, event) -- TODO move into main?
        if event == "PLAYER_REGEN_DISABLED" and frame:IsVisible() then
            ToshUnitFrames:OptionsAfterCombat()
            ToshUnitFrames.HideOptions()
        elseif event == "PLAYER_REGEN_ENABLED" then
            if optionsAfterCombat then
                optionsAfterCombat = false
                ToshUnitFrames:ShowOptions()
            end
        end
    end)

    local tree = AceGUI:Create("TreeGroup")
    tree:SetLayout("Fill")

    function frame:UpdateTree()
        tree:SetTree(ToshUnitFrames:TreeFromDB())
        if ToshUnitFrames.db.profile.selected then
          tree:SelectByPath(unpack(ToshUnitFrames.db.profile.selected))
        end
    end
    -- NOTE: make sure that "self" isn't ToshUnitFrames so that it doesn't overwrite the previous
    -- handler.
    self.RegisterMessage(frame, "TUF_FRAMES_UPDATED", "UpdateTree")
    frame:AddChild(tree)

    function ns.ScrollTo(region)
        local path = {region.id}
        local p = region.parent
        while p do
            path[#path+1] = p
        end

        for i=1,#path/2 do -- reverse
            path[i], path[#path-i+1] = path[#path-i+1], path[i]
        end

        tree:SelectByPath(unpack(path))
    end

    tree:SetCallback("OnGroupSelected", function(w, name, group)
        if group == nil or group == "" then return end

        group = {("\001"):split(group)}
        self.db.profile.selected = group

        if group[1] == "GENERAL" then
            tree:ReleaseChildren()
            if group[2] == "PROFILES" then
                tree:AddChild(ns:CreateProfilesWidget())
                return
            end

        elseif group[1] == "UNITS" then
            local unit = group[#group]
            if unit == "NEWUNIT" then
                --[[
                    Clear out the selected otherwise on the Add() call, when it refreshes the tree
                    it well re-select New Unit and infinite loop.
                ]]
                self.db.profile.selected = nil

                local v = ToshUnitFrames.units:Add({type="unit_single"})
                ns.ScrollTo(v)
            else
                local regionCfg = ns:CreateRegionConfigWidget(unit)
                tree:ReleaseChildren()
                tree:AddChild(regionCfg)
            end
        end
    end)

    frame:UpdateTree()

    optionsFrame = frame
end
