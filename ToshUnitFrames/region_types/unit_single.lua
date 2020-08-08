local _, ns = ...

local tinsert = table.insert

local lsm = LibStub("LibSharedMedia-3.0")

local unitSinglePrototype = {
    width = 100,
    height = 50,
}

function unitSinglePrototype:Name()
    if self.name and self.name ~= "" then return self.name end
    return (self.unit or self.type) .. "#" .. self.id
end

function unitSinglePrototype:FrameName()
    local unit = self:UnitID()
        :gsub('^%l', string.upper)
        :gsub('t(arget)', 'T%1')
        :gsub('p(et)', 'P%1')
        :gsub('f(ocus)', 'F%1')

    return "oUF_ToshUnitFrames" .. unit .. "_" .. self.id
end

function unitSinglePrototype:Frame()
    local f = ToshUnitFrames.frames[self.id]
    if f then return f end
    
    return _G[self:FrameName()]
end

function unitSinglePrototype:Create(oUF)
    local f = self:Frame()
    if not f then
        f = oUF:Spawn(self:UnitID(), self:FrameName())
    else
        self:ApplyConfig(f)
    end
    ToshUnitFrames.frames[self.id] = f
end

function unitSinglePrototype:ApplyConfig(frame)
    if self.width and self.width > 0 then frame:SetWidth(self.width) end
    if self.height and self.height > 0 then frame:SetHeight(self.height) end
    self:SetAnchors(frame)

    if self.bg then
        f.bg = frame.bg or frame:CreateTexture(nil, "BORDER")
        f.bg:SetAllPoints()
        f.bg:SetTexture(lsm:Fetch("background", self.bg.texture))
    end

    self:ApplyConfigChildren(frame)
end

function unitSinglePrototype:UnitID()
    -- TODO include suffixes (eg 'pettarget', 'targettarget')
    return self.unit or ""
end

setmetatable(unitSinglePrototype, {__index=ToshUnitFrames.regionPrototypes["_container"]})
ToshUnitFrames.regionPrototypes["unit_single"] = unitSinglePrototype
