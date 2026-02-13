local CurTime = CurTime
local time
local max, min, Round = math.max, math.min, math.Round
--local Organism = hg.organism
hg.organism.module.blood = {}
local module = hg.organism.module.blood

hg.organism.bloodtypes = {
	["o-"] = {["o-"] = true,["o+"] = true,["a-"] = true,["a+"] = true,["b-"] = true,["b+"] = true,["ab-"] = true,["ab+"] = true},
	["o+"] = {["o+"] = true,["a+"] = true,["b+"] = true,["ab+"] = true},
	["a-"] = {["a+"] = true,["a-"] = true,["ab+"] = true,["ab-"] = true},
	["a+"] = {["a+"] = true,["ab+"] = true},
	["b-"] = {["b+"] = true,["b-"] = true,["ab+"] = true,["ab-"] = true},
	["b+"] = {["b+"] = true,["ab+"] = true},
	["ab-"] = {["ab+"] = true,["ab-"] = true},
	["ab+"] = {["ab+"] = true},
	["c-"] = {["c-"] = true,["o-"] = true,["o+"] = true,["a-"] = true,["a+"] = true,["b-"] = true,["b+"] = true,["ab-"] = true,["ab+"] = true},
}

module[1] = function(org)
	org.blood = 5000
	org.bleed = 0
	org.internalBleed = 0
	org.internalBleedHeal = 0
	org.arteria = 0
	org.rarmartery = 0
	org.larmartery = 0
	org.rlegartery = 0
	org.llegartery = 0
	org.spineartery = 0
	org.bleedStart = 0
	org.wounds = {}
	org.arterialwounds = {}
	org.wantToVomit = 0
	org.vomitInThroat = nil

	org.bloodtype = table.GetKeys(hg.organism.bloodtypes)[math.random(8)]
	
	if org.bloodtype == "c-" then
		org.bloodtype = "o-" --эпик
	end

	org.hemotransfusionshock = 0

	org.survivalchance = 1
end

local internalbleed_phrases = {
	"That's... that's blood I just vomited...",
	"Oh, that's blood...",
	"Fuck, I just puked blood...",
	"Oh shit... I don't feel good...",
}

local about_to_puke = {
	"I feel like I'm gonna puke any second now...",
	"Not feeling good...",
	"Gonna puke right now...",
	"I want to vomit...",
}

