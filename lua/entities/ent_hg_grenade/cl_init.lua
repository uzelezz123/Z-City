include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>A Grenade\n<colour=150,150,150>Was it really a good idea to be this close?</colour></font>",450)
end