AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)
	self:SetUseType(SIMPLE_USE)
	local vec1, vec2 = self:GetModelBounds()
	self:PhysicsInitBox(vec1, vec2)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5)
		phys:Wake()
	end
	local Eff = EffectData()
	Eff:SetOrigin(self:GetPos()+ self:GetAngles():Up() * -75)
	Eff:SetNormal(-self:GetAngles():Up())
	Eff:SetScale(1.5)
	util.Effect("eff_jack_rockettrust", Eff, true, true)

	self.Osejka = (100 == math.random(1,100))
end

function ENT:PhysicsCollide(data, physobj)
	if data.DeltaTime > .2 and data.Speed > 25 then
		if data.Speed > (self.Activated and 200 or 2200) and not self.Exploded then self:Detonate() end
	end
end

function AeroDrag(ent, forward, mult, spdReq)
	if constraint.HasConstraints(ent) then return end
	if ent:IsPlayerHolding() then return end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return end
	local Vel = Phys:GetVelocity()
	local Spd = Vel:Length()

	if not spdReq then
		spdReq = 300
	end

	if Spd < spdReq then return end
	mult = mult or 1
	local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
	Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * Mass / 1000)
end


function ENT:Think()
	AeroDrag(self, self:GetAngles():Up(), .75)
	if not self.Activated then return end
	if self.Osejka then self:StopLoopingSound(self.LoopSndID ) return end
	self.Truhst = self.Truhst or CurTime() + self.TruhstTime
	if not self.EffectTrail then
		self.EffectTrail = true
		ParticleEffectAttach(self.RocketTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
	end
	if self.Truhst < CurTime() then self:Detonate() return end
	self:GetPhysicsObject():ApplyForceCenter( self:GetAngles():Up() * self.Speed )
	self:NextThink(CurTime() + 0.1)
end

function ENT:Use(ply)
	local wep = ply:GetActiveWeapon()
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

function ENT:OnRemove()
	self:StopLoopingSound(self.LoopSndID)
end
util.AddNetworkString("projectileFarSound")
function ENT:Detonate()
	if self.Exploded then return end
	self.Exploded = true
	local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self

	net.Start("projectileFarSound")
		net.WriteString(self.Sound)
		net.WriteString(self.SoundFar)
		net.WriteVector(SelfPos)
		net.WriteEntity(self)
		net.WriteBool(self:WaterLevel() > 0)
		net.WriteString(self.SoundWater)
	net.Broadcast()

	--[[local boom = DamageInfo()
	boom:SetDamage(self.BlastDamage)
	boom:SetDamageType(DMG_BLAST)
	boom:SetDamageForce(vector_up * 0)
	boom:SetInflictor(self)

	util.BlastDamageInfo( boom, SelfPos, self.BlastDis / 0.01905 )]]--
	util.BlastDamage(self, Owner, SelfPos, self.BlastDis / 0.01905, self.BlastDamage * 1)
	hgWreckBuildings(self, SelfPos, self.BlastDamage / 100, self.BlastDis/6, false)
	hgBlastDoors(self, SelfPos, self.BlastDamage / 100, self.BlastDis/6, false)
	if self:WaterLevel() == 0 then
		ParticleEffect("gf2_rocket_large_explosion_01",self:GetPos(),-vector_up:Angle())
	else
		local effectdata = EffectData()
		effectdata:SetOrigin(SelfPos)
		effectdata:SetScale(self.BlastDis/2.5)
		effectdata:SetNormal(-self:GetAngles():Forward())
		util.Effect("eff_jack_genericboom", effectdata)
	end
	
	hg.ExplosionEffect(SelfPos, self.BlastDis / 0.2, 80)

	timer.Simple(.01, function()
		if not IsValid(self) then return end
		for i = 0, 10 do
			local Tr = util.QuickTrace(SelfPos, -vector_up, {self})
			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end
	end)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		if self.Oskole then 
			local vecCone = Vector(5, 5, 0)
			
			for i = 1, self.Fragmentation do
				local bullet = {}
				bullet.Src = SelfPos
				bullet.Spread = vecCone
				bullet.Force = 0.01
				bullet.Damage = self.BlastDamage
				bullet.AmmoType = "Metal Debris"
				bullet.Attacker = Owner
				bullet.Distance = 205
				bullet.DisableLagComp = true
				bullet.Filter = {}
				bullet.Dir = self:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / self.Fragmentation)
				self:FireLuaBullets(bullet, true)
			end
		end
		util.ScreenShake(SelfPos,100,200,1,1000)
	end)

	timer.Simple(.06, function()
		if not IsValid(self) then return end
		self:Remove()
	end)
end