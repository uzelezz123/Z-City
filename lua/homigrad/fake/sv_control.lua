
local vecZero = Vector(0, 0, 0)
local vectorUp = Vector(0, 0, 1)
local shadowparams = {}

--[[
local ply = Entity(1)
local tbl = {}
for i = 0,ply:GetBoneCount()-1 do
	local physbone = ply:TranslateBoneToPhysBone(i)
	if physbone != -1 and not tbl[physbone] then
		tbl[physbone] = ply:GetBoneName(i)
	end
end
for i,bon in ipairs(tbl) do
	print("["..i.."] = "..'"'..bon..'"'..",")
end
]]

local defaultBones = {
	[0] = "ValveBiped.Bip01_Pelvis",
	[1] = "ValveBiped.Bip01_Spine2",
	[2] = "ValveBiped.Bip01_R_UpperArm",
	[3] = "ValveBiped.Bip01_L_UpperArm",
	[4] = "ValveBiped.Bip01_L_Forearm",
	[5] = "ValveBiped.Bip01_L_Hand",
	[6] = "ValveBiped.Bip01_R_Forearm",
	[7] = "ValveBiped.Bip01_R_Hand",
	[8] = "ValveBiped.Bip01_R_Thigh",
	[9] = "ValveBiped.Bip01_R_Calf",
	[10] = "ValveBiped.Bip01_Head1",
	[11] = "ValveBiped.Bip01_L_Thigh",
	[12] = "ValveBiped.Bip01_L_Calf",
	[13] = "ValveBiped.Bip01_L_Foot",
	[14] = "ValveBiped.Bip01_R_Foot",
}

local right_arm = {
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
}

local left_arm = {
	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
}

--[[
local ent = hg.GetCurrentCharacter(Entity(1))
for i = 0,ent:GetBoneCount()-1 do
	print(i,ent:GetBoneName(i),ent:TranslateBoneToPhysBone(i))
end

for i = 0,ent:GetPhysicsObjectCount()-1 do
	print(i,ent:GetBoneName(ent:TranslatePhysBoneToBone(i)),i)
end
--]]

hg.cachedmodels = hg.cachedmodels or {}

local function realPhysNum(ragdoll, physNumber)
	local bone = defaultBones[physNumber]
	local model = ragdoll:GetModel()
	
	if hg.cachedmodels[model] and hg.cachedmodels[model][bone] then
		return hg.cachedmodels[model][bone]
	else
		hg.cacheModel(ragdoll)
		
		return hg.cachedmodels[model] and hg.cachedmodels[model][bone] or 0
	end
end


hg.realPhysNum = realPhysNum
local oldtime
function hg.ShadowControl(ragdoll, physNumber, ss, ang, maxang, maxangdamp, pos, maxspeed, maxspeeddamp)
	physNumber = realPhysNum(ragdoll, physNumber) or 0
	local phys = ragdoll:GetPhysicsObjectNum(physNumber)
	--print(phys:GetMass(), hg.IdealMassPlayer[ragdoll:GetBoneName(ragdoll:TranslatePhysBoneToBone(physNumber))])
	--print(ragdoll:GetPhysicsObject():GetMass())
	--phys:SetMass(120)
	shadowparams.secondstoarrive = ss
	shadowparams.angle = ang
	shadowparams.maxangular = maxang and maxang * (ragdoll.power or 1)-- * (hg.IdealMassPlayer[physNumber] and hg.IdealMassPlayer[physNumber] / phys:GetMass() or 0)
	shadowparams.maxangulardamp = maxangdamp
	shadowparams.pos = pos
	shadowparams.maxspeed = maxspeed and maxspeed * (ragdoll.power or 1)
	shadowparams.maxspeeddamp = maxspeeddamp
	shadowparams.dampfactor = 0.9
	phys:Wake()
	phys:ComputeShadowControl(shadowparams)
end

local shadowControl = hg.ShadowControl

hook.Add("Fake", "Contorl", function(ply, ragdoll)
	ragdoll.cooldownLH = 0
	ragdoll.cooldownRH = 0
end)

--local ragdollFake = hg.ragdollFake or {}
local att, trace, ent
local tr = {
	filter = {}
}

