hg.drums = hg.drums or {}
hg.drums2 = hg.drums2 or {}
hg.gasolinePath = hg.gasolinePath or {}

local math_random = math.random
local math_Round = math.Round
local math_max = math.max

local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)

local whitelistModels = {
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/metalgascan.mdl"] = true,
}

hg.gas_models = whitelistModels

local vecHole = {
	["models/props_c17/oildrum001_explosive.mdl"] = Vector(10, 0, 0),
	--["models/props_junk/gascan001a.mdl"] = Vector(0, -7, 11),
	--["models/props_junk/metalgascan.mdl"] = Vector(0, -7, 11),
}

PrecacheParticleSystem("env_fire_medium")

if SERVER then
	local function addDrum(ent)
		if not IsValid(ent) then return end

		if whitelistModels[ent:GetModel()] then
			local maxs, mins = ent:OBBMaxs(), ent:OBBMins()
			local vec = vecZero
			local hole = vecHole[ent:GetModel()]
			local pos

			if hole then
				vec:Set(hole)
				pos = maxs + mins + vec
			end

			hg.drums[ent:EntIndex()] = {
				Entity = ent,
				Volume = hole and math_random(1, pos[3]) or maxs[3] * 0.8,
				high_point = {
					[1] = hole and {pos, CurTime()} or nil
				}
			}
			table.insert(hg.drums2, ent)
		end
	end

	hook.Add("OnEntityCreated", "drum_spawn", function(ent) timer.Simple(0, function() addDrum(ent) end) end)
end

