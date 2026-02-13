local painPhrases = {
	[1] = {
		{"vo/npc/male01/moan", ".wav", 1, 5},
	},
	[2] = {
		{"vo/npc/female01/moan", ".wav", 1, 5},
	}
}

local bigPainPhrases = {
	[1] = {
		{"vo/npc/male01/pain", ".wav", 7, 9},
	},
	[2] = {
		{"vo/npc/female01/pain", ".wav", 9, 9},
		{"vo/npc/female01/pain", ".wav", 6, 6},
		{"vo/npc/female01/ow", ".wav", 2, 2},
	}
}

local terrorist_phrases = {
	normal = {
		"mercenary/moving1.mp3",
		"mercenary/moving2.mp3",
		"mercenary/moving3.mp3",
		"mercenary/moving4.mp3",
		"mercenary/moving5.mp3",
		"mercenary/moving6.mp3",
		"mercenary/intimidate1.mp3",
		"mercenary/intimidate2.mp3",
		"mercenary/intimidate3.mp3",
		"mercenary/intimidate4.mp3",
		"mercenary/intimidate5.mp3"
	},
	kill = {
		"mercenary/kill1.mp3",
		"mercenary/kill2.mp3",
		"mercenary/kill3.mp3",
		"mercenary/kill4.mp3",
		"mercenary/kill5.mp3",
		"mercenary/kill6.mp3",
		"mercenary/kill7.mp3",
		"mercenary/kill8.mp3",
		"mercenary/killswear1.mp3",
		"mercenary/killswear2.mp3"
	},
	teammate_death = {
		"mercenary/mandown1.mp3",
		"mercenary/mandown2.mp3",
		"mercenary/mandown3.mp3",
		"mercenary/mandown4.mp3",
		"mercenary/mandown5.mp3",
		"mercenary/mandown6.mp3",
		"mercenary/mandown7.mp3"
	},
	grenade_throw = {
		"mercenary/fragout1.mp3",
		"mercenary/fragout2.mp3",
		"mercenary/fragout3.mp3",
		"mercenary/fragout4.mp3",
		"mercenary/fragout5.mp3",
		"mercenary/fragout6.mp3",
		"mercenary/fragout7.mp3",
		"mercenary/fragout8.mp3",
		"mercenary/fragout9.mp3",
		"mercenary/fragout10.mp3",
		"mercenary/fragout11.mp3",
		"mercenary/fragout12.mp3",
		"mercenary/fragout13.mp3",
		"mercenary/fragout14.mp3",
		"mercenary/fragout15.mp3",
		"mercenary/fragout16.mp3",
		"mercenary/fragout17.mp3"
	},
	reload = {
		"mercenary/reloading1.mp3",
		"mercenary/reloading2.mp3",
		"mercenary/reloading3.mp3",
		"mercenary/reloading4.mp3",
		"mercenary/reloading5.mp3",
		"mercenary/reloading6.mp3",
		"mercenary/reloading7.mp3",
		"mercenary/reloading8.mp3",
		"mercenary/reloading9.mp3",
		"mercenary/reloading10.mp3",
		"mercenary/reloading11.mp3",
		"mercenary/reloading12.mp3",
		"mercenary/reloading13.mp3",
		"mercenary/reloading14.mp3",
		"mercenary/reloading15.mp3"
	}
}

local nationalguard_phrases = {
	normal = {
		"national_guard/ng_nationalguard_1.mp3",
		"national_guard/ng_nationalguard_2.mp3",
		"national_guard/ng_readytofight_1.mp3",
		"national_guard/ng_readytofight_2.mp3"
	},
	kill = {
		"national_guard/ng_getsome_1.mp3",
		"national_guard/ng_getsome_2.mp3"
	},
	teammate_death = {
		"national_guard/ng_mandown_1.mp3",
		"national_guard/ng_mandown_2.mp3"
	},
	grenade_throw = {
		"national_guard/ng_fireinthehole_1.mp3",
		"national_guard/ng_fireinthehole_2.mp3"
	},
	reload = {
		"national_guard/ng_reloading_1.mp3",
		"national_guard/ng_reloading_2.mp3"
	}
}

