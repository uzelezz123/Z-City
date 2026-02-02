AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:SetModelScale(self.ModelScale or 0.4)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableMotion(true)
	end
end

function ENT:Use(ply)
	self:UnBlock()
	ply:Give("weapon_hg_jam")
	ply:SelectWeapon("weapon_hg_jam")
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() == self then return end
	if dmginfo:IsDamageType(DMG_BLAST + DMG_BULLET + DMG_BUCKSHOT + DMG_BURN) and math.random(1, 5) == 1 then
		self:UnBlock()
		self:EmitSound("Wood_Plank.ImpactHard")
	end
end

function ENT:Think()
	if self.Blocking then
		for key, door in pairs(self.Doors) do
			if not IsValid(door) then
				self:UnBlock()
				break
			end

			door:Fire("lock", "", 0)
		end

		if not IsValid(self.Constraint) then
			self:UnBlock()
			self:EmitSound("Wood_Plank.ImpactSoft")
		end
	end

	self:NextThink(CurTime() + .1)
	return true
end

function ENT:UnBlock()
	if self.Blocking then
		self.Blocking = false
		for key, door in pairs(self.Doors) do
			if IsValid(door) and not self.DoorLocked then door:Fire("unlock", "", 0) end
		end

		self.Doors = {}
		self:EmitSound("Wood_Plank.ImpactSoft")
		self:EmitSound("Flesh.ImpactSoft")
		constraint.RemoveAll(self)
	end
end

function ENT:Block(doors)
	if not self.Blocking then
		self.Blocking = true
		self.Doors = doors
		self.Constraint = constraint.Weld(self.Doors[1], self, 0, 0, 3000, true, false)
		self.Constraint.PickupAble = true
		self:EmitSound("Wood_Plank.ImpactSoft")
		self:EmitSound("Flesh.ImpactSoft")
		self:EmitSound("Wood_Plank.ImpactSoft")
		self:Think()
	end
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .1 then
		self:EmitSound("Wood_Plank.ImpactSoft")
		self:EmitSound("Flesh.ImpactSoft")
	end
end