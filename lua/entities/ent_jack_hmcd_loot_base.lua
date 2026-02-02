-- backward compatibility
if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Loot"
ENT.IsLoot = true
if SERVER then
	ENT.ImpactSound = "Drywall.ImpactHard"
	function ENT:Initialize()
		self:SetModel(self.Model or "")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:DrawShadow(false)
		SafeRemoveEntityDelayed(self, 1)
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	function ENT:Draw()
	end
end

function ENT:Think()
end