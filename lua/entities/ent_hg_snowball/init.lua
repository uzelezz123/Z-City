AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/zerochain/props_christmas/snowballswep/zck_w_snowballswep.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(USE_TOGGLE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(2) -- Убить человека снежком..
		phys:Wake()
	end
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .2 and data.Speed > 120 then self:Detonate(data) end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	ply:PickupObject(self)
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	local Dmg = dmginfo:GetDamage()
	if Dmg >= 1 then
		self:Detonate()
	end
end

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Detonate()
	end
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Detonate(data)
	local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self:GetOwner() or self
	timer.Simple(.01, function()
		if not IsValid(self) then return end
		for i = 0, 1 do
			if data then
				local effData = EffectData()
				effData:SetOrigin(SelfPos)
				effData:SetScale(math.Rand(0.85, 1.25))
				util.Effect("eff_jack_hmcd_poof", effData)
				util.Decal("Splash.Large", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
			end
		end
		for k, ent in ipairs(ents.FindInSphere(self:GetPos(),5)) do
			if ent:GetClass() == "vfire" then
				ent.life = (ent.life or 0 ) - 5
				if ent.life < 2 then
					ent:Remove()
				end
			end
		end
	end)

	hg.EmitAISound(SelfPos, 256, 8, 128)

	timer.Simple(.02, function()
		if not IsValid(self) then return end
		sound.Play("weapons/snowball/snowball_impact0"..math.random(1, 2)..".wav", SelfPos, 80, math.random(95, 105))
	end)

	timer.Simple(.06, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end