local commanderforces_phrases = {
	normal = {
		"n51/spot/spot.ogg",
		"n51/spot/spot1.ogg",
		"n51/spot/spot2.ogg",
		"n51/spot/spot3.ogg",
		"n51/spot/spot4.ogg",
		"n51/spot/spot5.ogg",
		"n51/spot/spot6.ogg",
		"n51/spot/spot7.ogg",
		"n51/spot/spot8.ogg"

	},
	kill = {
		"n51/kill/kill.ogg",
		"n51/kill/kill1.ogg",
		"n51/kill/kill2.ogg",
		"n51/kill/kill3.ogg",
		"n51/kill/kill4.ogg"
	}
}


local swat_phrases = {
	normal = {
		"specops/moving1.mp3",
		"specops/moving2.mp3",
		"specops/moving3.mp3",
		"specops/moving4.mp3",
		"specops/moving5.mp3",
		"specops/moving6.mp3",
		"specops/intimidate1.mp3",
		"specops/intimidate2.mp3",
		"specops/intimidate3.mp3",
		"specops/intimidate4.mp3",
		"specops/intimidate5.mp3"
	},
	kill = {
		"specops/kill1.mp3",
		"specops/kill2.mp3",
		"specops/kill3.mp3",
		"specops/kill4.mp3",
		"specops/kill5.mp3",
		"specops/kill6.mp3",
		"specops/kill7.mp3",
		"specops/kill8.mp3",
		"specops/killswear1.mp3",
		"specops/killswear2.mp3"
	},
	teammate_death = {
		"specops/mandown1.mp3",
		"specops/mandown2.mp3",
		"specops/mandown3.mp3",
		"specops/mandown4.mp3",
		"specops/mandown5.mp3",
		"specops/mandown6.mp3",
		"specops/mandown7.mp3"
	},
	grenade_throw = {
		"specops/fragout1.mp3",
		"specops/fragout2.mp3",
		"specops/fragout3.mp3",
		"specops/fragout4.mp3",
		"specops/fragout5.mp3",
		"specops/fragout6.mp3",
		"specops/fragout7.mp3",
		"specops/fragout8.mp3",
		"specops/fragout9.mp3",
		"specops/fragout10.mp3",
		"specops/fragout11.mp3",
		"specops/fragout12.mp3",
		"specops/fragout13.mp3",
		"specops/fragout14.mp3",
		"specops/fragout15.mp3",
		"specops/fragout16.mp3",
		"specops/fragout17.mp3"
	},
	reload = {
		"specops/reloading1.mp3",
		"specops/reloading2.mp3",
		"specops/reloading3.mp3",
		"specops/reloading4.mp3",
		"specops/reloading5.mp3",
		"specops/reloading6.mp3",
		"specops/reloading7.mp3",
		"specops/reloading8.mp3",
		"specops/reloading9.mp3",
		"specops/reloading10.mp3",
		"specops/reloading11.mp3",
		"specops/reloading12.mp3",
		"specops/reloading13.mp3",
		"specops/reloading14.mp3",
		"specops/reloading15.mp3"
	}
}



local laugh = {
	"zbattle/laugh/laugh1.ogg",
	"zbattle/laugh/laugh2.ogg",
	"zbattle/laugh/laugh3.ogg",
	"zbattle/laugh/laugh4.ogg",
	"zbattle/laugh/laugh5.ogg",
	"zbattle/laugh/laugh6.ogg",
	"zbattle/laugh/laugh7.ogg",
}

local f_laugh = {
	"zbattle/laugh/f_laugh1.ogg",
	"zbattle/laugh/f_laugh2.ogg",
	"zbattle/laugh/f_laugh3.ogg",
	"zbattle/laugh/f_laugh4.ogg",
	"zbattle/laugh/f_laugh5.ogg",
	"zbattle/laugh/f_laugh6.ogg",
}

local file, math, table, CurTime, timer, string = file, math, table, CurTime, timer, string

