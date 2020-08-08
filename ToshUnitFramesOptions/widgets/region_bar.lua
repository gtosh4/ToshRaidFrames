local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

function ns.typeWidgets.bar(region)
    local root = AceGUI:Create("SimpleGroup")

    root:AddChild(ns.CreateDropdown(region, "source", "Data Source", {
        ["health"]     = "Health",
        ["power"]      = "Power",
        ["classpower"] = "Class Power",
        ["altpower"]   = "Alternate Power",
    }))

    local tex = AceGUI:Create("LSM30_Statusbar")
    tex:SetLabel("Texture")
    tex:SetList()
    tex:SetValue(region.texture)
    tex:SetCallback("OnValueChanged", function(w, msg, v)
        region.texture = v
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    root:AddChild(tex)

    root:AddChild(ns.CreateAnchorWidget(region, true))

    return root
end
