AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/kali/weapons/black_ops/magazines/30rd galil magazine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(USE_TOGGLE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetBodygroup(1, 1)
	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .2 and data.Speed > 120 then self:Detonate(data) end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	if ply:HasWeapon("weapon_hg_emptymag") then
		ply:PickupObject(self)
	else
		ply:Give("weapon_hg_emptymag")
		self:Remove()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	local Dmg = dmginfo:GetDamage()
	if Dmg >= 1 then
		self:Detonate()
	end
end

function ENT:Think()
end

function ENT:Detonate(data)
	local SelfPos = self:LocalToWorld(self:OBBCenter())
	timer.Simple(.02, function()
		if not IsValid(self) then return end
		sound.Play("physics/metal/weapon_impact_hard" .. math.random(3) .. ".wav", SelfPos, 85)
	end)

	--SafeRemoveEntityDelayed(self, 320) 
end