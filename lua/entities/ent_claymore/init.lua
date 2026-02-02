AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BlastDis = 680
ENT.BlastDamage = 100
ENT.ShrapnelDis = 500
ENT.ShrapnelDamage = 65
ENT.ConcussionDis = 1365
ENT.ConcussionDamage = 30

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(ONOFF_USE)
	self:DrawShadow(true)
	self.MotionTriggerIsActivated = false
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false) 
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.CanBeKnockedOver and data.Speed > 80 then
		phys:EnableMotion(true)
		phys:Wake()

		local force = data.Speed * 0.2
		phys:ApplyForceOffset(data.HitNormal * force * 10, data.HitPos)
	end
end

function ENT:Use(activator)
	if not self.MotionTriggerIsActivated then
		self.MotionTriggerIsActivated = true
		self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1,7) .. ".wav",55,100,1)
		if IsValid(activator) and activator:IsPlayer() then
			activator:ViewPunch(Angle(2,0,0))
		end
	end
end

local vec_huy = Vector(0,0,0)
function ENT:ActivateExplosive()
	if self.Exploded then return end
	self.Exploded = true
	local selfPos = self:GetPos()
	local pos, ang = LocalToWorld(self.offsetPos, self.offsetAng, self:GetPos(), self:GetAngles())
	local num = 700

	local bullet = {}
	bullet.Force = 2
	bullet.Damage = 10
	bullet.AmmoType = "Metal Debris"
	bullet.Attacker = self.owner
	bullet.Distance = 56756
	bullet.Callback = hg.bulletHit
	bullet.IgnoreEntity = self
	bullet.Tracer = 10000
	bullet.DisableLagComp = true
	bullet.Filter = {self}

	local co = coroutine.create(function()
		local LastShrapnel = SysTime()

		for i = 1, num do
			LastShrapnel = SysTime()

			local dir = (ang + Angle(math.Rand(-12, 2), math.Rand(-30, 30), 0)):Forward()
			dir:Normalize()

			local tr = util.TraceLine({
				start = pos,
				endpos = pos + dir * bullet.Distance,
				filter = bullet.Filter,
				mask = MASK_SHOT
			})
			if i > 100 and tr.Entity == game.GetWorld() then util.Decal("ExplosiveGunshot",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal) continue end

			bullet.Src = pos
			bullet.Dir = dir
			bullet.Penetration = math.Clamp(num / i, 5, 10) * 10
			if not IsValid(self) then return end
			self:FireLuaBullets(bullet,true)

			LastShrapnel = SysTime() - LastShrapnel

			if LastShrapnel > 0.001 then
				coroutine.yield()
			end
		end

		self.ShrapnelDone = true
	end)

	coroutine.resume(co)

	local index = self:EntIndex()

	timer.Create("GrenadeCheck_" .. index, 0, 0, function()
		if !IsValid(self) then
			timer.Remove("GrenadeCheck_" .. index)
		end

		coroutine.resume(co)

		if self.ShrapnelDone then
			util.ScreenShake(selfPos, 20, 20, 1, self.ConcussionDis)
			SafeRemoveEntity(self)
			timer.Remove("GrenadeCheck_" .. index)
		end
	end)

	net.Start("projectileFarSound")
		net.WriteString(table.Random(self.Sound))
		net.WriteString(table.Random(self.SoundFar))
		net.WriteVector(selfPos)
		net.WriteEntity(self)
		net.WriteBool(self:WaterLevel() > 0)
		net.WriteString(self.SoundWater)
	net.Broadcast()
	local normal = self:GetAngles():Right()
	local blastdist = self.BlastDis
	timer.Simple(0.3,function()
		ParticleEffect("pcf_jack_groundsplode_medium",selfPos+vector_up*1,-normal:Angle())
		--hg.ExplosionEffect(selfPos, blastdist, 80)
	end)

	local attacker = IsValid(self.owner) and self.owner or Entity(0)
	
	for _, ply in ipairs(ents.FindInSphere(selfPos,self.ConcussionDis)) do
		if not ply:IsPlayer() then continue end
		local tr = hg.ExplosionTrace(selfPos,ply:GetPos(),{self})
		if tr.Entity != ply then continue end
		local dist = ply:GetPos():Distance(selfPos)
		local tinnitusDuration = math.Clamp(10 * (1 - dist/self.ConcussionDis), 2, 10)
		ply:AddTinnitus(math.max(tinnitusDuration,1.5), true)
	end
	   
	--util.BlastDamage(self, attacker, selfPos, self.ShrapnelDis, self.BlastDamage)
	util.BlastDamage(self, attacker, selfPos, self.BlastDis, self.ShrapnelDamage)
	--util.BlastDamage(self, attacker, selfPos, self.ConcussionDis, self.ConcussionDamage)
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() == self then return end
	if dmginfo:IsDamageType(DMG_BLAST + DMG_BULLET + DMG_BUCKSHOT + DMG_BURN) then
		self:ActivateExplosive()
	end
end