local _, ns = ...

local staticPrototype = {}
ToshUnitFrames.regionPrototypes["static"] = setmetatable(staticPrototype, {__index=ToshUnitFrames.regionPrototypes["_container"]})
