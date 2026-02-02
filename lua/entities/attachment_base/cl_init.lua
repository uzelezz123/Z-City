include("shared.lua")
function ENT:Draw()
	if not self.PhysModel then
		self:DrawModel()
		return
	end

	local model = self.model

	if not IsValid(self.model) then
		self.model = ClientsideModel(self.Model, RENDERGROUP_OPAQUE)
	end

	local pos, ang = LocalToWorld(self.PhysPos, self.PhysAng, self:GetPos(), self:GetAngles())
	model:SetRenderOrigin(pos)
	model:SetRenderAngles(ang)
	model:DrawModel()
end

function ENT:Think()
end

function ENT:Initialize()
	self.model = ClientsideModel(self.Model, RENDERGROUP_OPAQUE)
	if IsValid(self.model) then
		self.model:SetNoDraw(true)
	end
end

function ENT:OnRemove()
	if IsValid(self.model) then
		self.model:Remove()
		self.model = nil
	end
end