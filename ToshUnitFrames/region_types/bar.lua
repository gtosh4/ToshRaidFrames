local _, ns = ...

local lsm = LibStub("LibSharedMedia-3.0")

local barPrototype = {
    --[[ Fields
    * texture
    * events
    * source
    * powertype? if source == 'power'
    * orientation?
    * reverseFill?
    * color?
    --]]
}

function barPrototype:Enable(frame)
    local bar = frame.tuf[self.id] or CreateFrame("StatusBar")
    frame.tuf[self.id] = bar

    ToshUnitFrames:Debug({region=self, frame=frame, bar=bar}, "bar:Enable")
    bar.tuf_region = self

    -- define the function here so there's a unique function
    -- for each instance, but that can be released by
    -- the Disable call.
    function self.Update(frame, event, unit)
        local min, max, cur = self._values(unit)
        if cur then
            bar:SetMinMaxValues(min or 0, max or cur)
            bar:SetValue(cur)
        end
    end

    bar:SetParent(frame)

    for _, event in ipairs(self._events or {}) do
        frame:RegisterEvent(event, self.Update)
    end
end

function barPrototype:Disable(frame)
    local bar = frame.tuf and frame.tuf[self.id]
    ToshUnitFrames:Debug({region=self, frame=frame, bar=bar}, "bar:Disable")
    if not bar then return end

    bar:Hide()

    for _, event in ipairs(self._events or {}) do
        frame:UnregisterEvent(event, self.Update)
    end
end

local sourceEvents = {
    ["health"] = {"UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH"},
    ["power"] = {"UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_POWER_BAR_HIDE", "UNIT_POWER_BAR_SHOW", "UNIT_FLAGS"},
}
sourceEvents.classpower = sourceEvents.power
sourceEvents.altpower = sourceEvents.power

function barPrototype:ApplyConfig(frame)
    local bar = frame.tuf and frame.tuf[self.id]
    if not bar then return end

    self:SetAnchors(bar)
    
    if self.texture then
        local tex = lsm:Fetch("statusbar", self.texture)
        if bar:IsObjectType('StatusBar') then
            bar:SetStatusBarTexture(tex)
        elseif bar:IsObjectType('Texture') then
            bar:SetTexture(tex)
        end
    end
    if self.orientation then
        self:SetOrientation(self.orientation)
    end
    if self.reverseFill then
        self:SetReverseFill(self.reverseFill)
    end

    self._events = sourceEvents[self.source]

    if self.source == "health" then
        self._values = function(unit)
            return 0, UnitHealthMax(unit), UnitHealth(unit)
        end
    elseif self.source == "power" then
        self._values = function(unit)
            return 0, UnitPowerMax(unit), UnitPower(unit)
        end
    elseif self.source == "classpower" then
        self._values = function(unit)
            local pt = self.powertype or UnitPowerType(unit)

            -- Copied from oUF classpower
            local cur = UnitPower(unit, pt, true)
            local mod = UnitPowerDisplayMod(pt)
            cur = mod == 0 and 0 or cur / mod

            return 0, UnitPowerMax(unit, pt), cur
        end
    elseif self.source == "altpower" then
        self._values = function(unit)
            local barID = UnitPowerBarID(unit)
            local barInfo = GetUnitPowerBarInfoByID(barID)
            if barInfo and barInfo.barType then
                return barInfo.minPower, UnitPowerMax(unit, Enum.PowerType.Alternate), UnitPower(unit, Enum.PowerType.Alternate)
            end
        end
    else
        self._values = function() return end
    end
end

ToshUnitFrames.regionPrototypes["bar"] = setmetatable(barPrototype, {__index=ToshUnitFrames.regionPrototypes["_region"]})
