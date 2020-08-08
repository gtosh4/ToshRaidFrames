local containerPrototype = {}

function containerPrototype:AddChild(child)
    if type(child) == "table" then
        ToshUnitFrames.regions:Add(child)
    elseif type(child) == "number" then
        child = ToshUnitFrames.regions[child]
    end
    assert(type(child) == "table")

    self.children = self.children or {}
    tinsert(self.children, child.id)
    child.parent = self.id

    return child
end

function containerPrototype:Parent()
    return ToshUnitFrames.regions[self.parent]
end

function containerPrototype:Children()
    local c = {}
    for i, id in ipairs(self.children) do
        c[i] = ToshUnitFrames.regions[id]
    end
    return c
end

local function multiplex(self, funcName, ...)
    ToshUnitFrames:Debug({region=self, funcName=funcName, args={...}}, ("multiplex:%d:%s"):format(self.id, funcName))
    if not self.children then return end

    for _, id in ipairs(self.children) do
        local c = ToshUnitFrames.regions[id]
        if c and c[funcName] then c[funcName](c, ...) end
    end
end

function containerPrototype:Enable(frame)
    multiplex(self, "Enable", frame)
end
containerPrototype.EnableChildren = containerPrototype.Enable

function containerPrototype:Disable(frame)
    multiplex(self, "Disable", frame)
end
containerPrototype.DisableChildren = containerPrototype.Disable

function containerPrototype:Update(frame, ...)
    multiplex(self, "Update", frame, ...)
end
containerPrototype.UpdateChildren = containerPrototype.Update

function containerPrototype:ApplyConfig(frame)
    multiplex(self, "ApplyConfig", frame)
end
containerPrototype.ApplyConfigChildren = containerPrototype.ApplyConfig

function containerPrototype:RemoveChild(child)
    if type(child) == "table" then
        child = child.id
    end
    assert(type(child) == "number")

    ToshUnitFrames.regions:Remove(child)

    for i=#self.children,1,-1 do
        if self.children[i] == child then
            ToshUnitFrames.regions[self.children[i]]:Remove()
        end
    end
end

setmetatable(containerPrototype, {__index=ToshUnitFrames.regionPrototypes["_region"]})
ToshUnitFrames.regionPrototypes["_container"] = containerPrototype
