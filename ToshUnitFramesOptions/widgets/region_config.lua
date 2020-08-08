local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

local methods = {}

function methods:SetRegionId(id)

    self:SetUserData("id", id)
    self:SetUserData("region", region)

    self.name:SetDisabled(false)
    self.typeSel:SetDisabled(false)

end

function ns:CreateRegionConfigWidget(id)
    local root = AceGUI:Create("SimpleGroup")
    root:SetLayout("Flow")

    if id == nil then 
        return root
    end

    if type(id) == "string" then
        id = tonumber(id)
    end
    assert(type(id) == "number")

    local region = ToshUnitFrames.regions[id]
    if region == nil then
        return root
    end

    local header = AceGUI:Create("SimpleGroup")
    header:SetFullWidth(true)
    header:SetLayout("Flow")
    root:AddChild(header)

    local name = AceGUI:Create("EditBox")
    name:SetLabel("Frame Name")
    name:SetText(region.name)
    name:SetCallback("OnEnterPressed", function(w, msg, name)
        region.name = name
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    root.name = name
    header:AddChild(name)

    local typeSel = AceGUI:Create("Dropdown")
    typeSel:SetWidth(160)
    header:AddChild(typeSel)
    
    if region.parent == nil then
        typeSel:SetList({
            ["unit_single"] = "Single Unit",
            ["unit_group"]  = "Unit Group",
        })
    else
        typeSel:SetList({
            ["dynamic"] = "Dynamic Group",
            ["static"]  = "Static Group",
            ["bar"]     = "Bar",
            ["icon"]    = "Icon",
            ["texture"] = "Texture",
        })
    end
    typeSel:SetValue(region.type)
    typeSel:SetCallback("OnValueChanged", function(w, msg, key)
        region.type = key
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)

    local delete = AceGUI:Create("Button")
    delete:SetText("Delete")
    delete:SetWidth(80)
    delete:SetCallback("OnClick", function()
        region:Remove()
        ToshUnitFrames.db.profile.selected = nil
    end)
    header:AddChild(delete)

    local config = AceGUI:Create("InlineGroup")
    config:SetFullHeight(true)
    config:SetFullWidth(true)
    config:SetLayout("Fill")
    root:AddChild(config)
    
    config:ReleaseChildren()

    if region.type then
        config:AddChild(ns.typeWidgets[region.type](region))
    end

    typeSel:SetCallback("OnValueChanged", function(w, msg, val)
        region.type = val

        config:ReleaseChildren()
        if region.type then
            config:AddChild(ns.typeWidgets[region.type](region))
        end
        
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)

    return root
end
