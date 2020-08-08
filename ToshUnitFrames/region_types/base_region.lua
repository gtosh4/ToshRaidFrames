local regionPrototype = {}
ToshUnitFrames.regionPrototypes["_region"] = regionPrototype

function regionPrototype:Remove()
    if self.parent == nil then
        ToshUnitFrames.regions:Remove(self.id)
    else
        self.parent:RemoveChild(self)
    end
end

function regionPrototype:Name()
    if self.name and self.name ~= "" then
        return self.name
    elseif self.type then
        return self.type .. "#" .. self.id
    else
        return "#"..self.id
    end
end


-- Not all regions will have anchors (or be respected if part of a container)
function regionPrototype:SetAnchors(frame)
    if not self.anchors then return end
    if not frame then return end

    frame:ClearAllPoints()

    for i, a in ipairs(self.anchors) do
        if a.from then 
            local args = {a.from}
            if a.otherFrame and a.otherFrame ~= "" and _G[a.otherFrame] then
                args[#args+1] = _G[a.otherFrame]

                if a.to and a.to ~= "" then
                    args[#args+1] = a.to
                end
            elseif a.to and a.to ~= "" then
                args[#args+1] = frame:GetParent()
                args[#args+1] = a.to
            end
            args[#args+1] = a.x or 0
            args[#args+1] = a.y or 0
            frame:SetPoint(unpack(args))
        end
    end
end

function regionPrototype:Debug(data, msg)
    local d = {}
    if type(data) == "table" then
        for k,v in pairs(data) do
            d[k] = v
        end
    else
        d.data = data
    end
    d.region = self
    ToshUnitFrames:Debug(data, msg)
end
