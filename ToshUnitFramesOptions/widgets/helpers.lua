local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

ns.backdropTemplate = select(4, GetBuildInfo()) > 90000 and "BackdropTemplate"

ns.typeWidgets = {}

local tremove = table.remove

function ns.Confirm(text, callback)
    local root = AceGUI:Create("Window")
    root.sizer_se:Hide()
    root.sizer_s:Hide()
    root.sizer_e:Hide()
    root:SetHeight(72)
    root:SetWidth(320)
    root:SetTitle(text)
    root:SetLayout("Flow")

    local accept = AceGUI:Create("Button")
    accept:SetText("Accept")
    accept:SetRelativeWidth(0.5)
    accept:SetCallback("OnClick", function()
        root:Hide()
        root:Release()
        callback()
    end)
    root:AddChild(accept)

    local cancel = AceGUI:Create("Button")
    cancel:SetText("Cancel")
    cancel:SetRelativeWidth(0.5)
    cancel:SetCallback("OnClick", function()
        root:Hide()
        root:Release()
    end)
    root:AddChild(cancel)

    root.frame:Show()
end

function ns.CreateAnchorWidget(region, showOther)
    local root = AceGUI:Create("InlineGroup")
    root:SetFullWidth(true)

    -- TODO make this a table

    local points = {}
    local toPoints = {[""] = ""}
    for _, p in ipairs({
        "CENTER",
        "TOP", "BOTTOM", "LEFT", "RIGHT",
        "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT",
    }) do
        points[p] = p
        toPoints[p] = p
    end

    function setAnchors()
        root:ReleaseChildren()

        if region.anchors then
            for i, a in ipairs(region.anchors) do
                local g = AceGUI:Create("SimpleGroup")
                g:SetFullWidth(true)
                g:SetLayout("Flow")
                
                local from = AceGUI:Create("Dropdown")
                from:SetLabel("From")
                from:SetWidth(140)
                from:SetList(points)
                from:SetValue(a.from)
                from:SetCallback("OnValueChanged", function(w, msg, v)
                    a.from = v
                    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                end)
                g:AddChild(from)

                if showOther then
                    local other = AceGUI:Create("EditBox")
                    other:SetLabel("Other Frame")
                    other:SetWidth(120)
                    other:SetText(a.otherFrame)
                    other:SetCallback("OnEnterPressed", function(w, msg, v)
                        if v == "" then a.otherFrame = nil
                        elseif not _G[v] then return
                        else a.otherFrame = v
                        end
                        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                    end)
                    g:AddChild(other)
                end

                local to = AceGUI:Create("Dropdown")
                to:SetLabel("To")
                to:SetWidth(140)
                to:SetList(toPoints)
                to:SetValue(a.to)
                to:SetCallback("OnValueChanged", function(w, msg, v)
                    a.to = v
                    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                end)
                g:AddChild(to)

                local x = AceGUI:Create("EditBox")
                x:SetLabel("X off")
                x:SetWidth(60)
                x:SetText(a.x)
                x:SetCallback("OnEnterPressed", function(w, msg, v)
                    v = tonumber(v)
                    if not v then return end
                    a.x = v
                    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                end)
                g:AddChild(x)

                local y = AceGUI:Create("EditBox")
                y:SetLabel("Y off")
                y:SetWidth(60)
                y:SetText(a.y)
                y:SetCallback("OnEnterPressed", function(w, msg, v)
                    v = tonumber(v)
                    if not v then return end
                    a.y = v
                    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                end)
                g:AddChild(y)

                local delete = AceGUI:Create("Button")
                delete:SetText("Remove")
                delete:SetWidth(90)
                delete:SetCallback("OnClick", function()
                    tremove(region.anchors, i)
                    ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
                    setAnchors()
                end)
                g:AddChild(delete)

                root:AddChild(g)
            end
        end

        local addAnchor = AceGUI:Create("Button")
        addAnchor:SetText("Add Anchor")
        addAnchor:SetWidth(120)
        addAnchor:SetCallback("OnClick", function()
            region.anchors = region.anchors or {}
            region.anchors[#region.anchors+1] = {}
            setAnchors()
        end)

        root:AddChild(addAnchor)
    end
    setAnchors()

    return root
end

function ns.CreateDropdown(region, key, label, list)
    local f = AceGUI:Create("Dropdown")
    f:SetLabel(label)
    f:SetList(list)
    f:SetValue(region[key])

    f:SetCallback("OnValueChanged", function(w, msg, v)
        region[key] = v
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)

    return f
end

local function SliderBounds(min, max, value)
    if not value then return min, max end

    local bound = (max-min) * 0.15

    -- if the value is within 15% of either end
    -- set the value to the middle:
    -- value = (max-min)/2
    if value < min+bound then
        min = max - value*2
    elseif value > max-bound then
        max = value*2 - min
    end

    return min, max
end

function ns.CreateSizeConfig(region)
    local root = AceGUI:Create("SimpleGroup")

    local width = AceGUI:Create("Slider")
    width:SetLabel("Width")
    width:SetSliderValues(SliderBounds(0, 500, region.width))
    width:SetValue(region.width or 0)
    width:SetCallback("OnValueChanged", function(w, msg, v)
        region.width = v
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    width:SetCallback("OnMouseUp", function(w, msg, v)
        width:SetSliderValues(SliderBounds(0, 500, v))
    end)
    root:AddChild(width)

    local height = AceGUI:Create("Slider")
    height:SetLabel("Height")
    height:SetSliderValues(SliderBounds(0, 500, region.height))
    height:SetValue(region.height or 0)
    height:SetCallback("OnValueChanged", function(w, msg, v)
        region.height = v
        ToshUnitFrames:SendMessage("TUF_FRAMES_UPDATED")
    end)
    height:SetCallback("OnMouseUp", function(w, msg, v)
        height:SetSliderValues(SliderBounds(0, 500, v))
    end)
    root:AddChild(height)

    return root
end