local util_TraceLine, util_TraceHull = util.TraceLine, util.TraceHull
local game_GetWorld = game.GetWorld
local ang, ang2, ang3 = Angle(0, 0, 0), Angle(0, 0, 0),  Angle(0, 0, 0)
local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
local hullVec = Vector(3, 3, 6)
local vecAimHands = Vector(0, 0, -4.5)
local spine, time, rhand, lhand
--local Organism = hg.organism
local height = Vector(0, 0, 72) --28 eye level if crouched
local util_PointContents, bit_band, hook_Run = util.PointContents, bit.band, hook.Run
local forceArm = 600
local forceArm_dump = 450
local forceArmForward = 120
local forceArmForward_dump = 105
local forceArmWater = 5
local forceArmWater_dump = 0
local forceArmGun = 9000
local forceArmGun_dump = 1000
local fakeshockFall = 0.1
local models_female = {
	["models/player/group01/female_01.mdl"] = true,
	["models/player/group01/female_02.mdl"] = true,
	["models/player/group01/female_03.mdl"] = true,
	["models/player/group01/female_04.mdl"] = true,
	["models/player/group01/female_05.mdl"] = true,
	["models/player/group01/female_06.mdl"] = true,
	["models/player/group03/female_01.mdl"] = true,
	["models/player/group03/female_02.mdl"] = true,
	["models/player/group03/female_03.mdl"] = true,
	["models/player/group03/female_04.mdl"] = true,
	["models/player/group03/female_05.mdl"] = true,
	["models/player/group03/police_fem.mdl"] = true
}
local hook_Run = hook.Run
local vector_zero = Vector(0,0,0)
local vector_usehull = Vector(3,3,3)
--[[
	ValveBiped.Bip01_L_Thigh
	ValveBiped.Bip01_L_Calf
	ValveBiped.Bip01_L_Foot
	ValveBiped.Bip01_L_Toe0
]]

--[[local mainbones = {
	["ValveBiped.Bip01_Pelvis"] = true,
	["ValveBiped.Bip01_Spine2"] = true,
	["ValveBiped.Bip01_Head1"] = true,
}--]]

local speedupbones = {
	["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_R_Foot"] = true,
}

local vecfive = Vector(5,5,5)

local player_GetHumans = player.GetHumans

