include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>Grenade\n<colour=200,0,0>RUN IDIOT!</colour></font>",450)
end