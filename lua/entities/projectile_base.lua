if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "Projectile Base"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Model = ""
ENT.Sound = ""
ENT.SoundFar = ""
ENT.SoundWater = ""
ENT.Speed = 0.095
ENT.TruhstTime = 2
ENT.Oskole = true
ENT.Fragmentation = 1200
ENT.IconOverride = "vgui/inventory/weapon_rpg7"

ENT.BlastDamage = 80
ENT.BlastDis = 30


ENT.ThrustEffect = "eff_jack_rockettrust"
ENT.TrailEffect = "eff_jack_rockettrail"
ENT.ExplosionEffect = "pcf_jack_airsplode_medium"
ENT.WaterExplosionEffect = "eff_jack_genericboom"
ENT.ShrapnelEffect = "eff_jack_hmcd_shrapnel"

game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small3.pcf")
game.AddParticles("particles/pcfs_jack_explosions_incendiary2.pcf")

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(20)
			phys:Wake()
			self.snd = self:StartLoopingSound("weapons/ins2rpg7/rpg_rocket_loop.wav")
		end
		
		self:CallOnRemove("RemoveSound",function()
			if self.snd then
				self:StopLoopingSound(self.snd)
			end
		end)

		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos()+ self:GetAngles():Forward() * -75)
		Eff:SetNormal(-self:GetAngles():Forward())
		Eff:SetScale(1.5)
		util.Effect(self.ThrustEffect, Eff, true, true)

		self.Osejka = (100 == math.random(1,100))
	end

	function ENT:PhysicsCollide2(data, physobj)
	end

	function ENT:PhysicsCollide(data, physobj)
		if self:PhysicsCollide2(data, physobj) then return end
		if data.DeltaTime > .2 and data.Speed > 25 and data.HitNormal:Dot(data.OurOldVelocity:GetNormalized()) > math.cos(math.rad(30)) then
			if data.Speed > 200 and not self.Exploded then self:Detonate() end
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

	function ENT:AboutToHit2(trace)
	end

	function ENT:AboutToHit(trace)
		if self:AboutToHit2(trace) then return end
		if trace.HitSky then self:Remove() self.Removed = true return end
		if trace.Hit then self:Detonate() end
	end

    function ENT:Think()
		if self.Removed then return end
		AeroDrag(self, self:GetAngles():Forward(), .75)
		if self.Osejka then self:StopSound("weapons/ins2rpg7/rpg_rocket_loop.wav") return end
		self.Truhst = self.Truhst or CurTime() + self.TruhstTime
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(-self:GetAngles():Forward())
		Eff:SetScale(0.5)
		util.Effect(self.TrailEffect, Eff, true, true)
		if self.Truhst >= CurTime() then
        	self:GetPhysicsObject():SetVelocity( self:GetVelocity() + (self.dragvec or self:GetAngles():Forward()) * self.Speed )
        	self:NextThink(CurTime() + 0.0)
		end
		
		local tr = {}
		tr.start = self:GetPos()
		tr.endpos = tr.start + self:GetAngles():Forward() * 128
		tr.filter = self
		
		local trace = util.TraceLine(tr)

		self:AboutToHit(trace)

		return true
    end

	function ENT:Use(ply)
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

	util.AddNetworkString("projectileFarSound")
	function ENT:Detonate()
		if self.Exploded then return end
		if self.Removed then return end
		self.Exploded = true
		local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self
		self:SetMoveType(MOVETYPE_NONE)

		--; говна поел
		local offset = VectorRand() * 10
		SelfPos = SelfPos + offset

		net.Start("projectileFarSound")
			net.WriteString(self.Sound)
			net.WriteString(self.SoundFar)
			net.WriteVector(SelfPos)
			net.WriteEntity(self)
			net.WriteBool(self:WaterLevel() > 0)
			net.WriteString(self.SoundWater)
		net.Broadcast()


		local dis = self.BlastDis / 0.01905
		local disorientation_dis = (self.BlastDis * 1.5) / 0.01905  

		for i, enta in ipairs(ents.FindInSphere(SelfPos, disorientation_dis)) do
			local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {self})
			local phys = enta:GetPhysicsObject()
			
			local phys = enta:GetPhysicsObject()
			local force = (enta:GetPos() - SelfPos)
			local len = force:Length()
			force:Div(len)
			local frac = math.Clamp((disorientation_dis - len) / disorientation_dis, 0.1, 1) 
			local physics_frac = math.Clamp((dis - len) / dis, 0.5, 1)  
			local forceadd = force * physics_frac * 50000  

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and not behindwall then
					hg.ExplosionDisorientation(enta, 5 * frac, 6 * frac)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if len > dis then continue end
			if tr.Entity != enta then continue end
		end

		--[[local boom = DamageInfo()
		boom:SetDamage(self.BlastDamage)
		boom:SetDamageType(DMG_BLAST)
		boom:SetDamageForce(vector_up * 0)
		boom:SetInflictor(self)

		util.BlastDamageInfo( boom, SelfPos, self.BlastDis / 0.01905 )]]--
		util.BlastDamage(self, IsValid(self.owner) and self.owner or Owner, SelfPos, self.BlastDis / 0.01905, self.BlastDamage * 1)
		hgWreckBuildings(self, SelfPos, self.BlastDamage / 100, self.BlastDis/6, false)
		hgBlastDoors(self, SelfPos, self.BlastDamage / 100, self.BlastDis/6, false)
		
		hg.ExplosionEffect(SelfPos, self.BlastDis / 0.2, 80)

		timer.Simple(.01, function()
			if not IsValid(self) then return end
			for i = 0, 10 do
				local Tr = util.QuickTrace(SelfPos, -vector_up, {self})
				if Tr.Hit then
					util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
			if self:WaterLevel() == 0 then
				ParticleEffect(self.ExplosionEffect,SelfPos+vector_up*1,-vector_up:Angle())
			else
				local effectdata = EffectData()
				effectdata:SetOrigin(SelfPos)
				effectdata:SetScale(self.BlastDis/2.5)
				effectdata:SetNormal(-self:GetAngles():Forward())
				util.Effect(self.WaterExplosionEffect, effectdata)
			end
		end)

		
		local co 

		if not IsValid(self) then return end
		if self.Oskole then 
			local Poof=EffectData()
			Poof:SetOrigin(SelfPos)
			Poof:SetScale(1.5)
			util.Effect(self.ShrapnelEffect,Poof,true,true)
			co = coroutine.create(function()
				local LastShrapnel = SysTime()
				local vecCone = Vector(5, 5, 0)
				local forward = self:GetAngles():Forward()
				local selfowner = self.owner
				local selfFragmentation = self.Fragmentation
				for i = 1, self.Fragmentation do
						LastShrapnel = SysTime()

						local dir = VectorRand(-1,1):GetNormalized()--vector_up
						dir[3] = dir[3] > 0 and math.abs(dir[3] - 0.5) or -math.abs(dir[3] + 0.5)
						dir:Normalize()

						local Tr = util.QuickTrace(SelfPos, dir * 10000, self)
						if Tr.Hit and !Tr.HitSky and !Tr.HitWorld then
							local bullet = {}
							bullet.Src = SelfPos
							bullet.Spread = vecCone
							bullet.Force = 20
							bullet.Damage = 40
							bullet.AmmoType = "Metal Debris"
							bullet.Attacker = self.owner
							bullet.Inflictor = self
							bullet.Distance = 16756
							bullet.DisableLagComp = true
							bullet.Filter = {self}
							bullet.Dir = dir
							if not IsValid(self) then
								self = Entity(1)
							end
							--bullet.Spread = vecCone * i / self.Fragmentation
							self:FireLuaBullets(bullet, true)
						end

						LastShrapnel = SysTime() - LastShrapnel
						if LastShrapnel > 0.001 then
							coroutine.yield()
						end
				end
				self.ShrapnelDone = true
			end)
		end

        util.ScreenShake(SelfPos,100,200,1,3000)

		coroutine.resume(co)
		local index = self:EntIndex()
		timer.Create("GrenadeCheck_" .. index, 0, 0, function()
			if !IsValid(self) then
				timer.Remove("GrenadeCheck_" .. index)
			end
			coroutine.resume(co)
			if self.ShrapnelDone then
				if not IsValid(self) then return end
				self:StopSound("weapons/ins2rpg7/rpg_rocket_loop.wav")
				SafeRemoveEntity(self)
				timer.Remove("GrenadeCheck_" .. index)
			end
		end)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	
	local function PlaySndDist(snd,snd2,pos,isOnWater,watersnd)
		if SERVER then return end
		local view = render.GetViewSetup(true)
		local time = pos:Distance(view.origin) / 17836
		--print(time)
		timer.Simple(time, function()
			local owner = Entity(0)
			if not isOnWater then
				EmitSound(snd, pos, 0, CHAN_VOICE, 1, time > 0.2 and 150 or 120, 0, 100, 0, 1)
				EmitSound(snd2, pos, 0, CHAN_VOICE_BASE, 1, 140, 0, 100, 0, 1)
			else
				EmitSound(watersnd, pos, 0, CHAN_VOICE, 1, 130, 0, 85, 0, 1)
			end
		end)
	end

	net.Receive("projectileFarSound",function()
		local snd = net.ReadString() or ""
		local sndfar = net.ReadString() or ""
		local pos = net.ReadVector() or Vector(0,0,0)
		local self = net.ReadEntity()
		local onWater = net.ReadBool()
		local watersnd = net.ReadString() or ""
		--print("huy")
		PlaySndDist(sndfar,snd,pos,onWater,watersnd)
	end)
end