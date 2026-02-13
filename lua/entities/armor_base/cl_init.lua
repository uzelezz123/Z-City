include("shared.lua")
ENT.HowToUseInstructions = "<font=ZCity_Tiny>"..string.upper( (input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD") ).." to wear</font>"

function ENT:Draw()
	if not self.PhysModel then
		self:DrawModel()
		return
	end

	local model = self.model
	local pos, ang = LocalToWorld(self.PhysPos, self.PhysAng, self:GetPos(), self:GetAngles())
	model:SetRenderOrigin(pos)
	model:SetRenderAngles(ang)
	model:DrawModel()
end

function ENT:Think()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. self.PrintName .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. self.HowToUseInstructions .."</colour></font>",450)
	self.model = ClientsideModel(self.Model, RENDERGROUP_OPAQUE)
	if !IsValid(self.model) then return end
	self.model:SetNoDraw(true)
end

function ENT:OnRemove()
	if IsValid(self.model) then
		self.model:Remove()
		self.model = nil
	end
end

hook.Add("RagdollPerdiction","TransferMats",function(ragdoll, ply)
	local armors = ragdoll.PredictedArmor
	for k,v in pairs(armors) do
		ragdoll:SetNWString("ArmorMaterials" .. v, ply:GetNWString("ArmorMaterials" .. v))
		ragdoll:SetNWInt("ArmorSkins" .. v, ply:GetNWInt("ArmorSkins" .. v))
	end
end)