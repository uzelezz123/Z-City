--
if SERVER then
	AddCSLuaFile("effects/eff_hg_co2_leak.lua")
end
util.AddNetworkString("hg_booom")
util.AddNetworkString("hg_gastank_leak")
util.AddNetworkString("hg_gastank_stop")
hg = hg or {}

hg.GasTank = hg.GasTank or {}
hg.GasTank.ActiveTanks = hg.GasTank.ActiveTanks or {}
local RNG = math.random

function hg.FindOtherExplosive(inflictor,pos,radius)

end

function hg.MakeCombinedExplosion()

end

local DebrisSounds = {
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave01.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave010.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave02.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave03.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave04.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave05.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave06.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave07.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave09.wav"
}

local ExplosionExtraSounds = {
	"explosionextra/explode_1.wav",
	"explosionextra/explode_2.wav",
	"explosionextra/explode_3.wav",
	"explosionextra/explode_4.wav",
	"explosionextra/explode_5.wav",
	"explosionextra/explode_6.wav",
	"explosionextra/explode_7.wav",
	"explosionextra/explode_8.wav",
	"explosionextra/explode_9.wav"
}

local GasTankModels = {
	["models/props_c17/canister01a.mdl"] = true,
	["models/props_c17/canister02a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
	["models/props_c17/canister_propane01a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
}

local GasTankPushForce = {
	Default = 100,
	["models/props_c17/canister01a.mdl"] = 125,
	["models/props_c17/canister02a.mdl"] = 125,
	["models/props_junk/PropaneCanister001a.mdl"] = 120,
	["models/props_c17/canister_propane01a.mdl"] = 135,
	["models/props_junk/propane_tank001a.mdl"] = 145
}

local GasTankSmokeSettings = {
	NextTick = 0.35,
	Magnitude = 1.4,
	DrainPerTick = 1.4
}

function hg.PlayExtraExplosionSound(pos, entIndex, volume)
	if not pos then return end
	local snd = ExplosionExtraSounds[math.random(#ExplosionExtraSounds)]
	local idx = entIndex or 0
	local vol = volume or 1
	EmitSound(snd, pos, idx + 400, CHAN_ITEM, vol, 145, 0, math.random(95, 105))

	timer.Simple(0.04, function()
		EmitSound(snd, pos, idx + 401, CHAN_AUTO, vol * 0.7, 135, 0, math.random(90, 100))
	end)
end

local function RegisterGasTank(ent)
	if not IsValid(ent) then return end
	if not GasTankModels[ent:GetModel()] then return end
	local idx = ent:EntIndex()
	if hg.GasTank.ActiveTanks[idx] then return end
	hg.GasTank.ActiveTanks[idx] = {
		Ent = ent,
		IsActive = false,
		Leaks = {}
	}
end

local function IsLeakingTankOnFire(ent)
	if not IsValid(ent) then return false end
	if ent:IsOnFire() then return true end
	return istable(ent.fires) and next(ent.fires) != nil
end

local function ResolveGasTankLeak(target, dmginfo)
	local dmgPos = dmginfo:GetDamagePosition()
	if dmginfo:IsDamageType(DMG_BLAST) then
		dmgPos = target:NearestPoint(dmgPos)
	end
	local holePos = target:NearestPoint(dmgPos)
	local center = target:WorldSpaceCenter()
	local outward = holePos - center
	if outward:LengthSqr() < 0.001 then
		outward = target:GetForward()
	end
	outward:Normalize()
	local localHole = target:WorldToLocal(holePos)
	local localNormal = target:WorldToLocal(holePos + outward) - localHole
	if localNormal:LengthSqr() < 0.001 then
		localNormal = Vector(1, 0, 0)
	else
		localNormal:Normalize()
	end
	return localHole, localNormal
end

function hg.GasTankDetonate(ent)
	if not IsValid(ent) or ent.IsExploding then return end
	ent.IsExploding = true
	local idx = ent:EntIndex()
	local data = hg.GasTank.ActiveTanks[idx]
	local baseGas = (data and data.BaseGasAmount) or (ent.Volume or 75)
	local curGas = (data and data.GasAmount) or baseGas
	local ratio = math.Clamp(curGas / baseGas, 0.1, 1)

	net.Start("hg_gastank_stop")
	net.WriteUInt(idx, 16)
	net.Broadcast()

	hg.GasTank.ActiveTanks[idx] = nil

	local phys = ent:GetPhysicsObject()
	local mass = IsValid(phys) and phys:GetMass() or 30
	local baseVol = baseGas
	hg.PropExplosion(ent, "CustomBarrel", baseVol * 2 * ratio, mass)
end

local hg, util, ParticleEffect, IsValid, timer, coroutine, Vector = hg, util, ParticleEffect, IsValid, timer, coroutine, Vector

local vecCone = Vector(5, 5, 0)
local function safeExplosionDir(fromPos, toPos)
	local force = (toPos - fromPos)
	local len = force:Length()
	if len < 0.001 then return nil end
	force:Div(len)
	return force, len
end

local ExpTypes = {
    Fire = function(Ent, Force, Mass)
		local multi = math.min(Mass / 10,20)
		Force = Force * multi
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
		hg.PlayExtraExplosionSound(SelfPos, Ent:EntIndex(), 1)
		local rad = (Force / 8)
        util.BlastDamage(Ent, Owner, SelfPos, rad / 0.01905, Force * 2)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50, Force / 15)
		--ParticleEffect("pcf_jack_incendiary_ground_sm2",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Fire")
        net.Broadcast()

		if not IsValid(Ent) then return end
		local multi = math.min(Mass / 5, 20)
		
		local Tr = util.QuickTrace(SelfPos, -vector_up*500, {Ent})
		local fire = CreateVFire(game.GetWorld(), Tr.HitPos, Tr.HitNormal, 150 / 7 * multi, Ent)
		if IsValid(fire) then
			fire:ChangeLife(150)
		end
		for i = 1, multi / 2 do
			local randvec = VectorRand(-1000,1000)--VectorRand(-1,1) * math.random(1000)
			randvec[3] = math.random(100,1000)
			CreateVFireBall(20, 50, SelfPos + vector_up * 10, randvec)
		end

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			if enta == Ent then continue end
			local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			
			local force, len = safeExplosionDir(SelfPos, enta:GetPos())
			if not force then continue end
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() then
					hg.ExplosionDisorientation(enta, 5 * frac / (behindwall and 3 or 1), 6 * frac / (behindwall and 3 or 1))
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end

			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {Ent}
		table.Add(bullet.Filter, hg.drums2)
		local multi = math.min(Mass/5,20)

		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*3 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

        util.ScreenShake(SelfPos,100,900,1,5000)

        coroutine.resume(co)

		local index = Ent:EntIndex()

		timer.Create("GrenadeCheck_" .. index, 0, 0, function()
			if !IsValid(Ent) then
				timer.Remove("GrenadeCheck_" .. index)
			end
			coroutine.resume(co)
			if Ent.ShrapnelDone then
				if not IsValid(Ent) then return end
				SafeRemoveEntity(Ent)
				timer.Remove("GrenadeCheck_" .. index)
			end
		end)
    end,

    Sharpnel = function(Ent,Force,Mass)
		local rad = (Force / 8)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
		hg.PlayExtraExplosionSound(SelfPos, Ent:EntIndex(), 1)
        util.BlastDamage(Ent, Owner, SelfPos, (Force/7.5) / 0.01905, Force * 1)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50)

        --ParticleEffect("pcf_jack_groundsplode_medium",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Sharpnel")
        net.Broadcast()

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			if enta == Ent then continue end
			local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			
			local force, len = safeExplosionDir(SelfPos, enta:GetPos())
			if not force then continue end
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and not behindwall then
					hg.ExplosionDisorientation(enta, 5 * frac, 6 * frac)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end


			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {Ent}
		table.Add(bullet.Filter, hg.drums2)
		local multi = math.min(Mass/5,20)

		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*5 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

         util.ScreenShake(SelfPos,100,900,1,5000)

        coroutine.resume(co)

		local index = Ent:EntIndex()

		timer.Create("GrenadeCheck_" .. index, 0, 0, function()
			if !IsValid(Ent) then
				timer.Remove("GrenadeCheck_" .. index)
			end
			coroutine.resume(co)
			if Ent.ShrapnelDone then
				if not IsValid(Ent) then return end
				SafeRemoveEntity(Ent)
				timer.Remove("GrenadeCheck_" .. index)
			end
		end)
    end,
    Normal = function(Ent,Force)
		local rad = (Force / 8)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
		hg.PlayExtraExplosionSound(SelfPos, Ent:EntIndex(), 1)
        util.BlastDamage(Ent, Owner, SelfPos, (Force / 7.5) / 0.01905, Force * 1)
		--hgWreckBuildings(Ent, SelfPos, Force / 50)
		hgBlastDoors(Ent, SelfPos, Force / 50)

        --ParticleEffect("pcf_jack_groundsplode_small",SelfPos + vector_up * 1,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Normal")
        net.Broadcast()

		local dis = rad / 0.01900
		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			if enta == Ent then continue end
			local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end
			
			local force, len = safeExplosionDir(SelfPos, enta:GetPos())
			if not force then continue end
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 50000

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and not behindwall then
					hg.ExplosionDisorientation(enta, 5 * frac, 6 * frac)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

			if tr.Entity != enta then forceadd = forceadd / 5 continue end


			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
				hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		if not IsValid(Ent) then return end
		 util.ScreenShake(SelfPos,100,900,1,2000)
		SafeRemoveEntity(Ent)
    end,
	CustomBarrel = function(Ent, Force, Mass)
		local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), (Ent.owner or Ent)
		local rad = (Force / 6.5)
		local dis = rad / 0.01905
		local scaledForce = Force * 1.35

		hg.PlayExtraExplosionSound(SelfPos, Ent:EntIndex(), 1.2)
		util.BlastDamage(Ent, Owner, SelfPos, dis, scaledForce * 1.4)
		hgBlastDoors(Ent, SelfPos, scaledForce / 35, scaledForce / 10)
		hg.ExplosionEffect(SelfPos, scaledForce / 0.18, 85)

		net.Start("hg_booom")
			net.WriteVector(SelfPos)
			net.WriteString("CustomBarrel")
		net.Broadcast()

		for i = 1, 8 do
			CreateVFireBall(14, 24, SelfPos + vector_up * 12, VectorRand(-350, 350) + Vector(0, 0, math.random(150, 350)))
		end

		local entsCount = 0
		for i, enta in ipairs(ents.FindInSphere(SelfPos, dis)) do
			if enta == Ent then continue end
			local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
			local tr = hg.ExplosionTrace(SelfPos, tracePos, {Ent})
			local phys = enta:GetPhysicsObject()
			if IsValid(phys) then
				entsCount = entsCount + 1
			end

			local force, len = safeExplosionDir(SelfPos, enta:GetPos())
			if not force then continue end
			local frac = math.Clamp((dis - len) / dis, 0.5, 1)
			local forceadd = force * frac * 70000

			if enta.organism and IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() and tr.Entity == enta then
				hg.ExplosionDisorientation(enta, 6 * frac, 8 * frac)
				hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
			end

			if tr.Entity != enta then forceadd = forceadd / 4 continue end

			if enta:IsPlayer() then
				hg.AddForceRag(enta, 0, forceadd * 0.6, 0.6)
				hg.AddForceRag(enta, 1, forceadd * 0.6, 0.6)
				timer.Simple(0, function() hg.LightStunPlayer(enta) end)
			end

			if not IsValid(phys) then continue end
			phys:ApplyForceCenter(forceadd)
		end

		if entsCount > 10 then
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
			EmitSound(DebrisSounds[math.random(#DebrisSounds)], Ent:GetPos(), Ent:EntIndex(), CHAN_AUTO, 1, 80)
		end

		util.ScreenShake(SelfPos, 120, 900, 1, 5000)
		SafeRemoveEntity(Ent)
	end,
}

function hg.PropExplosion(Ent, ExpType, Force, Mass)
	if Ent.HasExploded then return end
	Ent.HasExploded = true
	
    ExpTypes[ExpType](Ent,Force, Mass)
end

local expItems = {
    ["models/props_c17/oildrum001_explosive.mdl"] = {ExpType = "CustomBarrel", Force = 75},
    ["models/props_junk/gascan001a.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/propane_tank001a.mdl"] = {ExpType = "Sharpnel", Force = 30},
    ["models/props_junk/metalgascan.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/PropaneCanister001a.mdl"] = {ExpType = "Sharpnel", Force = 40},
    ["models/props_c17/canister01a.mdl"] = {ExpType = "Sharpnel", Force = 45},
    ["models/props_c17/canister02a.mdl"] = {ExpType = "Sharpnel", Force = 45},
    ["models/props_c17/canister_propane01a.mdl"] = {ExpType = "Fire", Force = 50}
}

hg.expItems = expItems

hook.Add("OnEntityCreated", "hg_gastank_spawn", function(ent)
	timer.Simple(0, function()
		RegisterGasTank(ent)
	end)
end)

hook.Add("InitPostEntity", "hg_gastank_mapinit", function()
	timer.Simple(1, function()
		for mdl, _ in pairs(GasTankModels) do
			for _, ent in ipairs(ents.FindByModel(mdl)) do
				RegisterGasTank(ent)
			end
		end
	end)
end)

timer.Simple(0, function()
	for mdl, _ in pairs(GasTankModels) do
		for _, ent in ipairs(ents.FindByModel(mdl)) do
			RegisterGasTank(ent)
		end
	end
end)

hook.Add("Think", "hg_gastank_mainloop", function()
	for idx, data in pairs(hg.GasTank.ActiveTanks) do
		local ent = data.Ent
		if not IsValid(ent) then
			hg.GasTank.ActiveTanks[idx] = nil
			continue
		end

		if IsLeakingTankOnFire(ent) then
			hg.GasTankDetonate(ent)
			continue
		end

		if not data.IsActive then continue end

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) and istable(data.Leaks) then
			local pushForce = GasTankPushForce[ent:GetModel()] or GasTankPushForce.Default
			for i = 1, #data.Leaks do
				local leak = data.Leaks[i]
				if leak and leak.LocalHolePos then
					local holePos = ent:LocalToWorld(leak.LocalHolePos)
					local dir = (ent:LocalToWorld(leak.LocalHolePos + leak.LocalNormal) - holePos):GetNormalized()
					dir = (dir + VectorRand() * 0.1):GetNormalized()
					phys:ApplyForceCenter(dir * pushForce)
					phys:AddAngleVelocity(VectorRand() * 10 * FrameTime())

					if leak.Mode == "fire" and CurTime() > (data.NextBurnTime or 0) then
						data.NextBurnTime = CurTime() + 0.1
						local burnPos = holePos + dir * 50
						for _, v in ipairs(ents.FindInSphere(burnPos, 100)) do
							if v == ent or not IsValid(v) then continue end
							if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
								v:Ignite(1)
							elseif v:GetClass() == "prop_physics" and not GasTankModels[v:GetModel()] then
								v:Ignite(1)
							end
						end
					end
					if leak.Mode == "smoke" and CurTime() > (leak.NextSmokeTime or 0) then
						if (data.GasAmount or 0) <= 0 then
							leak.Mode = "empty"
							continue
						end
						leak.NextSmokeTime = CurTime() + GasTankSmokeSettings.NextTick
						local smoke = EffectData()
						smoke:SetOrigin(holePos)
						smoke:SetNormal(dir)
						smoke:SetMagnitude(GasTankSmokeSettings.Magnitude)
						smoke:SetEntity(ent)
						util.Effect("eff_hg_co2_leak", smoke, true, true)
						for _, ply in ipairs(ents.FindInSphere(holePos, 220)) do
							if ply:IsPlayer() and ply:Alive() and ply.organism then
								ply.organism.lastCOBreathe = CurTime()
							end
						end
						if data.GasAmount then
							data.GasAmount = math.max(0, data.GasAmount - GasTankSmokeSettings.DrainPerTick)
						end
					end
				end
			end
		end

		if (data.GasAmount or 0) <= 0 and data.LeakMode == "smoke" then
			data.IsActive = false
			data.Leaks = {}
			net.Start("hg_gastank_stop")
			net.WriteUInt(idx, 16)
			net.Broadcast()
			continue
		end

		if CurTime() > (data.ExplodeAt or 0) then
			local hasFire = false
			for i = 1, #data.Leaks do
				if data.Leaks[i] and data.Leaks[i].Mode == "fire" then
					hasFire = true
					break
				end
			end
			if hasFire then
				hg.GasTankDetonate(ent)
			else
				data.ExplodeAt = CurTime() + 1
			end
		end
	end
end)

hook.Add("PostCleanupMap", "hg_gastank_reset", function()
	hg.GasTank.ActiveTanks = {}
end)

hook.Add("EntityTakeDamage", "ExplosiveDamage", function( target, dmginfo )
	if IsValid(target) then
		local tankData = hg.GasTank.ActiveTanks[target:EntIndex()]
		if tankData then
			if dmginfo:IsDamageType(DMG_BURN) or IsLeakingTankOnFire(target) then
				hg.GasTankDetonate(target)
				dmginfo:SetDamage(0)
				return true
			end

			if dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_BUCKSHOT) or dmginfo:IsDamageType(DMG_BLAST) then
				if not tankData.IsActive then
					tankData.IsActive = true
					tankData.NextBurnTime = 0
					tankData.ExplodeAt = CurTime() + math.Rand(3, 5)
					if not tankData.BaseGasAmount then
						tankData.BaseGasAmount = target.Volume or 75
						tankData.GasAmount = tankData.BaseGasAmount
					end
					local attacker = dmginfo:GetAttacker()
					if IsValid(attacker) then
						target.LastAttacker = attacker
					end
				end

				local localHole, localNormal = ResolveGasTankLeak(target, dmginfo)

				local mode = tankData.LeakMode or (RNG(100) <= 30 and "fire" or "smoke")
				tankData.LeakMode = mode
				if #tankData.Leaks >= 4 then
					table.remove(tankData.Leaks, 1)
				end
				tankData.Leaks[#tankData.Leaks + 1] = {
					LocalHolePos = localHole,
					LocalNormal = localNormal,
					Mode = mode,
					Time = CurTime()
				}

				net.Start("hg_gastank_leak")
				net.WriteEntity(target)
				net.WriteVector(localHole)
				net.WriteVector(localNormal)
				net.WriteString(mode)
				net.Broadcast()

				local phys = target:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
					phys:EnableMotion(true)
				end

				dmginfo:SetDamage(0)
				return true
			end

			if tankData.IsActive then
				dmginfo:SetDamage(0)
				return true
			end
		end
	end

	if IsValid(target) and expItems[target:GetModel()] then
		hook.Run("ExplosivesTakeDamage", target, dmginfo)

		local rnd = CurrentRound and CurrentRound()
		if (rnd and rnd.name == "coop" and dmginfo:IsDamageType(DMG_BLAST_SURFACE + DMG_BLAST + DMG_BURN + DMG_BULLET + DMG_BUCKSHOT + DMG_AIRBOAT) or dmginfo:IsDamageType(DMG_BLAST_SURFACE + DMG_BLAST + DMG_BURN)) and not target.babahnut then
			target.hp = target.hp or 50
			target.hp = target.hp - (dmginfo:GetDamage() / (dmginfo:IsDamageType(DMG_BURN) and 12.5 or 0.5))
			if target.hp <= 0 and ( !target.Volume or target.Volume > 0 ) and not target.babahnut then
				local tbl = expItems[target:GetModel()]
				target.babahnut = true
				
				hg.PropExplosion( target, tbl.ExpType, (target.Volume or tbl.Force) * 2, target:GetPhysicsObject():GetMass() )
			end
		end

		--dmginfo:SetDamageType(DMG_ACID)
		dmginfo:ScaleDamage(0)

		return true
	end
end)