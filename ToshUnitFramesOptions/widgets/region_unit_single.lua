local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

function ns.typeWidgets.unit_single(region)
    local root = AceGUI:Create("SimpleGroup")
    root:SetFullWidth(true)

    root:AddChild(ns.CreateDropdown(region, "unit", "Unit", {
        ["player"] = "Player",
        ["pet"]    = "Pet",
        ["target"] = "Target",
        ["focus"]  = "Focus",
    }))

    root:AddChild(ns.CreateSizeConfig(region))

    local bg = AceGUI:Create("LSM30_Background")
    bg:SetLabel("Background")
    bg:SetList()
    bg:SetValue(region.bg and region.bg.texture)
    bg:SetCallback("OnValueChanged", function(w, msg, v)
        if v == "None" then
            region.bg = nil
        else
            region.bg = region.bg or {}
            region.bg.texture = v
        end
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    root:AddChild(bg)

    root:AddChild(ns.CreateAnchorWidget(region))

    local newChild = AceGUI:Create("Button")
    newChild:SetText("Add Region")
    newChild:SetWidth(120)
    newChild:SetCallback("OnClick", function()
        local child = region:AddChild({})
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
        --ns.ScrollTo(child)
    end)

    root:AddChild(newChild)

    return root
end