if SERVER then
	util.AddNetworkString("gas particle")
	util.AddNetworkString("gasoline_path")
	
	local time = CurTime()
	local CurTime = CurTime
	hook.Add("Think", "drum_think", function()
		if time > CurTime() then return end
		time = time + 0.1

		for i, drum in pairs(hg.drums) do
			hook.Run("Drum Think", i, drum)
		end
	end)

	local time2 = CurTime()
	local ents_FindInSphere = ents.FindInSphere
	hook.Add("Think", "path_think", function()
		if time2 > CurTime() then return end
		time2 = time2 + 1

		for i, tbl in ipairs(hg.gasolinePath) do
			local pos, ignited = tbl[1], tbl[2]
			
			if isnumber(ignited) and (ignited + 60) < CurTime() then tbl[2] = true continue end
			
			if isnumber(ignited) then
				local something_ignited = false
				
				for i, tbl2 in ipairs(hg.gasolinePath) do
					if not tbl2[2] and (tbl[1] - tbl2[1]):LengthSqr() < 2048 then
						tbl2[2] = CurTime()
						tbl2[3] = tbl[3] or tbl2[3]
						something_ignited = true
					end
				end
			
				for i, obj in ipairs(ents_FindInSphere(pos, 32)) do
					if obj:GetMoveType() == MOVETYPE_NONE then continue end
					
					if IsValid(obj) and (((not obj:IsPlayer()) or (obj:Alive() and obj:GetMoveType() != MOVETYPE_NOCLIP and !IsValid(obj.FakeRagdoll))) and not obj:IsOnFire() and obj:WaterLevel() < 1)  then
						--obj:Ignite(30 * ((obj.shouldburn or 0) + 1))
						CreateVFire(obj, obj:GetPos(), -vector_up, 100, tbl[3])
						--CreateVFire(parent, pos, normal, newFeed, spreader)
					end
				end
			end
		end

		net.Start("gasoline_path")
		net.WriteTable(hg.gasolinePath)
		net.Broadcast()
	end)

	hook.Add("PostCleanupMap","removetrailsofevidence",function()
		hg.drums = {}
		hg.drums2 = {}
		hg.gasolinePath = {}
	end)

	local vecTemp = Vector(0, 0, 0)
	
	hook.Add("Drum Think", "Main", function(i, drum)
		local ent = drum.Entity

		if not IsValid(ent) then
			hg.drums[i] = nil

			return
		end

		local pos = ent:GetPos()
		local maxs, mins, center = ent:OBBMaxs(), ent:OBBMins(), ent:OBBCenter()
		
		ent.lastvel = ent.lastvel or ent:GetVelocity()

		local diff = ent.lastvel:LengthSqr() - ent:GetVelocity():LengthSqr()
		if math.abs(diff) > 75 * 75 and drum.Volume > 1 then
			ent.lastvel = ent:GetVelocity()

			ent:EmitSound("player/footsteps/wade3.wav", 65, math.random(55, 75) * math.Clamp(2 - drum.Volume * 0.1, 1, 2))
		--elseif diff > 0 then
			--ent.lastvel = ent:GetVelocity()
		end

		for i, point in pairs(drum.high_point) do
			ent.Volume = drum.Volume
			local high_point = vecZero
			high_point:Set(point[1])
			high_point:Rotate(ent:GetAngles())

			local center = ent:OBBCenter()
			center:Rotate(ent:GetAngles())
			
			local dot = math.max(math.abs(vector_up:Dot(ent:GetUp())), 0.99)
			vecTemp[3] = drum.Volume / dot - ent:OBBCenter()[3]
			
			local volumePos = center + vecTemp
			volumePos:Add(ent:GetVelocity() / 8)
			
			if math_Round(high_point[3], 1) < math_Round(volumePos[3], 1) + 1 then
				drum.Volume = math_max(drum.Volume - 0.1, 0)
				drum.leaking = true
				drum.loopsound = drum.loopsound or CreateSound(ent,"ambient/water/leak_1.wav")
				drum.loopsound:Play()

				local tr = {}
				tr.start = pos + high_point
				tr.endpos = tr.start + -vector_up * 256
				tr.filter = ent

				tr = util.TraceLine(tr)
				
				if tr.Hit and tr.Entity == Entity(0) then
					if (drum.lastFireCreated or 0) < CurTime() then
						drum.lastFireCreated = CurTime() + 0.2

						table.insert(hg.gasolinePath, {tr.HitPos, false})
					end
				elseif tr.Entity != Entity(0) then
					tr.Entity.shouldburn = tr.Entity.shouldburn and tr.Entity.shouldburn + 1 or 1
				end

				net.Start("gas particle")
				net.WriteVector(pos + high_point)
				net.WriteVector(vector_up * 0 + ent:GetVelocity() + VectorRand(-15, 15) + (pos + high_point - (center + ent:GetPos())):GetNormalized() * 60)
				net.WriteEntity(ent)
				net.Broadcast()
			else
				if drum.loopsound then
					drum.loopsound:Stop()
				end

				drum.leaking = false
			end

			if point[2] < CurTime() then point[2] = point[2] + 0.1 end
		end

		if drum.Volume <= 0.5 then
			if drum.loopsound then
				drum.loopsound:Stop()
				drum.loopsound = nil
			end

			ent:SetNWBool("EmptyBarrel", true)

			hg.drums[i] = nil
		end
	end)

	hook.Add("EntityRemoved", "drum_removed", function(ent)
		local drum = hg.drums[ent:EntIndex()]
		if drum then
			if drum.loopsound then
				drum.loopsound:Stop()
				drum.loopsound = nil
			end
		end
		table.RemoveByValue(hg.drums2, ent)
	end)

	hook.Add("ExplosivesTakeDamage", "drum_damage", function(ent, dmgInfo)
		if !hg.drums[ent:EntIndex()] then return end
		if !(dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) or (dmgInfo:IsDamageType(DMG_SLASH) and dmgInfo:GetDamage() >= 25)) then return end
		
		local dmgPos = dmgInfo:GetDamagePosition()
		local tr = util.QuickTrace(dmgPos,(ent:GetPos() + ent:OBBCenter()) - dmgPos)
		if tr.Entity == ent then dmgPos = tr.HitPos end
		local localPos, localAng = WorldToLocal(dmgPos, angZero, ent:GetPos(), ent:GetAngles())
		local drum = hg.drums[ent:EntIndex()]
		
		if #drum.high_point < 5 then
			drum.high_point[#drum.high_point + 1] = {localPos, CurTime()}
		end
	end)
