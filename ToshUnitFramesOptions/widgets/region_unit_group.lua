local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

function ns.typeWidgets.unit_group(region)
    local root = AceGUI:Create("SimpleGroup")

    local unitSel = AceGUI:Create("Dropdown")
    unitSel:SetList({
        ["party"] = "Party",
        ["raid"]  = "Raid",
    })

    unitSel:SetCallback("OnValueChanged", function(w, msg, unit)
        region.unit = unit
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    root:AddChild(unitSel)

    return root
end
