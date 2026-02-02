AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Exploded = false
function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(USE_TOGGLE)
	self:DrawShadow(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(5)
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	ply:PickupObject(self)
end

function ENT:Think()
	if CLIENT then return end
	self:NextThink(CurTime())
	if not self.Exploded then self:Explode() end
	return true
end

function ENT:DoParticle()
	if not IsValid(self) then return end

	local pos = self:GetPos()
	self.Burn = (self.Burn or 0) + 1
	if self.Burn == 24 then self:StopLoopingSound(self.snd or 0) end
	ParticleEffect("pcf_jack_smokebomb3", pos, -vector_up:Angle())
end

function ENT:Explode()
	self.Exploded = true
	self.snd = self:StartLoopingSound("Weapon_FlareGun.Burn")
	--self:DoParticle()
	timer.Create("smokenade" .. self:EntIndex(), 1, 25, function()
		if IsValid(self) then
			self:DoParticle()
		end
	end)
end