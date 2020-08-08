local _, ns = ...
local oUF = ns.oUF

local wipe = table.wipe

-- spawningRegion is used to make sure that the `.tuf_region` is set on frames
-- spawned by `unitRegion:Create` before elements are enabled.
local spawningRegion

function ToshUnitFrames:UpdateUnitFrames()
    oUF:Factory(function(self)
		self:SetActiveStyle("ToshUnitFrames")

		for _, frame in pairs(ToshUnitFrames.frames) do
			if frame.UnregisterUnitWatch then frame:UnregisterUnitWatch() end
			frame:UnregisterAllEvents()
			frame:Hide()
		end
		wipe(ToshUnitFrames.frames)

         for id, unitRegion in ToshUnitFrames.units() do
			if unitRegion.Create then
				spawningRegion = unitRegion
				unitRegion:Create(self)
				spawningRegion = nil
            else
                ToshUnitFrames:Printf("no create for %s", unitRegion.Name and unitRegion:Name() or ("#"..unitRegion.id))
            end
		end
    end)
end

oUF:RegisterStyle("ToshUnitFrames", function(frame, unit)
	if frame.tuf then wipe(frame.tuf) else frame.tuf = {} end
	
	if spawningRegion then
		frame.tuf_region = spawningRegion
		return
	end
	-- for styling units with headers
	local parent = frame:GetParent()
	if parent.tuf_region then
		frame.tuf_region = parent.tuf_region
	end
end)


do -- backdrop management (borrowed from grid2)

	local format = string.format
	local tostring = tostring
	local backdrops = {}
	-- Generates a backdrop table, reuses tables avoiding to create duplicates
	function ns:GetBackdropTable(edgeFile, edgeSize, bgFile, tile, tileSize, inset)
		inset = inset or edgeSize
		local key = format("%s;%s;%d;%s;%d;%d", bgFile or "", edgeFile or "", edgeSize or -1, tostring(tile), tileSize or -1, inset or -1)
		local backdrop = backdrops[key]
		if not backdrop then
			backdrop = {
				bgFile = bgFile,
				tile = tile,
				tileSize = tileSize,
				edgeFile = edgeFile,
				edgeSize = edgeSize,
				insets = { left = inset, right = inset, top = inset, bottom = inset },
			}
			backdrops[key] = backdrop
		end
		return backdrop
    end
    
	function ns:SetFrameBackdrop(frame, backdrop)
		if backdrop~=frame.currentBackdrop then
			frame:SetBackdrop(backdrop)
			frame.currentBackdrop = backdrop
		end
	end
end
