AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spoon"
ENT.Spawnable = false
ENT.Model = ""

ENT.PhysicsSounds = true

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:DrawShadow(true)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(1)
		phys:Wake()
		phys:EnableMotion(true)
        phys:AddAngleVelocity(VectorRand(-50,50))
	end
end

function ENT:OnRemove()

end

function ENT:Draw()
    self:DrawModel()
end
