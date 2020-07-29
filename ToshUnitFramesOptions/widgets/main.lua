local AceGUI = LibStub("AceGUI-3.0")

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontNormal

----------------
-- Main Frame --
----------------
--[[
	Events :
		OnClose

]]
do
	local Type = "ToshUnitFramesOptions"
	local Version = 1

	local function frameOnShow(this)
		this.obj:Fire("OnShow")
	end

	local function frameOnClose(this)
		this.obj:Fire("OnClose")
	end

	local function closeOnClick(this)
		PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
		this.obj:Hide()
	end

	local function frameOnMouseDown(this)
		AceGUI:ClearFocus()
	end

	local function titleOnMouseDown(this)
		this:GetParent():StartMoving()
		AceGUI:ClearFocus()
	end

	local function frameOnMouseUp(this)
		local frame = this:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()
	end

	local function sizerseOnMouseDown(this)
		this:GetParent():StartSizing("BOTTOMRIGHT")
		AceGUI:ClearFocus()
	end

	local function sizersOnMouseDown(this)
		this:GetParent():StartSizing("BOTTOM")
		AceGUI:ClearFocus()
	end

	local function sizereOnMouseDown(this)
		this:GetParent():StartSizing("RIGHT")
		AceGUI:ClearFocus()
	end

	local function sizerOnMouseUp(this)
		this:GetParent():StopMovingOrSizing()
	end

	local function SetTitle(self,title)
        self.title:SetText(title)
	end

	local function SetStatusText(self,text)
		-- self.statustext:SetText(text)
	end

	local function Hide(self)
		self.frame:Hide()
	end

	local function Show(self)
		self.frame:Show()
	end

	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
		self:EnableResize(true)
		self:Show()
	end

	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end

	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end

	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end

	local function OnWidthSet(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end


	local function OnHeightSet(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end

	local function EnableResize(self, state)
		local func = state and "Show" or "Hide"
		self.sizer_se[func](self.sizer_se)
    end
    
    -- Borrowed from WeakAurasOptions
    local function CreateDecoration(frame, width)
        local deco1 = frame:CreateTexture(nil, "BACKGROUND")
        deco1:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        deco1:SetTexCoord(0.31, 0.67, 0, 0.63)
        deco1:SetSize(width, 40)
      
        local deco2 = frame:CreateTexture(nil, "BACKGROUND")
        deco2:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        deco2:SetTexCoord(0.21, 0.31, 0, 0.63)
        deco2:SetPoint("RIGHT", deco1, "LEFT")
        deco2:SetSize(30, 40)
        deco1.decoLeft = deco2
      
        local deco3 = frame:CreateTexture(nil, "BACKGROUND")
        deco3:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
        deco3:SetTexCoord(0.67, 0.77, 0, 0.63)
        deco3:SetPoint("LEFT", deco1, "RIGHT")
        deco3:SetSize(30, 40)
        deco1.decoRight = deco3
      
        return deco1
      end

    local function Constructor()
        if _G["ToshUnitFramesOptions"] then
            return _G["ToshUnitFramesOptions"].obj
        end

        local backdropTemplate = select(4, GetBuildInfo()) > 90000 and "BackdropTemplate"
		local frame = CreateFrame("Frame", "ToshUnitFramesOptions", UIParent, backdropTemplate)
        tinsert(UISpecialFrames, frame:GetName())

		local self = {}
		self.type = Type

		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetStatusText = SetStatusText
		self.SetStatusTable = SetStatusTable
		self.ApplyStatus = ApplyStatus
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet
		self.EnableResize = EnableResize

		self.localstatus = {}

		self.frame = frame
		frame.obj = self
		frame:SetWidth(700)
		frame:SetHeight(500)
		frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
		frame:EnableMouse()
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetScript("OnMouseDown", frameOnMouseDown)

		frame:SetScript("OnShow",frameOnShow)
		frame:SetScript("OnHide",frameOnClose)
		frame:SetMinResize(240,240)
        frame:SetToplevel(true)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        frame:SetBackdropColor(0, 0, 0, 1)

		local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -4, -4)
		close:SetScript("OnClick", closeOnClick)
		self.closebutton = close
		close.obj = self

        local title = CreateFrame("Button", nil, frame)
        title:SetPoint("TOP", 0, 12)
        title:SetSize(120, 40)
        title:SetNormalFontObject(GameFontNormal)
        title:SetPushedTextOffset(0,0)
		title:EnableMouse()
		title:SetScript("OnMouseDown",titleOnMouseDown)
        title:SetScript("OnMouseUp", frameOnMouseUp)
        self.title = title
        
        local titlebg = CreateDecoration(title, 100)
        titlebg:SetPoint("BOTTOMLEFT", title)
        titlebg:SetPoint("TOPRIGHT", title)
        title:SetNormalTexture(titlebg)

		local sizer_se = CreateFrame("BUTTON",nil,frame)
		sizer_se:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
		sizer_se:SetSize(25, 25)
		sizer_se:EnableMouse()
		sizer_se:SetScript("OnMouseDown",sizerseOnMouseDown)
		sizer_se:SetScript("OnMouseUp", sizerOnMouseUp)
        self.sizer_se = sizer_se
        
        local normal = sizer_se:CreateTexture(nil, "OVERLAY")
        normal:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        normal:SetPoint("BOTTOMLEFT", sizer_se, 0, 6)
        normal:SetPoint("TOPRIGHT", sizer_se, -6, 0)
        sizer_se:SetNormalTexture(normal)
      
        local pushed = sizer_se:CreateTexture(nil, "OVERLAY")
        pushed:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        pushed:SetPoint("BOTTOMLEFT", sizer_se, 0, 6)
        pushed:SetPoint("TOPRIGHT", sizer_se, -6, 0)
        sizer_se:SetPushedTexture(pushed)
      
        local highlight = sizer_se:CreateTexture(nil, "OVERLAY")
        highlight:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        highlight:SetPoint("BOTTOMLEFT", sizer_se, 0, 6)
        highlight:SetPoint("TOPRIGHT", sizer_se, -6, 0)
        sizer_se:SetHighlightTexture(highlight)

		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-32)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,13)

		AceGUI:RegisterAsContainer(self)
		return self
	end

	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end
