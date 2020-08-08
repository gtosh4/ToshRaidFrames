local _, ns = ...

local dynamicPrototype = {}
ToshUnitFrames.regionPrototypes["dynamic"] = setmetatable(dynamicPrototype, {__index=ToshUnitFrames.regionPrototypes["_container"]})
