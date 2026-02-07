hook.Add("Org Think", "regenerationfurry", function(owner, org, timeValue)
	if not owner:IsPlayer() or not owner:Alive() then return end
	if owner.PlayerClassName != "furry" then return end
	//if org.heartstop then return end

	org.blood = math.Approach(org.blood, 5000, timeValue * 60)

	for i, wound in pairs(org.wounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	org.internalBleed = math.max(org.internalBleed - timeValue * 0.6, 0)
	
	local regen = timeValue / 60

	org.lleg = math.max(org.lleg - regen, 0)
	org.rleg = math.max(org.rleg - regen, 0)
	org.rarm = math.max(org.rarm - regen, 0)
	org.larm = math.max(org.larm - regen, 0)
	org.chest = math.max(org.chest - regen, 0)
	org.pelvis = math.max(org.pelvis - regen, 0)
	org.spine1 = math.max(org.spine1 - regen, 0)
	org.spine2 = math.max(org.spine2 - regen, 0)
	org.spine3 = math.max(org.spine3 - regen, 0)
	org.skull = math.max(org.skull - regen, 0)

	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false

	org.liver = math.max(org.liver - regen, 0)
	org.intestines = math.max(org.intestines - regen, 0)
	org.heart = math.max(org.heart - regen, 0)
	org.stomach = math.max(org.stomach - regen, 0)
	org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math.max(org.lungsR[2] - regen, 0)
	org.lungsL[2] = math.max(org.lungsL[2] - regen, 0)
	org.brain = math.max(org.brain - regen * 0.1, 0)

	org.hungry = 0
end)

hook.Add("PlayerDeath", "FurDeathSound", function(ply)
	if ply.PlayerClassName == "furry" then
		ply:EmitSound("zbattle/robot_death.ogg")
	end
end)

util.AddNetworkString("CrackScreen")

hook.Add("HomigradDamage","FurCrackHit",function(ply, dmgInfo, hitgroup, ent)
	if ply.PlayerClassName == "furry" then
		if hitgroup == HITGROUP_HEAD then
			local intensity = math.max(dmgInfo:GetDamage() / 3, 0.05)

			//if intensity > 0.1 then
			//	timer.Simple(0, function()
			//		ply.armors["head"] = "protovisor"
			//		ply:SyncArmor()
			//	end)
			//end

			net.Start("CrackScreen")
				net.WriteFloat(intensity)
			net.Send(ply)

			if intensity > 0.1 then
				ply:EmitSound("zbattle/glass_shatter.ogg", nil, math.random(70, 130))
			else
				ply:EmitSound("zbattle/glass_break.ogg", nil, math.random(70, 130), math.random(10, 30))
			end
		end
	end
end)

local fur_pain = {
	"zbattle/furry/exp5.wav",
	"zbattle/furry/exp6.wav",
	"zbattle/furry/exp7.wav",
	"zbattle/furry/exp8.wav",
	"zbattle/furry/exp9.wav",
	"zbattle/furry/exp10.wav",
	"zbattle/furry/exp11.wav",
	"zbattle/furry/exp12.wav",
	"zbattle/furry/exp13.wav",
	"zbattle/furry/exp14.wav",
	"zbattle/furry/exp15.wav",
	"zbattle/furry/exp16.wav",
	"zbattle/furry/exp17.wav",
	"zbattle/furry/death1.wav",
	"zbattle/furry/death3.wav",
	"zbattle/furry/death4.wav",
	"zbattle/furry/death5.wav",
}

local uwuspeak_phrases = {
	"zbattle/furry/cat_mrrp1.ogg",
	"zbattle/furry/cat_mrrp1.ogg",
	"zbattle/furry/cat_purr1.ogg",
	"zbattle/furry/cat_purr2.ogg",
	"zbattle/furry/mewo.ogg",
	"zbattle/furry/mrrp.ogg",
	"zbattle/furry/prbt.ogg",
	"zbattle/furry/beep1.wav",
	"zbattle/furry/beep2.wav",
}

hook.Add("HG_ReplacePhrase", "UwUPhrases", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.PlayerClassName == "furry" then
		local inpain = ply.organism.pain > 60
		local phr = (inpain and fur_pain[math.random(#fur_pain)] or uwuspeak_phrases[math.random(#uwuspeak_phrases)])

		return ply, phr, muffed, pitch
	end
end)

hook.Add("HG_ReplaceBurnPhrase", "UwUBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "furry" then
		return ply, fur_pain[math.random(#fur_pain)]
	end
end)

hook.Add("Org Think", "ItHurtsfrfr",function(owner, org, timeValue)
	if owner.PlayerClassName != "furry" then return end

	if (owner.lastPainSoundCD or 0) < CurTime() and !org.otrub and org.pain >= 30 and math.random(1, 50) == 1 then
		local phrase = table.Random(fur_pain)

		local muffed = owner.armors["face"] == "mask2"

		owner:EmitSound(phrase, muffed and 65 or 75,owner.VoicePitch or 100,1,CHAN_AUTO,0, pitch and 56 or muffed and 16 or 0)

		owner.lastPainSoundCD = CurTime() + math.Rand(10, 25)
		owner.lastPhr = phrase
	end
end)