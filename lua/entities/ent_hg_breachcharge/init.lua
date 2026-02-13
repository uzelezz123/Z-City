AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self.NextTime = 3
	self.TickAmount = 0
	self.Allowed = false

	timer.Simple(3, function()
		self.Allowed = true
	end)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(5)
	end
end

function ENT:Think()
	if self.NextBeep < CurTime() and self.Allowed then
		self.NextBeep = CurTime() + self.NextTime
		self:EmitSound("npc/turret_floor/ping.wav")
		self.TickAmount = self.TickAmount + 1

		if self.TickAmount >= 3 then
			self.NextTime = 0.2
		end

		if self.TickAmount == 7 then
			self:Detonate()
		end
	end

	self:NextThink(CurTime() + .01)

	return true
end

function ENT:NearGround()
	return util.QuickTrace(self:GetPos() + vector_up * 10, -vector_up * 50, {self}).Hit
end

function ENT:Detonate()
	if self.Detonated then return end
	self.Detonated = true
	local Pos, Ground, Attacker = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 5), self:NearGround(), self:GetOwner()

	if Ground then
		ParticleEffect("pcf_jack_groundsplode_small3", Pos, vector_up:Angle())
	else
		ParticleEffect("pcf_jack_airsplode_small3", Pos, VectorRand():Angle())
	end
	util.ScreenShake( selfPos, 35, 200, 3, 1000 )
	local Foom = EffectData()
	Foom:SetOrigin(Pos)

	for key, ent in pairs(ents.FindInSphere(Pos, 75)) do
		if (ent ~= self) and (ent:GetClass() == "func_breakable") then
			ent:Fire("break", "", 0)
		elseif (ent ~= self) and (ent:GetClass() == "func_physbox") then
			constraint.RemoveAll(ent)
		elseif (ent ~= self) and hgIsDoor(ent) and not ent:GetNoDraw() then
			hgBlastThatDoor(ent, (ent:GetPos() - self:GetPos()):GetNormalized() * 750)
		end
	end

	util.Effect("explosion", Foom, true, true)
	local Flash = EffectData()
	Flash:SetOrigin(Pos)
	Flash:SetScale(2)
	util.Effect("eff_jack_hmcd_dlight", Flash, true, true)

	timer.Simple(.01, function()
		if not IsValid(self) then return end
		self:EmitSound("snd_jack_hmcd_explosion_debris.mp3", 85, math.random(90, 110))
		self:EmitSound("m67/m67_detonate_far_dist_0" .. math.random(1, 3) .. ".wav", 140, 100)
		self:EmitSound("snd_jack_hmcd_debris.mp3", 85, math.random(90, 110))

		for i = 0, 10 do
			local Tr = util.QuickTrace(Pos, VectorRand() * math.random(10, 150), {self})

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end
	end)

	timer.Simple(.02, function()
		if not IsValid(self) then return end
		self:EmitSound("m67/m67_detonate_0" .. math.random(1, 3) .. ".wav", 80, 100)
		self:EmitSound("m67/m67_detonate_0" .. math.random(1, 3) .. ".wav", 80, 100)
	end)

	timer.Simple(.04, function()
		if not IsValid(self) then return end
		local shake = ents.Create("env_shake")
		shake:SetPos(Pos)
		shake:SetKeyValue("amplitude", tostring(100))
		shake:SetKeyValue("radius", tostring(200))
		shake:SetKeyValue("duration", tostring(1))
		shake:SetKeyValue("frequency", tostring(200))
		shake:SetKeyValue("spawnflags", bit.bor(4, 8, 16))
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)
		SafeRemoveEntityDelayed(shake, 2) -- don't clutter up the world
		local shake2 = ents.Create("env_shake")
		shake2:SetPos(Pos)
		shake2:SetKeyValue("amplitude", tostring(100))
		shake2:SetKeyValue("radius", tostring(400))
		shake2:SetKeyValue("duration", tostring(1))
		shake2:SetKeyValue("frequency", tostring(200))
		shake2:SetKeyValue("spawnflags", bit.bor(4))
		shake2:Spawn()
		shake2:Activate()
		shake2:Fire("StartShake", "", 0)
		SafeRemoveEntityDelayed(shake2, 2) -- don't clutter up the world
		util.BlastDamage(self, Attacker, Pos, 150, 50)
	end)

	timer.Simple(.05, function()
		if not IsValid(self) then return end
		local Shrap = DamageInfo()
		Shrap:SetAttacker(Attacker)

		if IsValid(self) then
			Shrap:SetInflictor(self)
		else
			Shrap:SetInflictor(game.GetWorld())
		end

		Shrap:SetDamageType(DMG_BUCKSHOT)
		Shrap:SetDamage(55)
		util.BlastDamageInfo(Shrap, Pos, 600)
		SafeRemoveEntity(self)
	end)

	timer.Simple(.1, function()
		if not IsValid(self) then return end
		for key, rag in pairs(ents.FindInSphere(Pos, 750)) do
			if (rag:GetClass() == "prop_ragdoll") or rag:IsPlayer() then
				for i = 1, 20 do
					local Tr = util.TraceLine({
						start = Pos,
						endpos = rag:GetPos() + VectorRand() * 50
					})

					if Tr.Hit and (Tr.Entity == rag) then
						util.Decal("Blood", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end
			end
		end
	end)
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:StartTouch(ply)
end