local vecZero = Vector(0, 0, 0)
module[2] = function(owner, org, mulTime)
	local adrenaline = math.min(org.adrenaline, 2)

	if org.vomitInThroat then
		local ent = hg.GetCurrentCharacter(owner)
		
		local bon = "ValveBiped.Bip01_Head1"
		local bone = ent:LookupBone(bon)
		local mat = ent:GetBoneMatrix(bone)
	
		if mat and mat:GetAngles():Right()[3] < 0.25 then
			org.vomitInThroat = nil

			net.Start("bloodsquirt2")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
			net.Broadcast()

			ent:EmitSound("vomit/vomit5.mp3")
		end
	end

	if org.isPly and not org.otrub and org.blood < 2900 then org.owner:Notify(math.random(2) == 1 and "I cant feel anything..." or (math.random(2) == 1 and "I think I'm gonna faint right now...") or "I dont feel so good...",60,"blood2",0) end

	if org.internalBleed < 0.5 and org.bleed < 0.05 and org.pulse > 5 then
		org.blood = min(org.blood + mulTime * 5 * (adrenaline * 1.5 + 1) * (org.satiety / 100 + 1) * org.pulse / 70, 5000)
	end

	if org.hemotransfusionshock > 0 then
		org.hemotransfusionshock = math.max(org.hemotransfusionshock - mulTime / 200,0)
		org.internalBleed = org.internalBleed + mulTime / 30
	end

	if org.arteria == 1 then
		org.o2[1] = math.max(org.o2[1] - mulTime * 5,0)
	end

	org.consciousness = math.min(org.consciousness, math.min(org.blood / 3000, 1) * math.Clamp(((org.temperature < 30 and org.temperature - 30 or 0) * 0.25 + 1), 0.25, 1))

	local beatsPerSecond = max(min(60 / math.max(org.pulse,2) / (org.bleed / 15), 7), 0.3)
	time = CurTime()

	local coagulatespeed = 0
	local bleedoutspeed = 0
	if #org.wounds > 0 then
		local ent = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		
		for i, wound in pairs(org.wounds) do
			local rand1 = math.Rand(4, 10) * 1
			local rand2 = math.Rand(0.5, 1) * 1
			local bleed = rand1 * wound[1] * mulTime * math.max(org.pulse, 20) / 70 * 2.0 * (1 - math.min(adrenaline / 6, 0.5)) * org.bleedingmul * 0.02
			local coagulate = 2 * mulTime * rand2 * (adrenaline * 0.1 + 1) * 0.04-- / #org.wounds
			bleedoutspeed = bleedoutspeed + bleed / rand1 * 3--we pray for the luck of it being in the center
			coagulatespeed = coagulatespeed + coagulate / rand2 * 1
			
			local rand = math.Rand(0, 2) * 2
			//if wound[5] + beatsPerSecond * 2 < time then
				wound[5] = time
				org.blood = max(org.blood - bleed, 1)
				
				if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
					hg.organism.BloodDroplet2(owner, org, wound, ent:GetVelocity() + VectorRand(-15, 15), false)
					wound[1] = max(wound[1] - coagulate, 0)
				end

				if wound[1] == 0 then table.remove(org.wounds, i) owner:SetNetVar("wounds",org.wounds) end
			//end
		end
	end

	if org.heart == 1 then
		org.blood = math.max(org.blood - mulTime * 100 * org.pulse / 70,0)
		bleedoutspeed = bleedoutspeed + mulTime * 100 * org.pulse / 70
	end

	if org.liver > 0.5 then
		//org.blood = math.max(org.blood - mulTime * 10 * org.pulse / 70 * org.liver,0)
		//bleedoutspeed = bleedoutspeed + mulTime * 10 * org.pulse / 70 * org.liver
	end

	bleedoutspeed = bleedoutspeed / (beatsPerSecond + 2)

	local bleedoutspeed2 = 0
	local next_arterypump = 1 / math.max(org.pulse, 10)
	local ent = owner:IsPlayer() and IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
	for i, wound in pairs(org.arterialwounds) do
		bleedoutspeed2 = bleedoutspeed2 + wound[1] * mulTime * 0.2 * math.max(org.pulse, 20) / 80

		if wound[5] + next_arterypump * 2 < time then
			local pos, ang = ent:GetBonePosition(ent:LookupBone(wound[4]))
			wound[5] = time
			org.blood = max(org.blood - wound[1] * mulTime * 4.5 * math.max(org.pulse, 20) / 80, 1)
			if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
				local dir = wound[6]
				local len = dir:Length()
				local _, dir = LocalToWorld(vecZero, dir:Angle(), vecZero, ang)
				dir = -dir:Forward() * len
				hg.organism.BloodDroplet2(owner, org, wound, owner:GetVelocity() + VectorRand(-10, 10) + dir, true)
			end

			if wound[1] == 0 then
				table.remove(org.arterialwounds, i)
				owner:SetNetVar("arterialwounds", org.arterialwounds)

				org[wound[7]] = 0
			end
		end
	end
	bleedoutspeed2 = bleedoutspeed2 / next_arterypump

	if org.blood < (2400 / (adrenaline / 3 + 1)) * ((math.cos(CurTime()/2) + 1) / 2 * 0.1 + 1) then org.needotrub = true end

	local bleed = org.internalBleed / 14 -- + org.lungsR[3] + org.lungsL[3]
	org.internalBleed = math.Approach(org.internalBleed, 0, org.internalBleedHeal > 0 and mulTime / 2 or mulTime / 55)
	coagulatespeed = coagulatespeed + mulTime
	org.internalBleedHeal = math.Approach(org.internalBleedHeal, 0, mulTime / 2)
	
	if bleed > 0 then org.blood = max(org.blood - bleed * mulTime * 10 * org.pulse / 70, 1) end
	
	if (org.internalBleed > 1 or org.pneumothorax > 0) and org.blood > 2000 and org.o2[1] > 0 then
		org.wantToVomit = org.wantToVomit or 0

		org.wantToVomit = org.wantToVomit + math.Rand(0, org.internalBleed / 1000 + org.pneumothorax / 200) * mulTime * 5
		
		if org.wantToVomit > 0.90 then
			//owner:Notify(about_to_puke[math.random(#about_to_puke)], 15, "internalbleed_pre")
		end
	end

	if org.wantToVomit > 1 then
		org.wantToVomit = 0

		if org.isPly then owner:Notify(internalbleed_phrases[math.random(#internalbleed_phrases)], 15, "internalbleed") end

		hg.organism.Vomit(owner)
	end

	org.bleed = (bleedoutspeed + bleedoutspeed2 + bleed)--в секунду
	
	local timetouncon = (org.blood - 2500) / org.bleed
	
	local bleeding_will_stop = (timetouncon ~= timetouncon) or ((coagulatespeed * timetouncon - org.bleed) > 0)
	local canwakeup_pain = ((org.pain - 5) / (org.painlessen)) < timetouncon
	org.timetouncon = (timetouncon ~= timetouncon) and timetouncon or Lerp(hg.lerpFrameTime2(0.01,mulTime), org.timetouncon or 10000, timetouncon)
	
	if org.otrub and ((not bleeding_will_stop and not (canwakeup_pain and org.blood > 3000)) or (org.brain > 0.4) or (org.pulse < 15) or (org.o2[1] < 5) or (org.trachea >= 0.5) or org.heartstop or (org.spine3 >= hg.organism.fake_spine3) or (org.spine2 >= hg.organism.fake_spine2)) then
		org.incapacitated = true
	else
		org.incapacitated = false
	end

	if (org.brain > 0.4) or (org.heart > 0.6) or (org.trachea >= 0.6) then
		org.critical = true
	else
		org.critical = false
	end

	org.bleed = (bleedoutspeed + bleedoutspeed2)
end

util.AddNetworkString("bloodsquirt2")

function hg.organism.Vomit(owner, snd)
	if !hg.IsValidPlayer(owner) then return end
	
	local org = owner.organism
	org.blood = math.max(org.blood - 200, 0)
	local ent = hg.GetCurrentCharacter(owner)

	local bon = "ValveBiped.Bip01_Head1"
	local bone = ent:LookupBone(bon)
	local mat = ent:GetBoneMatrix(bone)

	if not mat then return end

	local on_spine = mat:GetAngles():Right()[3] > 0.25
	if on_spine then
		org.vomitInThroat = true
	end

	owner:SetNetVar("vomiting", CurTime() + 1.5)

	ent:EmitSound(snd or "zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "female" or "male").."_cough"..math.random(4)..".mp3")
	if !on_spine then ent:EmitSound("vomit/vomit5.mp3") end
	
	if owner.armors and owner.armors.face and hg.armor.face[owner.armors.face].voice_change then
		owner:SetNetVar("zableval_masku", true)
	else
		if !on_spine then
			net.Start("bloodsquirt2")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
			net.Broadcast()
		end
	end
end

function hg.organism.CoughBlood(org)
	local ply = org.owner
	local phr = "zcitysnd/real_sonar/" .. (ThatPlyIsFemale(ply) and "female" or "male") .. "_cough" .. math.random(4) .. ".mp3"
	ply:EmitSound(phr)
	ply.phrCld = CurTime() + 2
	ply.lastPhr = phr

	if math.random(5) == 1 then
		org.vomitInThroat = nil

		net.Start("bloodsquirt2")
		net.WriteEntity(ent)
		net.WriteString(bon)
		net.WriteMatrix(mat)
		net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
		net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
		net.Broadcast()

		ent:EmitSound("vomit/vomit5.mp3")
	end
end

function hg.organism.BloodDroplet2(owner, org, wound, dir, artery)
	hook.Run("HG_BloodParticleStartedDropping", owner, org, wound, dir, artery)
end