include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>Claymore\n<colour=150,150,150>E - Enable motion trigger</colour></font>",450)
end