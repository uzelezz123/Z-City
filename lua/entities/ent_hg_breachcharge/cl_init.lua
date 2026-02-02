include("shared.lua")

local redglow, trans = Material("sprites/redglow1"), Material("models/hands/hands_color")

function ENT:Initialize()
	self.NextTime = 3
	self.material = trans
	self.Amount = 0

	timer.Simple(3, function()
		self.Allowed = true
	end)
end

local white = Color(255,255,255,255)
function ENT:Draw()
	local Mat = Matrix()
	Mat:Scale(Vector(.42, .42, .42))
	self:EnableMatrix("RenderMultiply", Mat)
	self:DrawModel()
	if not self.Allowed then return end
	local pos, ang = self:GetPos(), self:GetAngles()

	if self.NextBeep < CurTime() then
		self.material = redglow
		self.Amount = self.Amount + 1
		self.NextBeep = CurTime() + self.NextTime

		if self.Amount >= 3 then
			self.NextTime = 0.2
		end

		timer.Simple(.1, function()
			self.material = trans
		end)
	end

	cam.Start3D()
	render.SetMaterial(self.material)
	render.DrawSprite(pos + ang:Up() * 5.3 + ang:Right() * 0, 10, 10, white)
	cam.End3D()
end