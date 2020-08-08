local _, ns = ...
local oUF = ns.oUF

local function Update(frame, event, unit)
    if(frame.unit ~= unit) then return end
    ToshUnitFrames:Debug({frame=frame, event=event, unit=unit}, "TUF_Regions:Update")
    if not frame.tuf_region then return end

    local region = frame.tuf_region

    if region.Update then region:Update(frame, event, unit) end
end

local function Enable(frame)
    ToshUnitFrames:Debug({frame=frame, event=event, unit=unit}, "TUF_Regions:Enable")
    if not frame.tuf_region then return end

    local region = frame.tuf_region

    if region.Enable then region:Enable(frame) end
    if region.ApplyConfig then region:ApplyConfig(frame) end
    return true
end

local function Disable(frame)
    ToshUnitFrames:Debug({frame=frame, event=event, unit=unit}, "TUF_Regions:Disable")
    if not frame.tuf_region then return end

    local region = frame.tuf_region

    if region.Disable then region:Disable(frame) end
end

--[[ Hook our regions into the oUF system using one element to manage all the regions
    Alternatives:
    * One element per region
        as regions get added & removed, would cause a lot of dangling elements. Also
        elements are generally supposed to be generally applicable.
    * One element per type
        while it mostly solves issues with the previous, it might have a hard time
        working properly with containers (dynamic/static) and oUF elements aren't
        designed around this relationship.
--]] 
oUF:AddElement('TUF_Regions', Update, Enable, Disable)
