local PANEL = {}

local sw, sh = ScrW(), ScrH()

zb.PathowogenEnd = zb.PathowogenEnd

surface.CreateFont("ZB_UWUEnd1", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
    antialias = false
})

surface.CreateFont("ZB_UWUEnd2", {
    font = "Bahnschrift",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_UWUEnd3", {
    font = "Ari-W9500",
    size = ScreenScale(20),
    extended = true,
    weight = 400,
    antialias = false
})

surface.CreateFont("ZB_UWUEnd4", {
    font = "Bahnschrift",
    size = ScreenScale(50),
    extended = true,
    weight = 400,
    antialias = false,
	scanlines = 2,
})

function PANEL:Init()
	if IsValid(zb.PathowogenEnd) then
		zb.PathowogenEnd:Remove()
	end

	zb.PathowogenEnd = self

	self:SetPos(sw * 0.01, sh * 0.07)
	self:SetSize(sw * 0.3, sh * 0.9)

	-- local data = {}
	-- local ply = Entity(1)

	-- data[ply] = {}

	-- data[ply].og = {
	-- 	name = "Pluvtown Citizen",
	-- 	role = "survivor"
	-- }

	-- data[ply].now = {}
	-- data[ply].now.name = "Pluvtown Citizen"
	-- data[ply].now.alive = false
	-- data[ply].now.escaped = false
	-- data[ply].now.role = "furry"

	-- self.data = data

	self.appearAlpha = 255
	self.appearProgress = 0

	self:CreateAnimation(1, {
		index = 1,
		target = {
			appearAlpha = 0,
			appearProgress = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			-- self:SetSize(sw * 0.22 * self.appearProgress, sh * 0.12)
			-- self:SetAlpha(255 * self.appearProgress)
		end,
		OnComplete = function()
		end
	})

	surface.PlaySound("zbattle/dialogue/radio_talk.ogg")

	timer.Simple(10, function()
		if IsValid(self) then
			self:Close()
		end
	end)
end

function PANEL:SetData(winner, data)
	self.winner = winner
	self.data = data
end

local shadow = Color(0, 0, 0, 50)
local shadow2 = Color(0, 0, 0, 255)
local deadshadow = Color(0, 0, 0, 200)

local survivor = Color(168, 40, 40)
local traitor = Color(106, 29, 91)
local furry = Color(48, 134, 174)
local escapee = Color(237, 192, 80)

local red = Color(255, 0, 0)

local winText = {
	[0] = "Nobody won!",
	[1] = "Pathowogen wins!",
	[2] = "Survivors win!",
	[3] = "Contractor wins!"
}

local winColor = {
	[0] = color_white,
	[1] = furry,
	[2] = survivor,
	[3] = traitor
}

function PANEL:Paint(w, h)
	if !self.data then return end

	surface.SetDrawColor(41, 17, 17, 200)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(255, 0, 0)
	surface.DrawOutlinedRect(0, 0, w, h, 4)

	DisableClipping(true)
		draw.SimpleText("Status Report:", "ZB_UWUEnd2", w / 2 + 1, 0 - ScreenScale(10) + 1, shadow2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.GlowingText("Status Report:", "ZB_UWUEnd2", w / 2, 0 - ScreenScale(10), ColorAlpha(red, 255), ColorAlpha(red, 235), ColorAlpha(red, 10), TEXT_ALIGN_CENTER)
	DisableClipping(false)

	local count = 0
	local barsizeX, barsizeY = w * 0.4, h * 0.04

	for ply, v in SortedPairsByMemberValue(self.data, "role", false) do
		local y = count * h * 0.04

		local zebra
		if count % 2 == 0 then
			zebra = Color(0, 0, 0, 150)
		else
			zebra = Color(0, 0, 0, 100)
		end

		local offsetX, offsetY = 8, 8

		surface.SetDrawColor(zebra)
		surface.DrawRect(offsetX, y + offsetY, w - offsetX * 2, barsizeY)

		// og

		local color

		if v.role == "survivor" then
			color = survivor
		elseif v.role == "furry" then
			color = furry
		elseif v.role == "traitor" then
			color = traitor
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0 + offsetX, y + offsetY, barsizeX, barsizeY)

		surface.SetDrawColor(shadow)
		surface.DrawRect(0 + offsetX, y + offsetY + barsizeY / 2, barsizeX, barsizeY / 2)

		draw.SimpleText("->", "ZB_UWUEnd1", w / 2, barsizeY / 2.5 + y + offsetY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(v.name, "ZB_UWUEnd2", barsizeX / 2 + offsetX, barsizeY / 2.5 + y + offsetY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		// now

		color = nil
		if v.now.role == "survivor" then
			color = survivor
		elseif v.now.role == "furry" then
			color = furry
		elseif v.now.role == "traitor" then
			color = traitor
		end

		if v.now.escaped then
			color = escapee
		end

		offsetX, offsetY = w * 0.6 - 8, 8

		surface.SetDrawColor(color)
		surface.DrawRect(0 + offsetX, y + offsetY, barsizeX, barsizeY)

		surface.SetDrawColor(shadow)
		surface.DrawRect(0 + offsetX, y + offsetY + barsizeY / 2, barsizeX, barsizeY / 2)

		draw.SimpleText(v.now.name, "ZB_UWUEnd2", barsizeX / 2 + offsetX, barsizeY / 2.5 + y + offsetY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if !v.now.alive then
			surface.SetDrawColor(deadshadow)
			surface.DrawRect(0 + offsetX, y + offsetY, barsizeX, barsizeY)
		end

		count = count + 1
	end

	DisableClipping(true)
		surface.SetDrawColor(255, 255, 255, self.appearAlpha * 4)
		surface.DrawRect(0, 0 - ScreenScale(15), w, h + ScreenScale(15))

		color = winColor[self.winner]
		draw.SimpleText(winText[self.winner], "ZB_UWUEnd4", sw * 0.6 + 5, h * 0.04 + 5, shadow2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.GlowingText(winText[self.winner], "ZB_UWUEnd4", sw * 0.6, h * 0.04, ColorAlpha(color, 255), ColorAlpha(color, 235), ColorAlpha(color, 10), TEXT_ALIGN_CENTER)
	DisableClipping(false)
end

function PANEL:Think()
end

function PANEL:Close()
	if self.bClosing then return end
	self.bClosing = true

	sound.PlayFile("sound/zbattle/dialogue/radio_off.wav", "", function() end)

	self:CreateAnimation(1, {
		index = 2,
		target = {
			appearAlpha = 255,
			appearProgress = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			-- self:SetSize(sw * 0.22 * self.appearProgress, sh * 0.12)
			self:SetAlpha(255 * self.appearProgress / 2)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

vgui.Register("ZB_PathowogenEnd", PANEL, "EditablePanel")