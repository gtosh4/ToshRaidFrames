local _, ns = ...

local textPrototype = {}
ToshUnitFrames.regionPrototypes["text"] = setmetatable(textPrototype, {__index=ToshUnitFrames.regionPrototypes["_region"]})
