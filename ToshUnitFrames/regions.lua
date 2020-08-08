local ToshUnitFrames = ToshUnitFrames

local tinsert, tremove = table.insert, table.remove
local wipe = table.wipe

ToshUnitFrames.containerTypes = {
    ["unit_single"] = true,
    ["unit_group"]  = true,
    ["static"]      = true,
    ["dynamic"]     = true,
}

ToshUnitFrames.regionPrototypes = {}


function ToshUnitFrames.regions:Add(v)
    assert(type(v) == "table", "expected table, got " .. type(v))
    if v.id == nil then
        v.id = ToshUnitFrames:NextID()
    end
    ToshUnitFrames.db.profile.regions[v.id] = v
    ToshUnitFrames:Debug(v, "added region")
    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    return v
end

function ToshUnitFrames.regions:Remove(v)
    if type(v) == "number" then
        v = self[v]
        if v == nil then return end
    end
    assert(type(v) == "table")

    ToshUnitFrames.db.profile.regions[v.id] = nil
    if v.children then
        for i,child in ipairs(v.children) do
            ToshUnitFrames.regions[child]:Remove()
        end
    end
    ToshUnitFrames:Debug(v, "removed region")
    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    return v
end

setmetatable(ToshUnitFrames.regions, {
    __index = function(self, k)
        local props = ToshUnitFrames.db.profile.regions[k]
        if props == nil then
            return nil
        end
        setmetatable(props, {__index=ToshUnitFrames.regionPrototypes[props.type or "_region"]})
        return props
    end,

    __newindex = function(self, k, v)
        assert(type(v) == "table")
        
        if not ToshUnitFrames.db.profile.regions then
            ToshUnitFrames.db.profile.regions = {}
        end
        ToshUnitFrames.db.profile.regions[k] = v
    end,
})

function ToshUnitFrames.units:Add(v)
    return ToshUnitFrames.regions:Add(v)
end

function ToshUnitFrames.units:Remove(v)
    return ToshUnitFrames.regions:Remove(v)
end


setmetatable(ToshUnitFrames.units, {
    __index = function(self, k)
        return ToshUnitFrames.regions[k]
    end,

    __newindex = function(self, k, v)
        assert(type(v) == "table")
        if not v.id then v.id = k end
        assert(v.id == k)

        ToshUnitFrames.db.profile.regions[k] = v
    end,

    __call = function(self)
        local f = {}
        -- directly use the profile objects so we don't go around setting metatables we don't need.
        for k, v in pairs(ToshUnitFrames.db.profile.regions) do
            if v.type == "unit_single" or v.type == "unit_group" then
                f[k] = ToshUnitFrames.regions[k]
            end
        end
        return pairs(f)
    end,
})


function ToshUnitFrames:NextID()
    local id = self.db.profile.nextid
    if id == nil then
        if self.db.profile.regions == nil then
            self.db.profile.regions = {}
            id = 1
        else
            id = next(self.db.profile.regions)
            if id == nil then
                id = 1
            end
        end
    end
    while self.db.profile.regions[id] ~= nil do
        id = id + 1
    end
    self.db.profile.nextid = id+1
    return id
end
