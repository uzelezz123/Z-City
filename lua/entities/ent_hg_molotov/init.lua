AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_molotov.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(USE_TOGGLE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.1,function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
	end
	self.sndid = self:StartLoopingSound("ambient/fire/fire_small_loop1.wav")
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .2 and data.Speed > 25 then
		
		self.Velocity = data.OurOldVelocity
		if data.Speed > 200 and not self.Exploded then 
			self:Detonate()
			self:EmitSound("weapons/molotov/molotov_detonate.wav")
		end
	end
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	ply:PickupObject(self)
end

function ENT:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	self:TakePhysicsDamage(dmginfo)
	local Dmg = dmginfo:GetDamage()
	if Dmg >= 1 and dmginfo:IsDamageType(DMG_BURN) then
		timer.Simple(2, function()
			if not IsValid(self) then return end
			self:Detonate()
		end)
	end
end

function ENT:Think()
	if self:GetPhysicsObject():GetVelocity():Length() < 50 or self:WaterLevel() > 0 and not self.Exploded then
		local ent = ents.Create("weapon_hg_molotov_tpik")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetVelocity(self:GetPhysicsObject():GetVelocity())
		ent.init = true
		ent:Spawn()
		
		self.Exploded = true
		self:Remove()
	end
	--self:NextThink(CurTime() + 1)
	--return true
end

function ENT:OnRemove()
	self:StopLoopingSound(self.sndid or 0)
end

function ENT:Detonate()
	if self.Exploded then return end
	self.Exploded = true
	local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self:GetOwner() or self
	--local Boom = ents.Create("env_explosion")
	--Boom:SetPos(SelfPos)
	--Boom:SetKeyValue("imagnitude", "50")
	--Boom:SetOwner(Owner)
	--Boom:Spawn()
	--Boom:Fire("explode", 0)
	timer.Simple(.01, function()
		if not IsValid(self) then return end
		for i = 0, 25 do
			local Tr = util.QuickTrace(SelfPos + vector_up * 25,(vector_up * - 100) + VectorRand() * (i*3) , {self})
			if Tr.Hit then
				--util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				--util.Decal("BeerSplash", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				if Tr.Entity:IsPlayer() then Tr.Entity:Ignite() end
				--local fire = CreateVFire(Tr.Entity, Tr.HitPos, Tr.HitNormal, 7, self)
				CreateVFireBall(30, 12, Tr.HitPos + vector_up * 4, self.Velocity / 5 - vector_up * 10 + VectorRand() * 150,self.owner or self)
			else
				CreateVFireBall(25, 7, SelfPos + vector_up * 12, self.Velocity/2+ VectorRand() * 250,self.owner or self)
			end
		end
	end)
	
	hg.EmitAISound(SelfPos, 512, 16, 8)

	--ParticleEffect("pcf_jack_incendiary_ground_sm2",SelfPos,vector_up:Angle())

	timer.Simple(.05, function()
		if not IsValid(self) then return end
		sound.Play("snd_jack_firebomb.wav", SelfPos, 80, 100)
	end)

	--for i = 1, 2 do
	--local FireVec = (self:GetVelocity() / 500 + VectorRand() * .6 + Vector(0, 0, .6)):GetNormalized()
	--FireVec.z = FireVec.z / 2
	--local Flame = ents.Create("ent_hg_firesmall")
	--Flame:SetPos(SelfPos + Vector(0, 0, 10))
	--Flame:SetAngles(FireVec:Angle())
	--Flame:SetOwner(IsValid(self.Initiator) and self.Initiator or self or game.GetWorld())
	--Flame:Spawn()
	--Flame:Activate()
	--end
	timer.Simple(.06, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end