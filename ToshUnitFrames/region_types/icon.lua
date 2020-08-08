local _, ns = ...

local iconPrototype = {}
ToshUnitFrames.regionPrototypes["icon"] = setmetatable(iconPrototype, {__index=ToshUnitFrames.regionPrototypes["_region"]})