else
	net.Receive("drums_debug", function()
		hg.drums = net.ReadTable()
	end)

	hg.effparticles = hg.effparticles or {}

	local oldgas = {}
	net.Receive("gasoline_path", function()
		table.CopyFromTo(hg.gasolinePath, oldgas)

		hg.gasolinePath = net.ReadTable()

		for i, eff in pairs(hg.effparticles) do
			if hg.gasolinePath[i] then continue end

			if eff and eff:IsValid() then
				eff:StopEmissionAndDestroyImmediately()
			end
		end
	end)
		
	hook.Add("PreDrawEffects","fireeffects",function()
		for i, tbl in ipairs(hg.gasolinePath) do
			local pos, ignited = tbl[1], tbl[2]
			
			local effparticles = hg.effparticles
			
			if isnumber(tbl[2]) and (!effparticles[i] or !effparticles[i]:IsValid()) then
				effparticles[i] = CreateParticleSystemNoEntity("vFire_Base_Medium",tbl[1],AngleRand()*5)
			end

			if tbl[2] == true then -- do not change to "if tbl[2] then"
				if effparticles[i] and effparticles[i]:IsValid() then
					effparticles[i]:StopEmission()
				end
			end

			if isnumber(tbl[2]) and (tbl[2] + 60) < CurTime() then
				if effparticles[i] and effparticles[i]:IsValid() then
					effparticles[i]:StopEmission()
				end
			end
		end
	end)

	hook.Add("PostCleanupMap","removetrailsofevidence",function()
		hg.gasolinePath = {}

		for i, eff in pairs(hg.effparticles) do
			if eff and eff:IsValid() then
				eff:StopEmissionAndDestroyImmediately()
			end
		end
	end)

	hook.Add("HUDPaint","drum_client",function()
		if true then return end
		
        for i, drum in pairs(hg.drums) do
            local ent = drum.Entity
			
            if not IsValid(ent) then
                hg.drums[i] = nil
                continue
            end
            
            local pos = ent:GetPos()
            local maxs, mins, center = ent:OBBMaxs(),ent:OBBMins(),ent:OBBCenter()

            local leaking = false
            for i, point in pairs(drum.high_point) do
                local high_point = vecZero

                high_point:Set(point[1])
                high_point:Rotate(ent:GetAngles())

                --surface.DrawRect(pos:ToScreen().x,pos:ToScreen().y,10,10)

                local center = ent:OBBCenter()
                center:Rotate(ent:GetAngles())

                local dot = math.max(math.abs(vector_up:Dot(ent:GetUp())),0.99)
                
                local volumePos = center + Vector(0,0,(drum.Volume / (dot) - ent:OBBCenter()[3]))
                volumePos:Add(ent:GetVelocity() / 8)
                /*
                local center = ent:OBBCenter()
                center:Rotate(ent:GetAngles())

                local aa,ab = ent:OBBMaxs(),ent:OBBMins()
                local min,max = ent:GetRotatedAABB(aa, ab)

                center[3] = max[3]
                local volumePos = center - Vector(0,0,45 - drum.Volume)

                --слишком сложно
                */
                

                surface.DrawRect((pos + volumePos):ToScreen().x,(pos + volumePos):ToScreen().y,10,10)
                surface.DrawRect((pos + high_point):ToScreen().x,(pos + high_point):ToScreen().y,10,10)
                
                /*
                local aa,ab = ent:OBBMaxs(),ent:OBBMins()
                local _,max = ent:GetRotatedAABB(aa, ab)
                surface.DrawRect((pos + a):ToScreen().x,(pos + b):ToScreen().y,10,10)
				*/
            end
        end

		for i,tbl in pairs(hg.gasolinePath) do
			local pos, ignited = tbl[1], tbl[2]
			surface.SetDrawColor(255,255,255,255)
			surface.DrawRect(pos:ToScreen().x,pos:ToScreen().y,10,10)
		end
    end)
end