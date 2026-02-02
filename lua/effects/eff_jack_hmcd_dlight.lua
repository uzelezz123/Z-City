function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	local Pos = self.Position
	self.smokeparticles = {}
	local spawnpos = Pos
	local scale = data:GetScale()
	self.scale = scale
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = Pos
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 1 * scale
		dlight.Size = 600 * scale
		dlight.Decay = 5000
		dlight.DieTime = CurTime() + .5
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end