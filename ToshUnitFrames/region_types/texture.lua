local _, ns = ...

local texturePrototype = {}
ToshUnitFrames.regionPrototypes["texture"] = setmetatable(texturePrototype, {__index=ToshUnitFrames.regionPrototypes["_region"]})