local function GetPlayerClassPhrases(ply, phraseType)
	local playerClass = ply.PlayerClassName

	if playerClass == "terrorist" and terrorist_phrases[phraseType] then
		return terrorist_phrases[phraseType]
	elseif playerClass == "nationalguard" and nationalguard_phrases[phraseType] then
		return nationalguard_phrases[phraseType]
	elseif playerClass == "commanderforces" and commanderforces_phrases[phraseType] then
		return commanderforces_phrases[phraseType]
	elseif playerClass == "swat" and swat_phrases[phraseType] then
		return swat_phrases[phraseType]
	end

	return nil
end

hg = hg or {}
hg.GetPlayerClassPhrases = GetPlayerClassPhrases

local mClamp, mRandom = math.Clamp, math.random

local function PlayClassPhrase(ply, phraseType)
	if !IsValid(ply) or !ply:Alive() then return end
	if ply.organism and ply.organism.otrub then return end
	if (ply.phrCld or 0) > CurTime() then return end

	local classPhrases = GetPlayerClassPhrases(ply, phraseType)

	if !classPhrases or #classPhrases == 0 then
		return
	end

	local randomPhrase = classPhrases[mRandom(#classPhrases)]
	local ent = hg.GetCurrentCharacter(ply)
	local muffed = ply.armors and ply.armors["face"] == "mask2"

	ent:EmitSound(randomPhrase, muffed and 75 or 85, ply.VoicePitch or 100, 1, CHAN_AUTO, 0, muffed and 14 or 0)

	if string.match(randomPhrase, ".ogg") or string.match(randomPhrase, ".mp3") then
		ply.phrCld = CurTime() + 2
	else
		ply.phrCld = CurTime() + (SoundDuration(randomPhrase) or 2)
	end

	ply.lastPhr = randomPhrase
end

hook.Add("PlayerSpawn","GiveRandomPitch",function(ply)
	if OverrideSpawn then return end

	ply.VoicePitch = mRandom(93, 107)
end)

util.AddNetworkString("hg_phrase")
net.Receive("hg_phrase", function(len, ply)
	if (ply.phrCld or 0) > CurTime() then return end
	local result = hook.Run("HG_CanDoPhrase", ply, cmd, args) // return here true to reject phrase 
	if result then return end

	local playerClass = ply.PlayerClassName

	if playerClass == "terrorist" or playerClass == "nationalguard" or 
	   playerClass == "commanderforces" or playerClass == "swat" then
		PlayClassPhrase(ply, "normal")
		return
	end

	local gender = ThatPlyIsFemale(ply) and 2 or 1
	local i = net.ReadInt(8)
	local num = net.ReadInt(8)
	if ply.organism.brain > 0.1 then
		i = 5
		num = mRandom(1, 2)
	end

	local phrases2 = phrases

	local inpain = ply.organism.pain > 60
	if inpain then
		phrases2 = bigPainPhrases

		if ply.organism.pain > 100 then
			phrases2 = painPhrases
		end
	end
	
	local phr = phrases2[math.Round(mClamp(gender, 1, 2))]
	phr = phr[math.Round(mClamp(i, 1, #phr))]
	
	if !phr then return end

	local random = math.Round(mClamp(num, phr[3], phr[4]))

	if inpain then
		random = mRandom(phr[3], phr[4])
	end

	local huy = random < 10 and "0" or ""
	local phrase = phr[1] .. huy .. random .. phr[2]
	local ent = hg.GetCurrentCharacter(ply)
	local muffed = false
	local pitch = nil

	-- overrides
	local override_ply, override_phrase, override_muffed, override_pitch = hook.Run("HG_ReplacePhrase", ply, phrase, muffed, pitch) -- pitch means pitched effect, not exact sound pitch
	if override_ply ~= nil then
		phrase, muffed, pitch = override_phrase, override_muffed, override_pitch
	end


	if ply.PlayerClassName == "bloodz" or ply.PlayerClassName == "groove" then
		phrase = table.Random(hg.ghetto_phrases)
		local rf = RecipientFilter()
		rf:AddPAS(ply:GetPos())
		ply.sndplay = CreateSound(ply, phrase, rf)
		ply.sndplay:SetSoundLevel(muffed and 65 or 75)
		ply.sndplay:SetDSP(muffed and 16 or 0)
		ply.sndplay:Play()
		ply.sndplay:ChangeVolume(0.01)
		timer.Simple(0.2, function()
			ply.sndplay:ChangeVolume(1)
		end)
		timer.Simple(hg.precachedsounds[phrase] - 0.5, function()
			ply.sndplay:ChangeVolume(0)
		end)
		ply.phrCld = CurTime() + (hg.precachedsounds[phrase] or 0)
		ply.lastPhr = phrase
		return
	end

	if SoundDuration(phrase) == 0 then return end

	local wawer = string.match(ply:GetModel(), "scug")
	if wawer then
		ent:EmitSound(phrase, wawer and 65 or muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, muffed and 14 or 0)
		ent:EmitSound(phrase, wawer and 65 or muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, muffed and 14 or 0)
	else
		ent:EmitSound(phrase, muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, pitch and 56 or muffed and 14 or 0)
	end

	if string.match( phrase, ".ogg" ) then // ogg doesn't return the right soundduration
		ply.phrCld = CurTime() + 1
	else
		ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
	end
	ply.lastPhr = phrase
end)

hook.Add("PlayerDeath", "StopPhrOnDeath",function(ply)
	local ent = hg.GetCurrentCharacter(ply)
	ent:StopSound(ply.lastPhr or "")
	ply.phrCld = 0
end)

hook.Add("HG_OnOtrub", "StopPhrOnOtrub", function( ply )
	local ent = hg.GetCurrentCharacter(ply)
	ent:StopSound(ply.lastPhr or "")
	ply.phrCld = 0
end)

local femaleCount = 10
local maleCount = 14
local clr = Color(204,48,0)

hook.Add("PreHomigradDamage","BurnScream", function( ent, dmgInfo )
	local ply = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent

	if dmgInfo:IsDamageType(DMG_BURN) and IsValid(ply) and ply:IsPlayer() 
	and ply.organism and !ply.organism.otrub and ply:Alive() then
		local phrase = "zcitysnd/"..(ThatPlyIsFemale(ply) and "fe" or "").."male/burn/death_burn"..mRandom(1,ThatPlyIsFemale(ply) and femaleCount or maleCount)..".mp3"

		-- overrides
		override_ply, override_phrase = hook.Run("HG_ReplaceBurnPhrase", ply, phrase)
		if override_ply ~= nil then
			ply, phrase = override_ply, override_phrase
		end

		ply:Notify(hg.sharp_pain[math.random(#hg.sharp_pain)], 
		SoundDuration(phrase), "ply_burn", 0.5, function(ply)
			if hg.GetCurrentCharacter(ply):IsOnFire() then
				hg.GetCurrentCharacter(ply):EmitSound(phrase)
				ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
				ply.lastPhr = phrase
			end
		end, clr)
	end
end)

hook.Add("Org Think", "WhatsSoFunny",function(owner, org, timeValue)
	if (owner.lastBerserkLaughSoundCD or 0) < CurTime() and !org.otrub and owner:IsBerserk() and mRandom(1, 50) == 1 then
		local phrase = (ThatPlyIsFemale(owner) and table.Random(f_laugh)) or table.Random(laugh)

		local muffed = owner.armors["face"] == "mask2"

		owner:EmitSound(phrase, muffed and 90 or 100,owner.VoicePitch or 100,1 * math.min(2, org.berserk),CHAN_AUTO,0, pitch and 56 or muffed and 16 or 0)

		owner.lastBerserkLaughSoundCD = CurTime() + math.Rand(5, 15)
		owner.lastPhr = phrase
	end
end)

// Stop it in water
hook.Add("OnEntityWaterLevelChanged","StopPhraseInWater",function(ent,old,new)
	if ent:IsPlayer() or ent:IsRagdoll() then
		local ply = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
		local entReal = hg.GetCurrentCharacter(ply)
		if ent == entReal and new == 3 then
			ply.phrCld = 0
			ent:StopSound(ply.lastPhr or "")
		end
	end
end)

// Context Phrases
concommand.Add("hg_phrase_context",function(ply, cmd, args)
	if !IsValid(ply) then return end
	local result = hook.Run("HG_CanDoPhrase", ply, cmd, args) // return here true to reject phrase 
	if result then return end

	result = hook.Run("HG_Phrase_Context", ply, cmd, args) // return here true to reject phrase 
	if result then return end

	local phrase = contextPhrases[ThatPlyIsFemale(ply) and 2 or 1][args[1]]
	if !phrase then return end

	phrase = args[2] and phrase[tonumber(args[2])] or table.Random(phrase)
	if SoundDuration(phrase) == 0 then return end
	ply:EmitSound(phrase, nil, ply.VoicePitch or 100)
	ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
	ply.lastPhr = phrase
end)

hook.Add("HG_CanDoPhrase", "Pharse_Check", function(ply, cmd, args)
	if (ply.phrCld or 0) > CurTime() then return true end
	if ply.PlayerClassName == "Gordon" then return true end // move it to gordon playerclass soon...
	if !IsValid(ply) or !ply:Alive() or ply:WaterLevel() >= 3 then return true end
	local org = ply.organism
	if !org then return true end
	if org.otrub then return true end
	if org.o2[1] < 15 then return true end
	if org.holdingbreath then return true end
	--if ply.PlayerClassName and ply:GetPlayerClass() and !ply:GetPlayerClass().CanUseDefaultPhrase then return true end

	if org.vomitInThroat then
		hg.organism.CoughBlood(org)
	end

	if !hg.organism.CanBreath(org) then return true end
end)

hook.Add("HG_Phrase_Context", "Pharse_Check", function(ply, cmd, args)
	local org = ply.organism
	if !org then return true end

	if org.brain > 0.1 then
		return true
	end

	if (org.pain > 30 or hg.fearful(ply)) and args[1] == "Satisfied" then return true end
end)

hook.Add("HarmDone", "killmazafaka", function(attacker, victim, amt)
	if !IsValid(attacker) or !attacker:IsPlayer() then return end
	if !IsValid(victim) or !victim:IsPlayer() then return end
	if attacker == victim then return end
	
	if amt < 0.8 then return end
	
	local playerClass = attacker.PlayerClassName
	if playerClass == "terrorist" or playerClass == "nationalguard" or 
	   playerClass == "commanderforces" or playerClass == "swat" then
		timer.Simple(0.5, function()
			if IsValid(attacker) and IsValid(victim) and !victim:Alive() then
				PlayClassPhrase(attacker, "kill")
			end
		end)
	end
end)

hook.Add("HarmDone", "MateDead", function(attacker, victim, amt)
	if !IsValid(victim) or !victim:IsPlayer() then return end
	
	local victimClass = victim.PlayerClassName
	if !(victimClass == "terrorist" or victimClass == "nationalguard" or 
			victimClass == "commanderforces" or victimClass == "swat") then return end
	
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() and ply ~= victim and ply.PlayerClassName == victimClass then
			local distance = ply:GetPos():Distance(victim:GetPos())
			if distance <= 1000 then
				local tr = util.TraceLine({
					start = ply:EyePos(),
					endpos = victim:GetPos() + Vector(0, 0, 50),
					filter = ply,
					mask = MASK_OPAQUE
				})
				
				if !tr.Hit or tr.Entity == victim then
					timer.Simple(math.Rand(0.5, 2), function()
						if IsValid(ply) and ply:Alive() then
							PlayClassPhrase(ply, "teammate_death")
						end
					end)
				end
			end
		end
	end
end)


hook.Add("HGReloading", "Perezaryad", function(wep)
	if CLIENT then return end
	local ply = wep:GetOwner()
	if !IsValid(ply) then return end
	
	local playerClass = ply.PlayerClassName
	if !(playerClass == "terrorist" or playerClass == "nationalguard" or playerClass == "swat") then return end
	
	ply.ClassReloadSND_CD = ply.ClassReloadSND_CD or 0
	if ply.ClassReloadSND_CD > CurTime() then return end
	
	if ply:Alive() and !ply.organism.otrub and mRandom(1, 100) <= 25 then
		PlayClassPhrase(ply, "reload")
		ply.ClassReloadSND_CD = CurTime() + 3 
	end
end)