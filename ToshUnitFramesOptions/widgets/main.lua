local _, ns = ...

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

	local function updateOptions(frame)
		local opts = ToshUnitFrames.db.global.options
		if not opts then
			opts = {}
			ToshUnitFrames.db.global.options = opts
		end
		opts.width = frame:GetWidth()
		opts.height = frame:GetHeight()
		if frame:GetNumPoints() > 0 then
			local pt = {frame:GetPoint(1)}
			opts.pos = {
				from=pt[1],
				to=pt[3],
				x=pt[4],
				y=pt[5],
			}
		end
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
		updateOptions(frame)
	end

	local function sizerseOnMouseDown(this)
		this:GetParent():StartSizing("BOTTOMRIGHT")
		AceGUI:ClearFocus()
	end

	local function sizerOnMouseUp(this)
		this:GetParent():StopMovingOrSizing()
		updateOptions(this:GetParent())
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
	
	local function CreateDecoration(frame)
		local bg = frame:CreateTexture(nil, "OVERLAY")
		bg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		bg:SetTexCoord(0.31, 0.69, 0, 0.63)
		bg:SetHeight(40)
		bg:SetPoint("LEFT", frame)
		bg:SetPoint("RIGHT", frame)
	  
		local bgL = frame:CreateTexture(nil, "OVERLAY")
		bgL:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		bgL:SetTexCoord(0.21, 0.31, 0, 0.63)
		bgL:SetPoint("RIGHT", bg, "LEFT")
		bgL:SetSize(30, 40)
	
		local bgR = frame:CreateTexture(nil, "OVERLAY")
		bgR:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
		bgR:SetTexCoord(0.69, 0.79, 0, 0.63)
		bgR:SetPoint("LEFT", bg, "RIGHT")
		bgR:SetSize(30, 40)
	  
		return bg
	end

    function ns:CreateRootWidget()
        if _G["ToshUnitFramesOptions"] then -- only one instance allowed
            return _G["ToshUnitFramesOptions"].obj
        end

		local frame = CreateFrame("Frame", "ToshUnitFramesOptions", UIParent, ns.backdropTemplate)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
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

		local opts = ToshUnitFrames.db.global.options or {}
		frame:SetWidth(opts.width or 700)
		frame:SetHeight(opts.height or 500)
		local pos = opts.pos or {}
		frame:SetPoint(pos.from or "CENTER", UIParent, pos.to or "CENTER", pos.x or 0, pos.y or 0)
		ToshUnitFrames:Debug(opts, "options frame")

		frame:EnableMouse()
		frame:SetClampedToScreen(true)
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetFrameStrata("DIALOG")
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
		

		local closebg = CreateFrame("Frame", nil, frame)
		closebg:SetPoint("TOPRIGHT", -12, 12)
		closebg:SetSize(5, 40)
		CreateDecoration(closebg)

		local close = CreateFrame("Button", nil, closebg, "UIPanelCloseButton")
		close:SetPoint("CENTER")
		close:SetScript("OnClick", closeOnClick)
		self.closebutton = close
		close.obj = self

		local title = CreateFrame("Button", nil, frame)
        title:SetPoint("TOP", 0, 12)
		title:SetSize(100, 40)
        title:SetNormalFontObject(GameFontNormal)
        title:SetPushedTextOffset(0,0)
		title:EnableMouse()
		title:SetScript("OnMouseDown",titleOnMouseDown)
		title:SetScript("OnMouseUp", frameOnMouseUp)
		title:SetText("Tosh UF " .. ToshUnitFrames.versionString)
        self.title = title
        
		local titlebg = CreateDecoration(title)
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
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-18)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,12)

		AceGUI:RegisterAsContainer(self)

		self:SetLayout("Fill")
		self:Hide()

		return self
	end
end
