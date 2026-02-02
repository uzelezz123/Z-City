local PANEL = {}

local sw, sh = ScrW(), ScrH()

local text = "There's an unknown pathowogen virus ravaging your current area. Your location is now under immediate quarantine until further notice, we'll try to figure out the means of your extraction in the meantime."

local COMMANDER = Material("zbattle/CONTRACTOR.png", "smooth")

surface.CreateFont("ZB_PathowogenDialogue", {
	font = "Bahnschrift",
	size = ScreenScale(6),
	extended = true,
	weight = 400,
	antialias = true,
	scanlines = 2
})

surface.CreateFont("ZB_PathowogenDialogueTitle", {
	font = "Bahnschrift",
	size = ScreenScale(10),
	extended = true,
	weight = 400,
	antialias = true,
	scanlines = 2
})

function PANEL:Init()
	self:SetPos(sw * 0.07, sh * 0.07)
	self:SetSize(sw * 0.22, sh * 0.12)

	if IsValid(zb.DialogueWindow) then
		zb.DialogueWindow:Remove()
	end

	zb.DialogueWindow = self

	self.textread = ""
	self.textpos = 0
	self.currenttext = ""

	surface.PlaySound("zbattle/dialogue/radio_talk.ogg")

	-- timer.Simple(1.2, function()
	--     self:CreateAnimation(#text / 20, {
	--         index = 1,
	--         target = {
	--             textpos = #text
	--         },
	--         easing = "linear",
	--         bIgnoreConfig = true,
	--         Think = function()
	--             local newtext = string.sub(text, 0, self.textpos)

	--             if self.currenttext != newtext then
	--                 sound.PlayFile("sound/zbattle/dialogue/commander_talk2.ogg", "", function() end)
	--                 self.currenttext = newtext
	--                 self.text:SetText(newtext)
	--             end
	--         end,
	--         OnComplete = function()
	--         end
	--     })
	-- end)

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

	self.CloseOnLast = false
	self.bClosing = false

	self.text = vgui.Create("DLabel", self)
	self.text:Dock(FILL)
	self.text:DockMargin(sw * 0.22 * 0.3 + ScreenScale(1), ScreenScale(10), 0, 0)
	self.text:SetText(self.currenttext)
	self.text:SetFont("ZB_PathowogenDialogue")
	self.text:SetContentAlignment(4)
	self.text:SetTextColor(color_white)
	self.text:SetWrap(true)
	self.text:SetAutoStretchVertical(true)

	self.timebetween = SysTime() + 1.2

	-- timer.Simple(15, function()
	-- 	self:Close()
	-- end)
end

local glow = Material("zbattle/borderglow2.png")

local red = Color(93, 19, 93)

function PANEL:Paint(w, h)
	surface.SetDrawColor(59, 9, 44, 235)
	surface.DrawRect(0, h * 0.2, w, h)

	surface.SetDrawColor(67, 10, 64, 50)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(56, 30, 46)
	surface.DrawRect(0, 0, w * 0.3, h)

	surface.SetMaterial(COMMANDER)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(0, 0, w * 0.3, h)

	surface.SetDrawColor(0, 0, 0)
	surface.DrawOutlinedRect(0, 0, w * 0.3, h, ScreenScale(1))

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(glow)

	for i = 1, 10 do
		surface.SetDrawColor(144, 35, 119, 10)
		surface.DrawRect(0, ((h / 10 * i) + (CurTime() * 10)) % h, w * 0.3, ScreenScale(1))
	end

	DisableClipping(true)
		surface.SetDrawColor(0, 0, 0, self.appearProgress * 255)
		surface.DrawTexturedRect(-ScreenScale(4) - 1, -ScreenScale(4), w * 0.3 + ScreenScale(8) + 1, h + ScreenScale(8))
	DisableClipping(false)

	draw.GlowingText("The Contractor", "ZB_PathowogenDialogueTitle", w * 0.31, 0 - ScreenScale(1), ColorAlpha(red, 255), ColorAlpha(red, 235), ColorAlpha(red, 10), TEXT_ALIGN_LEFT)

	surface.SetDrawColor(255, 255, 255, self.appearAlpha * 4)
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Think()
	if SysTime() > self.timebetween and self.textpos <= #self.textread then
		self.textpos = self.textpos + 1

		local newtext = string.sub(self.textread, 0, self.textpos)

		if self.currenttext != newtext then
			sound.PlayFile("sound/zbattle/dialogue/commander_talk2.ogg", "", function() end)
			self.currenttext = newtext
			self.text:SetText(newtext)
		end

		if string.Right(newtext, 1) == "." then
			self.timebetween = SysTime() + 1
		elseif string.Right(newtext, 1) == "," or string.Right(newtext, 1) == ":" then
			self.timebetween = SysTime() + 0.5
		else
			self.timebetween = SysTime() + 0.04
		end

		if self.CloseOnLast and self.textpos == #self.textread then
			timer.Simple(2, function()
				if IsValid(self) then
					self:Close()
				end
			end)
		end
	end
end

function PANEL:SetText(text, delay)
	self.textread = text
	self.timebetween = SysTime() + (delay or 0)

	self.textpos = 0
end

function PANEL:SetTextAutoClose(text)
	self.textread = text
	self.timebetween = SysTime() + 2

	self.textpos = 0
	self.CloseOnLast = true
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

vgui.Register("ZB_DialogueTraitor", PANEL, "EditablePanel")