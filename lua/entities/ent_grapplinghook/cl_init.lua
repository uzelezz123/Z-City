include("shared.lua")
ENT.Model = "models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl"

local clr = Color(10, 10, 10, 255)
function ENT:Draw()
	if not self.RModel or not IsValid(self.RModel) then
		self.RModel = ClientsideModel(self.Model)
		self.RModel:SetNoDraw(true)
		self.RModel:SetMaterial("models/shiny")
		self.RModel:SetColor(clr)
		self.RModel:SetParent(self)
		self:CallOnRemove("Remove_CLMDL", function() self.RModel:Remove() end)
	end

	--print(self.RModel)
	local Vel, Ang = self:GetVelocity(), self:GetAngles()
	if Vel:Length() > 100 then
		Ang = Vel:Angle()
		if self:GetNWBool("Impacted") then
			Ang:RotateAroundAxis(Ang:Right(), 90)
		else
			Ang:RotateAroundAxis(Ang:Right(), -90)
		end
	end

	self.RModel:SetRenderAngles(Ang)
	self.RModel:SetRenderOrigin(self:GetPos())
	self.RModel:DrawModel()
end