hook.Add("Think", "Fake", function()
	hg.humans_cached = player_GetHumans()

	//for ply, ragdoll in pairs(hg.ragdollFake) do
	for i, ply in player.Iterator() do
		local ragdoll = hg.ragdollFake[ply]//ply.FakeRagdoll
		if not IsValid(ragdoll) then
			//hg.ragdollFake[ply] = nil
			continue
		end

		local torso = ragdoll:LookupBone("ValveBiped.Bip01_Spine2")
		if torso then
			local torsopos, ang = ragdoll:GetBonePosition(torso)

			if IsValid(ragdoll.bull) and (ragdoll.bull.lastposset or 0) < CurTime() then
				ragdoll.bull.lastposset = CurTime() + 0.5
				
				ragdoll.bull:SetPos(torsopos + vector_up * 5)
				--ragdoll.bull:Remove()
				--if ply.FakeRagdoll == ragdoll then ply:SetPos(ragdoll:GetPos()) end
			end
		end

		if hook_Run("CanControlFake", ply, ragdoll) ~= nil then
			ply.lastFake = 0
			//ply:SetNetVar("lastFake",0)
			continue
		end

		ragdoll.dtime = (SysTime() - (ragdoll.lastCallTime or SysTime())) * game.GetTimeScale()
		ragdoll.lastCallTime = SysTime()

		local vellen = ragdoll:GetPhysicsObject():GetVelocity():Length()

		local org = ply.organism
		local wep = ply:GetActiveWeapon()

		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() - vector_up * 10
		tr.filter = {ply,ragdoll}
		local tracehuy = util.TraceLine(tr)
		
		local power = org.pain and ((org.pain > 50 or org.blood < 2900 or org.o2[1] < 5) and 0.3) or ((org.pain > 20 or org.blood < 4200 or org.o2[1] < 10) and 0.5) or 1
		power = power * org.consciousness
		ragdoll.power = power

		local inmove = false
		
		local ragdollcombat = hg.RagdollCombatInUse(ply)
		if !ragdollcombat and ragdoll == ply.FakeRagdoll then
			hg.SetFreemove(ply, false)
		end

		if (org.lightstun < CurTime()) and (tracehuy.Hit or ply.FakeRagdoll ~= ragdoll) and org.spine1 < hg.organism.fake_spine1 and org.canmove and ((ply.lastFake and (ply.lastFake) > CurTime()) or ply.FakeRagdoll ~= ragdoll) and !ply.jumpedfake then
			local power = 1
			inmove = true
			
			local ragbonecount = ragdoll:GetPhysicsObjectCount()
			for i = 0, ragbonecount - 1 do
				local bone = ragdoll:TranslatePhysBoneToBone(i)
				local bonepos, boneang = ply:GetBonePosition(bone)
				if bonepos and boneang then
					local physobj = ragdoll:GetPhysicsObjectNum(i)
					local mass = physobj:GetMass() / 5
					
					local name = ragdoll:GetBoneName(bone)

					if IsValid(physobj) then
						local bone_impulse = ply.HitBones and ply.HitBones[bonename] or CurTime()
						local amt_impulse = (2 - math.Clamp(bone_impulse - CurTime(),0,2)) / 2
						
						local p = {}
						p.secondstoarrive = 0.01
						p.pos = bonepos
						p.angle = boneang
						p.maxangular = 250 * (ragdollcombat and 1 or 0.25) * mass * power * amt_impulse
						p.maxangulardamp = 100 * (ragdollcombat and 1 or 0.75) * mass * power * amt_impulse
						p.maxspeed = 250 * (ragdollcombat and 1 or 0.25) * mass * power * amt_impulse
						p.maxspeeddamp = 100 * (ragdollcombat and 1 or 0.75) * mass * amt_impulse
						p.teleportdistance = 0

						physobj:Wake()
						
						if ply:KeyDown(IN_JUMP) then
							if !ply.jumpedfake then
								ply.jumpedfake = true

								physobj:ApplyForceCenter(vector_up * 15000)
							end
						else
							ply.jumpedfake = nil
							physobj:ComputeShadowControl(p)
						end
					end
				end
			end

			if ply.FakeRagdoll ~= ragdoll then continue end
		elseif ply:Alive() then			
			local pos = ragdoll:GetBoneMatrix(ragdoll:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()		
			
			if !ply:KeyDown(IN_JUMP) then
				ply.jumpedfake = nil
			end

			if ragdollcombat then
				hg.SetFreemove(ply, true)
			end

			if ply:InVehicle() then
				ply:SetPos(vector_origin)
			else
				ply:SetPos(pos)
				--ply:SetVelocity(vector_origin)
			end
		end

		local angles = ply:EyeAngles()
		local att = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		--ragdoll:SetFlexWeight(9, 0)
		local vecpos = angles:Forward() * 10000
		local dist = (angles:Forward() * 10000):Distance(vecpos)
		local distmod = math.Clamp(1 - (dist / 20000), 0.35, 1)
		local lookat = LerpVector(distmod, att.Ang:Forward() * 10000, vecpos)
		local LocalPos, LocalAng = WorldToLocal(lookat, angles, att.Pos, att.Ang)
		LocalAng[1] = math.Clamp(LocalAng[1], -30, 30)
		LocalAng[2] = math.Clamp(LocalAng[2], -30, 30)
		
		if ragdoll.organism and not ragdoll.organism.otrub then
			ragdoll.LastAng = LocalAng
		else
			LocalAng = ragdoll.LastAng or LocalAng
		end

		ragdoll:SetEyeTarget(LocalAng:Forward() * 10000)

		local model = ragdoll:GetModel()
		ang:Set(angles)
		
		if ishgweapon(wep) and !wep:IsPistolHoldType() then
			ang:RotateAroundAxis(ang:Up(), 30)
		end

		if (!ply:InVehicle() && (ply:KeyDown(IN_USE) || ((ishgweapon(wep)) && ply:KeyDown(IN_ATTACK2)) || (wep.ismelee && (ply:KeyDown(IN_ATTACK2) || ply:KeyDown(IN_ATTACK))))) || (ply:InVehicle() && not ply:KeyDown(IN_USE)) or ragdollcombat then
			if org.canmove and (not ply:KeyDown(IN_MOVELEFT) and not ply:KeyDown(IN_MOVERIGHT) or ply:InVehicle()) then
				local angl = angZero
				angl:Set(ang)
				if ply:KeyDown(IN_DUCK) then
					angl:RotateAroundAxis(angl:Right(), ishgweapon(wep) and 30 or 30)
				end
				--angl:RotateAroundAxis(angl:Right(), -90)
				angl:RotateAroundAxis(angl:Forward(), 90)
				angl:RotateAroundAxis(angl:Up(), 90)
				angl:RotateAroundAxis(angl:Forward(), ishgweapon(wep) and not wep:IsPistolHoldType() and 120 or 180)
				angl:RotateAroundAxis(angl:Up(), -0)
				shadowControl(ragdoll, 1, 0.1, angl, 250, 20)
			end

			if org.canmovehead then
				--ang2 = Angle(-90,ang[2] - 90,0)
				local angl = angZero
				angl:Set(ang)
				if ply:KeyDown(IN_DUCK) then
					angl:RotateAroundAxis(angl:Right(), -90)
				end
				angl:RotateAroundAxis(angl:Forward(), 90)
				angl:RotateAroundAxis(angl:Up(), 90)
				shadowControl(ragdoll, 10, 0.1, angl, 100, 60) --,Vector(0,0,0),1000,1000)	
			end
		end

		spine = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,1))
		rhand = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7))
		lhand = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5))
		ang = spine:GetAngles()

		local angles2 = -(-angles)
		angles2:RotateAroundAxis(angles2:Right(),30)

		local forward = ply:KeyDown(IN_FORWARD)
		local back = ply:KeyDown(IN_BACK)
		time = CurTime()
		
		if ply.organism and ply.organism.wounds and not table.IsEmpty(ply.organism.wounds) and org.canmove and (ply.fakecd and (ply.fakecd + 1) > CurTime()) then
			local tr = {}
			tr.start = ragdoll:GetPos()
			tr.endpos = ragdoll:GetPos() - vector_up * 60
			tr.filter = {ply,ragdoll}
			local tracehuy = util.TraceLine(tr)

			if tracehuy.Hit then
				local wounds = ply.organism.wounds
				local wound = wounds[table.maxn(wounds) - 1] or wounds[table.maxn(wounds)]

				if ragdoll:LookupBone(wound[4]) then
					local pos, ang = LocalToWorld(wound[2], wound[3], ragdoll:GetBonePosition(ragdoll:LookupBone(wound[4])))
					
					if not ply:KeyDown(IN_ATTACK) and !left_arm[wound[4]] then
						shadowControl(ragdoll, 3, 0.001, nil, nil, nil, spine:GetPos() + spine:GetAngles():Right() * -50, 25, 10)
						shadowControl(ragdoll, 5, 0.001, nil, nil, nil, pos - (pos - lhand:GetPos()):GetNormalized() * 2, 100, 10)
					end

					if not ply:KeyDown(IN_ATTACK2) and !right_arm[wound[4]] then
						shadowControl(ragdoll, 2, 0.001, nil, nil, nil,spine:GetPos() + spine:GetAngles():Right() * -50, 25, 10)
						shadowControl(ragdoll, 7, 0.001, nil, nil, nil, pos - (pos - rhand:GetPos()):GetNormalized() * 2, 100, 10)
					end

					if not ply:KeyDown(IN_USE) then
						shadowControl(ragdoll, 10, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,8)):GetPos(), 40, 10)
						shadowControl(ragdoll, 1, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,8)):GetPos(), 00, 10)
						shadowControl(ragdoll, 2, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,8)):GetPos(), 0, 10)
						shadowControl(ragdoll, 3, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,8)):GetPos(), 20, 10)
						shadowControl(ragdoll, 11, 0.001, nil, nil, nil, spine:GetPos() + spine:GetAngles():Forward() * 50, 30, 10)
						shadowControl(ragdoll, 8, 0.001, nil, nil, nil, spine:GetPos() + spine:GetAngles():Forward() * 50, 30, 10)
					end
				end
			end
		end
		
		if not wep.RagdollFunc then
			local force = math.max(1 - org.larm / 1.3, 0)
			if !IsValid(ragdoll.ConsLH) and (ply:KeyDown(IN_ATTACK) and !ishgweapon(wep)) or ((ishgweapon(wep) or wep.ismelee2) and (ply:KeyDown(IN_USE) or ply:KeyDown(IN_ATTACK2))) then// || ply:InVehicle() then
				if org.canmove then
					//if !ply:InVehicle() then
						ang2:Set(angles)
						local lower = (ishgweapon(wep) and (ply:KeyDown(IN_USE) or ply:KeyDown(IN_ATTACK2)))
						ang2:RotateAroundAxis(angles:Right(), lower and -20 or 0)
						ang2:RotateAroundAxis(angles:Up(), lower and 20 or 10)
						ang2:RotateAroundAxis(angles:Forward(), -45)
						

						shadowControl(ragdoll, 3, 0.002, ang2, forceArm * force, forceArm_dump)
						shadowControl(ragdoll, 4, 0.002, ang2, forceArm * force, forceArm_dump)
						ang2:RotateAroundAxis(ang2:Forward(), 135)
						ang2:RotateAroundAxis(ang2:Up(), 20)
						shadowControl(ragdoll, 5, 0.001, ang2, forceArm * 2, forceArm_dump, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5)):GetPos() + ang2:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), 500, 50)
						if ply:WaterLevel() == 1 then shadowControl(ragdoll, 1, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5)):GetPos(), forceArmWater, forceArmWater_dump) end
					/*else
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), 0)
						ang2:RotateAroundAxis(angles:Right(), 0)
						ang2:RotateAroundAxis(angles:Forward(), -0)
						shadowControl(ragdoll, 5, 0.001, ang2, forceArm * 2, forceArm_dump * 2, ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_L_Hand")):GetTranslation() + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Up() * 4 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Forward() * -3 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Right() * 5 + ragdoll:GetVelocity() / 20, 5550, 1550)
					end*/
				end
			end

			local on_ground = util.TraceLine({
					start = spine:GetPos(),
					endpos = spine:GetPos() - vector_up * 58,
					filter = {ply, ragdoll},
					mask = MASK_SOLID,
				}).Hit
			
			if forward then
				if IsValid(ragdoll.ConsRH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsRH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = force * 2000 * math.max((hand:GetPos() - torso:GetPos()):GetNormalized():Dot(angles2:Forward()) + 0.1, 0) * ragdoll.dtime / 0.015 * ragdoll.power
					
					force = force * 1 / math.max(torso:GetVelocity():Dot(angles2:Forward()) / 25, 1)

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.rarm == 1 or org.rarmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end

					org.stamina.subadd = org.stamina.subadd + 0.05 * (ragdoll.staminaRightModifyer or 0.5) * (on_ground and 0.25 or 1)
				end

				if IsValid(ragdoll.ConsLH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsLH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = force * 2000 * math.max((hand:GetPos() - torso:GetPos()):GetNormalized():Dot(angles2:Forward()) + 0.1, 0) * ragdoll.dtime / 0.015 * ragdoll.power
					
					force = force * 1 / math.max(torso:GetVelocity():Dot(angles2:Forward()) / 25, 1)

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.larm == 1 or org.larmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end
					org.stamina.subadd = org.stamina.subadd + 0.05 * (ragdoll.staminaLeftModifyer or 0.5) * (on_ground and 0.25 or 1)
				end
			end

			if back then
				if IsValid(ragdoll.ConsRH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsRH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = -force * 1200 * math.min(10 / (hand:GetPos() - torso:GetPos()):Length(), 1) * ragdoll.dtime / 0.015 * ragdoll.power

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.rarm == 1 or org.rarmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end
				end

				if IsValid(ragdoll.ConsLH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsLH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = -force * 1200 * math.min(10 / (hand:GetPos() - torso:GetPos()):Length(), 1) * ragdoll.dtime / 0.015 * ragdoll.power
					
					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.larm == 1 or org.larmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end
				end
			end

			local force = math.max(1 - org.rarm / 1.3, 0)

			if !IsValid(ragdoll.ConsRH) and ply:KeyDown(IN_ATTACK2) or ((ishgweapon(wep) or wep.ismelee2) and ply:KeyDown(IN_USE)) then// || ply:InVehicle() then
				if org.canmove then
					--if org.shock > 1 and not ply:KeyDown(IN_ATTACK2) then angles = spine:GetAngles() end
					//if !ply:InVehicle() then
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), ishgweapon(wep) and -10 or 0)
						ang2:RotateAroundAxis(angles:Right(), ishgweapon(wep) and 10 or 0)
						ang2:RotateAroundAxis(angles:Forward(), -90)

						//if !ishgweapon(wep) then
							shadowControl(ragdoll, 2, 0.001, ang2, forceArm * force, forceArm_dump)
							shadowControl(ragdoll, 6, 0.001, ang2, forceArm * force, forceArm_dump)
						//end

						ang2:RotateAroundAxis(ang2:Forward(), 135)
						ang2:RotateAroundAxis(ang2:Up(), ishgweapon(wep) and 1 or 20)
						ang2:RotateAroundAxis(ang2:Forward(), ishgweapon(wep) and 120 or 0)
						shadowControl(ragdoll, 7, 0.001, ang2, forceArm * 2, forceArm_dump, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7)):GetPos() + ang2:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), ishgweapon(wep) and 500 or 500, ishgweapon(wep) and 50 or 50)
						if ply:WaterLevel() == 1 then shadowControl(ragdoll, 1, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(7):GetPos(), forceArmWater, forceArmWater_dump) end
					/*else
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), 0)
						ang2:RotateAroundAxis(angles:Right(), 0)
						ang2:RotateAroundAxis(angles:Forward(), 180)
						shadowControl(ragdoll, 7, 0.001, ang2, forceArm * 2, forceArm_dump * 2, ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetTranslation() + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Up() * 5 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Forward() * -1 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Right() * 2 + ragdoll:GetVelocity() / 20, 5550, 1550)
					end*/
				end
			end
			
			local choking = (IsValid(ragdoll.ConsRH) and IsValid(ragdoll.ConsRH.choking) and ragdoll.ConsRH.choking) or (IsValid(ragdoll.ConsLH) and IsValid(ragdoll.ConsLH.choking) and ragdoll.ConsLH.choking)
			local chokinghead = false

			if ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_WALK) then
				local trace
				tr.start = lhand:GetPos() + lhand:GetAngles():Forward() * 5
				tr.endpos = rhand:GetPos() + lhand:GetAngles():Forward() * 5
				tr.filter = ragdoll
				trace = util_TraceLine(tr)
	
				ent = trace.Entity
				
				if IsValid(ent) and ent:IsRagdoll() and trace.PhysicsBone == realPhysNum(ent, 10) then -- Отрубил чтобы ошибок не было пока...
					choking = ent
					local head = ent:GetPhysicsObjectNum(realPhysNum(ent, 10))
					chokinghead = head

					if IsValid(ragdoll.ConsRH) and not IsValid(ragdoll.ConsRH.choking) then
						rhand:SetPos(head:GetPos())
						ragdoll.cooldownLH = nil
						ragdoll.ConsRH:Remove()
						ragdoll.ConsRH = nil
					end
	
					if IsValid(ragdoll.ConsLH) and not IsValid(ragdoll.ConsLH.choking) then
						lhand:SetPos(head:GetPos())
						ragdoll.cooldownRH = nil
						ragdoll.ConsLH:Remove()
						ragdoll.ConsLH = nil
					end
				end
			end

			if org.stamina[1] < 2 then
				ply.HandsStun = CurTime() + 2
				--ply:Notify(math.random(1,2) == 1 and "SHIT!" or "OH NOO!", 2, "ragdoll_fall", 0, nil, Color(255, 0, 0))
			end

			if org.stamina[1] < 50 and (IsValid(ragdoll.ConsRH) or IsValid(ragdoll.ConsLH)) then
				ply:Notify( math.random(1,2) == 1 and "I'm at my limits here!" or "I can't hold much longer...", 25, "ragdoll_almostfall", 0, nil, Color(200, 55, 55))
			end

			if ply:KeyDown(IN_SPEED) and org.canmove and !org.larmamputated and (!ply.HandsStun or ply.HandsStun < CurTime()) then
				--and org.shock < fakeshockFall
				if IsValid(ragdoll.ConsLH) then
					org.stamina.subadd = org.stamina.subadd + 0.06 * (ragdoll.staminaLeftModifyer or 0.5) * ( IsValid(ragdoll.ConsRH) and 0.35 or 1.25) * (on_ground and 0.25 or 1)

					local ent2 = ragdoll.ConsLH.Ent2
					local ply2 = hg.RagdollOwner(ent2) or ent2

					if ply.PlayerClassName == "furry" and ply2.PlayerClassName != "furry" and IsValid(ent2) and ent2.organism then
						ent2.organism.assimilated = math.Approach(ent2.organism.assimilated, 1, ragdoll.dtime / 6)
						ent2.organism.lightstun = CurTime() + 1
					end
				end

				local wepinreload = wep and wep.reload
				phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 5))
				if (ragdoll.cooldownLH or 0) < time and not IsValid(ragdoll.ConsLH) and not wepinreload then

					--\\ Find Use Entity in ragdoll
						local usetrace = util_TraceHull({
							start = phys:GetPos(),
							endpos = phys:GetPos(),
							maxs = vector_usehull,
							mins = -vector_usehull,
							filter = {ragdoll, game.GetWorld()},
							mask = MASK_SOLID
						})

						local useent = (IsValid(usetrace.Entity) and usetrace.Entity) or false
						if useent and not useent:IsVehicle() then useent:Use(ply) end
						local wep = useent and useent:IsWeapon() and useent or false
						ply.force_pickup = true
						if IsValid(wep) and hook.Run("PlayerCanPickupWeapon", ply, wep) then ply:PickupWeapon(wep) end
						ply.force_pickup = nil
					--//

					local trace
					for i = 1,3 do
						if trace and trace.Hit and not trace.HitSky then continue end
						tr.start = phys:GetPos()
						tr.endpos = phys:GetPos() + phys:GetAngles():Right() * 6 + phys:GetAngles():Up() * (i - 2) * 3
						tr.filter = ragdoll
						tr.mask = MASK_SOLID
						trace = util_TraceLine(tr)
					end

					if IsValid(choking) or (trace.Hit and not trace.HitSky) then
						ent = IsValid(choking) and choking or trace.Entity
						ragdoll.staminaLeftModifyer = 1.5 - trace.HitNormal.z

						if IsValid(choking) and chokinghead then
							lhand:SetPos(chokinghead:GetPos(), true)
						end

						local cons = constraint.Weld(ragdoll, ent, realPhysNum(ragdoll, 5), IsValid(choking) and realPhysNum(choking, 10) or trace.PhysicsBone, ent:IsWorld() and 10000 or 0, false, false)
						if IsValid(cons) then
							ragdoll.cooldownLH = time + 0.5
							ragdoll.ConsLH = cons

							cons:CallOnRemove("fingersback", function()
								for i = 1, 4 do
									if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
									ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
								end
							end)

							cons.choking = choking

							ragdoll:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, math.random(95, 105))
							
							for i = 1, 4 do
								if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
								ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, -45, 0))
							end
						end
					end
				end
			else
				if IsValid(ragdoll.ConsLH) then
					ragdoll.ConsLH:Remove()
					ragdoll.ConsLH = nil
					for i = 1, 4 do
						if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
						ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
					end
				end
			end

			if ply:KeyDown(IN_WALK) and org.canmove and !(ishgweapon(wep) or wep.ismelee2) and !org.rarmamputated and (!ply.HandsStun or ply.HandsStun < CurTime()) then
				--and org.shock < fakeshockFall
				if IsValid(ragdoll.ConsRH) then
					org.stamina.subadd = org.stamina.subadd + 0.06 * (ragdoll.staminaRightModifyer or 1) * ( IsValid(ragdoll.ConsLH) and 0.35 or 1.25) * (on_ground and 0.25 or 1)
				
					local ent2 = ragdoll.ConsRH.Ent2
					local ply2 = hg.RagdollOwner(ent2) or ent2

					if ply.PlayerClassName == "furry" and ply2.PlayerClassName != "furry" and IsValid(ent2) and ent2.organism then
						ent2.organism.assimilated = math.Approach(ent2.organism.assimilated, 1, ragdoll.dtime / 6)
						ent2.organism.lightstun = CurTime() + 1
					end
				end

				phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 7))

				if (ragdoll.cooldownRH or 0) < time and not IsValid(ragdoll.ConsRH) then
					
					--\\ Find Use Entity in ragdoll
						local usetrace = util_TraceHull({
							start = phys:GetPos(),
							endpos = phys:GetPos(),
							maxs = vector_usehull,
							mins = -vector_usehull,
							filter = {ragdoll, game.GetWorld()},
							mask = MASK_SOLID
						})

						local useent = (IsValid(usetrace.Entity) and usetrace.Entity) or false
						if useent and not useent:IsVehicle() then useent:Use(ply) end
						local wep = useent and useent:IsWeapon() and useent or false
						ply.force_pickup = true
						if IsValid(wep) and hook.Run("PlayerCanPickupWeapon", ply, wep) then ply:PickupWeapon(wep) end
						ply.force_pickup = nil
					--//

					local trace
					for i = 1,3 do
						if trace and trace.Hit and not trace.HitSky then continue end
						tr.start = phys:GetPos()
						tr.endpos = phys:GetPos() + phys:GetAngles():Right() * 6 + phys:GetAngles():Up() * (i - 2) * 3
						tr.filter = ragdoll
						trace = util_TraceLine(tr)
					end
					
					if IsValid(choking) or (trace.Hit and not trace.HitSky) then
						ent = trace.Entity
						ragdoll.staminaRightModifyer = 1.5 - trace.HitNormal.z
						
						if IsValid(choking) and chokinghead then
							rhand:SetPos(chokinghead:GetPos(), true)
						end
						
						local cons = constraint.Weld(ragdoll, ent, realPhysNum(ragdoll, 7), IsValid(choking) and realPhysNum(choking, 10) or trace.PhysicsBone, ent:IsWorld() and 10000 or 0, false, false)
						if IsValid(cons) then
							ragdoll.cooldownRH = time + 0.5
							ragdoll.ConsRH = cons

							cons:CallOnRemove("fingersback", function()
								for i = 1, 4 do
									if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
									ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
								end
							end)

							cons.choking = choking

							ragdoll:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 55, math.random(95, 105))
							
							for i = 1, 4 do
								if not ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1") then continue end
								ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, -45, 0))
							end
						end
					end
				end
			else
				if IsValid(ragdoll.ConsRH) then
					ragdoll.ConsRH:Remove()
					ragdoll.ConsRH = nil
					for i = 1, 4 do
						if not ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1") then continue end
						ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
					end
				end
			end
		else
			if ply:KeyDown(IN_ATTACK2) and org.canmove then
				if wep.RagdollFunc then
					wep:RagdollFunc(ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7)):GetPos() + angles:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), angles, ragdoll)
				end
			end
		end
		-- Zavtra yje
		if IsValid(ragdoll.ConsLH) and IsValid(ragdoll.ConsRH) and IsValid(ragdoll.ConsLH.choking) and ragdoll.ConsLH.choking == ragdoll.ConsRH.choking then
			local choking1 = ragdoll.ConsLH.choking
			local head = choking1:GetPhysicsObjectNum(realPhysNum(choking1, 10))
			--lhand:SetPos(head:GetPos())
			--rhand:SetPos(head:GetPos())
			local org = choking1.organism
			if org then
				org.choking = true
				if zb then
					local dmgInfo = DamageInfo()
					dmgInfo:SetAttacker(ply)
					hook.Run("HomigradDamage", org.owner, dmgInfo, HITGROUP_RIGHTARM, hg.GetCurrentCharacter(org.owner), ragdoll.dtime * ((zb.MaximumHarm or 10) / 50) )
				end

				if org.otrub then
					ply:Notify("They seem unresponsive.", 60, "choked"..(org.owner:EntIndex()))
				end
			end
			--print("huy")
		end

		if ply:KeyDown(IN_MOVELEFT) and not inmove and !ply:InVehicle() then
			if org.canmove then
				local angle = spine:GetAngles()
				angle[3] = angle[3] - 20 * (ragdoll:IsOnFire() and 1.5 or 1)
				--ragdoll, physNumber, ss, ang, maxang, maxangdamp, pos, maxspeed, maxspeeddamp
				shadowControl(ragdoll, 1, 0.001, angle, 490, 90)
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))

				if math.random(100) == 1 and ragdoll:IsOnFire() then
					local key, fire = next(ragdoll.fires)

					if ragdoll:IsOnFire() then
						shadowControl(ragdoll, 5, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
						shadowControl(ragdoll, 7, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
					end

					if key then 
						ragdoll.fires[key] = nil

						if IsValid(key) then
							key:Remove()
						end
					end
				end
			end
		end

		if ply:KeyDown(IN_MOVERIGHT) and not inmove and !ply:InVehicle() then
			if org.canmove and not org.otrub then
				local angle = spine:GetAngles()
				angle[3] = angle[3] + 20 * (ragdoll:IsOnFire() and 1.5 or 1)
				shadowControl(ragdoll, 1, 0.001, angle, 490, 90)
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))

				if ragdoll:IsOnFire() then
					shadowControl(ragdoll, 5, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
					shadowControl(ragdoll, 7, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
				end

				if math.random(100) == 1 and ragdoll:IsOnFire() then
					local key, fire = next(ragdoll.fires)
					
					if key then 
						ragdoll.fires[key] = nil

						if IsValid(key) then
							key:Remove()
						end
					end
				end
			end
		end

		if ply:KeyDown(IN_DUCK) and !ply:InVehicle() then
			if org.canmove and org.spine1 < hg.organism.fake_spine1 then
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))
				local angle = -(-angles2)
				angle:RotateAroundAxis(angle:Forward(), -90)

				if ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), -angle.p - 30)
				end

				if ply:KeyDown(IN_ATTACK2) and !ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), 30)
				end

				angle:RotateAroundAxis(angle:Right(), -15)
				shadowControl(ragdoll, 8, 0.001, angle, 120, 30)

				if ply:KeyDown(IN_ATTACK2) and !ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), -30)
				end

				if ply:KeyDown(IN_ATTACK) and !ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), 30)
				end

				angle:RotateAroundAxis(angle:Right(), 30)
				shadowControl(ragdoll, 11, 0.001, angle, 120, 30) -- ragdoll, physNumber, ss, ang, maxang, maxangdamp, pos, maxspeed, maxspeeddamp

				if ply:KeyDown(IN_ATTACK) and !ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), -30)
				end

				//if vellen < 200 then
				if !ply:KeyDown(IN_ATTACK2) or ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), 90)
				end
				shadowControl(ragdoll, 9, 0.001, angle, 120, 30)
				if !ply:KeyDown(IN_ATTACK2) or ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), -90)
				end
				if !ply:KeyDown(IN_ATTACK) or ishgweapon(wep) then
					angle:RotateAroundAxis(angle:Up(), 90)
				end
				shadowControl(ragdoll, 12, 0.001, angle, 120, 30)

				local rleg = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 13))
				local lleg = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 14))

				local force = angles2:Forward()
				force:Normalize()
				force = force * 100 * ragdoll.dtime / 0.015 * ragdoll.power

				if org.lleg >= 1 or org.rleg >= 1 then
					org.painadd = org.painadd + ragdoll.dtime * 2 * (org.lleg + org.rleg)
				end
				//rleg:ApplyForceCenter(force)
				//lleg:ApplyForceCenter(force)
			end
		end
		local vel = ragdoll:GetVelocity()
		local vellen = vel:Length()
		if org.canmove and vellen > 350 and !ply:InVehicle() then
			--[[
			
				local defaultBones = {
					[0] = "ValveBiped.Bip01_Pelvis",
					[1] = "ValveBiped.Bip01_Spine2",
					[2] = "ValveBiped.Bip01_R_UpperArm",
					[3] = "ValveBiped.Bip01_L_UpperArm",
					[4] = "ValveBiped.Bip01_L_Forearm",
					[5] = "ValveBiped.Bip01_L_Hand",
					[6] = "ValveBiped.Bip01_R_Forearm",
					[7] = "ValveBiped.Bip01_R_Hand",
					[8] = "ValveBiped.Bip01_R_Thigh",
					[9] = "ValveBiped.Bip01_R_Calf",
					[10] = "ValveBiped.Bip01_Head1",
					[11] = "ValveBiped.Bip01_L_Thigh",
					[12] = "ValveBiped.Bip01_L_Calf",
					[13] = "ValveBiped.Bip01_L_Foot",
					[14] = "ValveBiped.Bip01_R_Foot",
				}

				(ragdoll, physNumber, ss, ang, maxang, maxangdamp, pos, maxspeed, maxspeeddamp)
			--]]
			local mul = (vellen - 350) / 750
			local maxangdamp = 500 * mul
			local maxangspeed = 950 *  mul
			local rand = 360 * mul
			shadowControl(ragdoll, 2, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 3, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 4, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 5, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 6, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 7, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 8, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 9, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 10, 0.001, AngleRand(-rand,rand), maxangspeed / 4, maxangdamp)
			shadowControl(ragdoll, 11, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 12, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
		end

		/*if ply:KeyDown(IN_DUCK) and !ply:InVehicle() then
			if org.canmove then
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))
				local angle = spine:GetAngles()

				//shadowControl(ragdoll, 13, 0.001, angle, 0, 0, spine:GetPos() + head:GetAngles():Forward() * 10, 5050, 100)
				//shadowControl(ragdoll, 14, 0.001, angle, 0, 0, spine:GetPos() + head:GetAngles():Forward() * 10, 5050, 100)

				local rleg = ragdoll:GetPhysicsObject(realPhysNum(ragdoll, 13))
				local lleg = ragdoll:GetPhysicsObject(realPhysNum(ragdoll, 14))

				local force = angles2:Forward()
				force:Normalize()
				force = force * 1200 * ragdoll.dtime / 0.015 * ragdoll.power

				rleg:ApplyForceCenter(force)
				lleg:ApplyForceCenter(force)
			end
		end*/
	end
end)

hook.Add("PlayerDeath", "homigrad-fake-control", function(ply)
	local ragdoll = ply.FakeRagdoll
	if not IsValid(ragdoll) then return end
	if IsValid(ragdoll.ConsLH) then
		ragdoll.ConsLH:Remove()
		ragdoll.ConsLH = nil
		for i = 1, 4 do
			ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
		end
	end

	if IsValid(ragdoll.ConsRH) then
		ragdoll.ConsRH:Remove()
		ragdoll.ConsRH = nil
		for i = 1, 4 do
			ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
		end
	end
end)