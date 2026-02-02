local PANEL = {}

function PANEL:Init()
	if IsValid(zb.FurBriefing) then
		zb.FurBriefing:Remove()
	end

	zb.FurBriefing = self
	self.alpha = 255

	self:SetSize(ScrW(), ScrH())

	self.dialogue = self:Add("ZB_DialogueFur")
	self.dialogue:SetPos(ScrW() / 2 - self.dialogue:GetWide() / 2, ScrH() / 2 - self.dialogue:GetTall() / 2)

	self.dialogue:SetText("Meow meow meow meow meow, meow meow meow, meow meow meow meow meow meow, meow meow meow meow. OwO. Meow meow meow meow. Meow meow, meow meow meow.", 2)
	timer.Simple(15, function()
		if !IsValid(self) then return end
		self.dialogue:SetText("Meow. :3")

		self:SetKeyboardInputEnabled(false)

		self:CreateAnimation(1, {
			index = 1,
			target = {
				alpha = 0
			},
			easing = "linear",
			bIgnoreConfig = true,
		})

		self.dialogue:CreateAnimation(1, {
			index = 1,
			target = {
				x = ScrW() * 0.07,
				y = ScrH() * 0.07
			},
			easing = "outQuint",
			bIgnoreConfig = true,
			Think = function()
				self.dialogue:SetPos(self.dialogue.x, self.dialogue.y)
			end
		})

		timer.Simple(3, function()
			if !IsValid(self) then return end
			self.dialogue:Close()
			timer.Simple(1, function()
				if !IsValid(self) then return end
				self:Remove()
			end)
		end)
	end)

	self:RequestFocus()
	self:MakePopup()

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(false)

	sound.PlayFile("sound/zbattle/briefing_fur.ogg", "", function() end)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, self.alpha)
	surface.DrawRect(0, 0, w, h)

	-- RunConsoleCommand("soundfade", "100", "999")
end

vgui.Register("ZB_FurFurBriefing", PANEL, "EditablePanel")