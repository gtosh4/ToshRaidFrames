local _, ns = ...

local unitGroupPrototype = {}

function unitGroupPrototype:Name()
    if self.name and self.name ~= "" then return self.name end
    return (self.unit or self.type) .. "." .. self.id
end

ToshUnitFrames.regionPrototypes["unit_group"] = setmetatable(unitGroupPrototype, {__index=ToshUnitFrames.regionPrototypes["_container"]})
